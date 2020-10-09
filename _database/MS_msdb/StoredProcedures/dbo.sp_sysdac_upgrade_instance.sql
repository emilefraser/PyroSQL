SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysdac_upgrade_instance]  
    @source_instance_id UniqueIdentifier = NULL,   
    @instance_id UniqueIdentifier = NULL,            
    @instance_name sysname,
    @database_name sysname
AS  
SET NOCOUNT ON;
BEGIN  
    DECLARE @retval INT  

    DECLARE @null_column sysname    
    SET @null_column = NULL

    IF (@source_instance_id IS NULL)
        SET @null_column = '@source_instance_id'
    ELSE IF (@instance_id IS NULL )
        SET @null_column = '@instance_id'
    ELSE IF( @database_name IS NULL)
        SET @null_column = '@database_name'

    IF @null_column IS NOT NULL
    BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_sysdac_upgrade_instance')
        RETURN(1)
    END
    
    -- Ensure that the package being referred to exists by using the package view. We only continue if we can see 
    -- the specified package. The package will only be visible if we are the associated dbo or sysadmin and it exists
    IF NOT EXISTS (SELECT * from dbo.sysdac_instances WHERE instance_id = @instance_id)
    BEGIN
        RAISERROR(36004, -1, -1)
        RETURN(1)
    END
    
    --Ensure that the package being referred exists
    IF NOT EXISTS (SELECT * from dbo.sysdac_instances_internal WHERE instance_id = @instance_id)
    BEGIN
        RAISERROR(36004, -1, -1)
        RETURN(1)
    END

    BEGIN TRAN 
    
    --Delete the source DacInstance first
    EXEC dbo.sp_sysdac_delete_instance @instance_id = @instance_id
    
    --Update the new version DacInstance metadata with the original DacInstance
    UPDATE [dbo].[sysdac_instances_internal]
    SET instance_id   = @instance_id, 
        instance_name = @instance_name
    WHERE instance_id = @source_instance_id

    COMMIT
    
    SELECT @retval = @@error
    RETURN(@retval)
END

GO
