SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE PROCEDURE [dbo].[sp_sysutility_ucp_initialize] 
   @utility_name sysname,
   @mdw_database_name sysname,
   @description nvarchar(1024) = N''
WITH EXECUTE AS OWNER
AS
BEGIN
    DECLARE @retval INT
    DECLARE @null_column    sysname
    
    SET @null_column = NULL

    IF (@utility_name IS NULL OR @utility_name = N'')
        SET @null_column = '@utility_name'
    ELSE IF (@mdw_database_name IS NULL OR @mdw_database_name = N'')
        SET @null_column = '@mdw_database_name'



    IF @null_column IS NOT NULL
    BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_sysutility_ucp_initialize')
        RETURN(1)
    END


    -- Make sure that the Utility wasn't already created
    DECLARE @utilityName sysname
    set @utilityName = (SELECT CAST (current_value as sysname) FROM msdb.dbo.sysutility_ucp_configuration_internal where name = 'UtilityName')
    

    IF (@utilityName IS NOT NULL AND @utilityName != N'')
    BEGIN
        RAISERROR(37003, -1, -1)
        RETURN(1)
    END


    IF NOT EXISTS (SELECT * FROM master.dbo.sysdatabases WHERE name = @mdw_database_name)
    BEGIN
        RAISERROR(37002, -1, -1, @mdw_database_name)
        RETURN(1)
    END

    UPDATE dbo.sysutility_ucp_configuration_internal
       SET current_value = @utility_name WHERE name = N'UtilityName'

    UPDATE dbo.sysutility_ucp_configuration_internal
       SET current_value = @mdw_database_name WHERE name = N'MdwDatabaseName'

    UPDATE dbo.sysutility_ucp_configuration_internal
       SET current_value = SYSDATETIMEOFFSET() WHERE name = N'UtilityDateCreated'

    UPDATE dbo.sysutility_ucp_configuration_internal
       SET current_value = SUSER_SNAME() WHERE name = N'UtilityCreatedBy'

    IF (@description IS NOT NULL AND @description != N'')
    BEGIN
       UPDATE dbo.sysutility_ucp_configuration_internal
          SET current_value = @description WHERE name = N'UtilityDescription'
    END

    DECLARE @utility_version SYSNAME
    set @utility_version = (SELECT CAST(current_value AS SYSNAME) FROM
                              [msdb].[dbo].[sysutility_ucp_configuration_internal]
                              WHERE name = N'UtilityVersion')

    ---- Add the UtilityVersion, UcpName and the UcpFriendlyName registry key values.
    EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Utility',
                                         N'UtilityVersion',
                                         N'REG_SZ',
                                         @utility_version

    EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Utility',
                                         N'UcpName',
                                         N'REG_SZ',
                                         @@SERVERNAME

    EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Utility',
                                         N'UcpFriendlyName',
                                         N'REG_SZ',
                                         @utility_name

END

GO
