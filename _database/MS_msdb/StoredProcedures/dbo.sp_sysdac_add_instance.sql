SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysdac_add_instance]  
    @type_name sysname,
    @instance_id UniqueIdentifier = NULL,            
    @instance_name sysname,
    @type_version NVARCHAR(64) = NULL,
    @description nvarchar(4000) = N'',
    @type_stream varbinary(max)
AS  
SET NOCOUNT ON;
BEGIN  
    DECLARE @retval INT  

    DECLARE @null_column sysname    
    SET @null_column = NULL

    IF (@type_name IS NULL OR @type_name = N'')
        SET @null_column = '@type_name'
    ELSE IF (@instance_name IS NULL OR @instance_name = N'')
        SET @null_column = '@instance_name'
    ELSE IF (@instance_id IS NULL )
        SET @null_column = '@instance_id'
    ELSE IF( @type_version = N'')
        SET @null_column = '@type_version'
    ELSE IF( @type_stream IS NULL)
        SET @null_column = '@type_stream'
      

    IF @null_column IS NOT NULL
    BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_sysdac_add_instance')
        RETURN(1)
    END

    -- only users that can create a dac can add instances
    if (dbo.fn_sysdac_is_dac_creator() != 1)
    BEGIN
        RAISERROR(36010, -1, -1);
        RETURN(1); -- failure
    END
    
    --instance_name is unique
    IF EXISTS (SELECT * FROM dbo.sysdac_instances_internal WHERE instance_name = @instance_name) 
    BEGIN
        RAISERROR(36001, -1, -1, 'DacInstance', @instance_name)
        RETURN(1)
    END

    --Ensure that the database being referred exists
    IF NOT EXISTS (SELECT * from sys.sysdatabases WHERE name = @instance_name)
    BEGIN
        RAISERROR(36005, -1, -1, @instance_name)
        RETURN(1)
    END
  
    INSERT INTO [dbo].[sysdac_instances_internal]
        (instance_id, type_name, instance_name, type_version, description, type_stream)
    VALUES
        (@instance_id, @type_name, @instance_name, @type_version, @description, @type_stream)

    SELECT @retval = @@error
    RETURN(@retval)
END

GO
