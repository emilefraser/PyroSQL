SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysutility_mi_add_ucp_registration]
    @ucp_instance_name SYSNAME,
    @mdw_database_name SYSNAME
WITH EXECUTE AS OWNER
AS
BEGIN
   
   DECLARE @null_column SYSNAME = NULL
   SET NOCOUNT ON;
   SET XACT_ABORT ON;

   IF (@ucp_instance_name IS NULL)
     SET @null_column = '@ucp_instance_name'
   ELSE IF (@mdw_database_name IS NULL)
     SET @null_column = '@mdw_database_name'

   IF @null_column IS NOT NULL
   BEGIN
     RAISERROR(14043, -1, -1, @null_column, 'sp_sysutility_mi_add_ucp_registration')
     RETURN(1)
   END
    
   BEGIN TRANSACTION;
    
     IF EXISTS (SELECT * FROM [msdb].[dbo].[sysutility_mi_configuration_internal])
    BEGIN
      UPDATE [msdb].[dbo].[sysutility_mi_configuration_internal]
      SET
         ucp_instance_name          = @ucp_instance_name,
         mdw_database_name          = @mdw_database_name
    END
    ELSE
    BEGIN
         INSERT INTO [msdb].[dbo].[sysutility_mi_configuration_internal] (ucp_instance_name, mdw_database_name)
         VALUES (@ucp_instance_name, @mdw_database_name);
    END          
    
   COMMIT TRANSACTION;

   ---- Add the MiUcpName registry key values.
   ---- If the value is already present this XP will update them.
   EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                        N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Utility',
                                        N'MiUcpName',
                                        N'REG_SZ',
                                        @ucp_instance_name
                                         
END

GO
