SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysdac_update_history_entry]
    @action_id int,
    @instance_id UniqueIdentifier = NULL,
    @action_type tinyint = NULL,
    @dac_object_type tinyint = NULL,
    @action_status tinyint = NULL,
    @dac_object_name_pretran sysname = N'',
    @dac_object_name_posttran sysname = N'',
    @sqlscript nvarchar(max) = N'',
    @error_string nvarchar(max) = N''
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
    ELSE IF (@dac_object_type IS NULL)
        SET @null_column = '@dac_object_type'
    ELSE IF (@action_status IS NULL) --action_status should be non-pending (success/failure)
        SET @null_column = '@action_status'

    IF @null_column IS NOT NULL
    BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_sysdac_update_history_entry')
        RETURN(1)
    END
     
    -- Only allow users who created history entry or 'sysadmins' to update the row
    DECLARE @username SYSNAME
    SET @username = (SELECT created_by 
                     FROM dbo.sysdac_history_internal 
                     WHERE instance_id              = @instance_id AND 
                           action_id                = @action_id AND 
                           action_type              = @action_type AND
                           dac_object_type          = @dac_object_type AND
                           dac_object_name_pretran  = @dac_object_name_pretran AND
                           dac_object_name_posttran = @dac_object_name_posttran)

    IF ((@username != [dbo].[fn_sysdac_get_currentusername]()) AND ([dbo].[fn_sysdac_is_currentuser_sa]() != 1))
    BEGIN
        RAISERROR(36011, -1, -1);
        RETURN(1); -- failure
    END

    UPDATE [dbo].[sysdac_history_internal] 
    SET            
                action_status           = @action_status,
                sqlscript               = @sqlscript,
                error_string            = @error_string,
                date_modified           = (SELECT GETDATE()) 
    WHERE
                action_id               = @action_id AND
                action_type             = @action_type AND
                dac_object_type         = @dac_object_type AND
                dac_object_name_pretran = @dac_object_name_pretran AND
                dac_object_name_posttran = @dac_object_name_posttran
    
    SELECT @retval = @@error
    RETURN(@retval)
END

GO
