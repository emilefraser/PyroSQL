SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysdac_add_history_entry]  
    @sequence_id int,
    @instance_id UniqueIdentifier = NULL,
    @action_type tinyint = NULL,
    @action_status tinyint = NULL,
    @dac_object_type tinyint = NULL,
    @required bit = NULL,
    @dac_object_name_pretran sysname = N'',
    @dac_object_name_posttran sysname = N'',
    @sqlscript nvarchar(max) = N'',
    @payload varbinary(max) = NULL,
    @comments varchar(max) = N'',
    @error_string nvarchar(max) = N'',
    @action_id int = NULL OUTPUT
AS  
SET NOCOUNT ON;
BEGIN  
    DECLARE @retval INT  

    DECLARE @null_column sysname    
    SET @null_column = NULL

    IF (@instance_id IS NULL)
        SET @null_column = '@instance_id'
    ELSE IF (@action_type IS NULL)
        SET @null_column = '@action_type'
    ELSE IF (@action_status IS NULL)
        SET @null_column = '@action_status'
    ELSE IF (@dac_object_type IS NULL)
        SET @null_column = '@dac_object_type'
    ELSE IF (@required IS NULL)
        SET @null_column = '@required'

    IF @null_column IS NOT NULL
    BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_sysdac_add_history_entry')
        RETURN(1)
    END

    -- comments is optional. make sure it is non-null
    IF (@comments IS NULL)
    BEGIN
        SET @comments = N''
    END

    --- Ensure the user is either a db_creator or that the package being referred is visible via the package view. 
    --- For non-dbcreators, the package will only be visible if we are the associated dbo or sysadmin and the instance row exists
    IF ((dbo.fn_sysdac_is_dac_creator() != 1) AND
         (NOT EXISTS (SELECT * from dbo.sysdac_instances WHERE instance_id = @instance_id)))
    BEGIN
        RAISERROR(36004, -1, -1)
        RETURN(1)
    END
    
    BEGIN TRAN

    --If the action_id value is not set by the user, this is a new entry and the proc
    --should calculate the next value which is one more than the current max
    IF (@action_id IS NULL)
    BEGIN
        SET @action_id = (
            SELECT ISNULL(MAX(action_id) + 1, 0) 
            FROM dbo.sysdac_history_internal WITH (UPDLOCK, HOLDLOCK))        
    END

    INSERT INTO [dbo].[sysdac_history_internal]
        (action_id, sequence_id, instance_id, action_type, dac_object_type, action_status, required,
         dac_object_name_pretran, dac_object_name_posttran, sqlscript, payload, comments, error_string)
    VALUES
        (@action_id, @sequence_id, @instance_id, @action_type, @dac_object_type, @action_status, @required,
         @dac_object_name_pretran, @dac_object_name_posttran, @sqlscript, @payload, @comments, @error_string)

    COMMIT
    
    
    SELECT @retval = @@error
    RETURN(@retval)
END

GO
