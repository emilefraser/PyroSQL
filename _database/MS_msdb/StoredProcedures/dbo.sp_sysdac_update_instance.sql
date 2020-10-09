SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysdac_update_instance]  
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

   IF (@type_name = N'')
        SET @null_column = '@type_name'
    ELSE IF (@instance_name = N'')
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

    -- Ensure that the package being referred to exists by using the package view. We only continue if we can see 
    -- the specified package. The package will only be visible if we are the associated dbo or sysadmin and it exists
    IF NOT EXISTS (SELECT * from dbo.sysdac_instances WHERE instance_id = @instance_id)
    BEGIN
        RAISERROR(36004, -1, -1)
        RETURN(1)
    END
    
    UPDATE sysdac_instances_internal SET
        type_name = ISNULL(@type_name, type_name),
        instance_name = ISNULL(@instance_name, instance_name),
		type_version = @type_version,
		description = @description, 
		type_stream = @type_stream
    WHERE instance_id = @instance_id 
    
    SELECT @retval = @@error
    RETURN(@retval)
END

GO
