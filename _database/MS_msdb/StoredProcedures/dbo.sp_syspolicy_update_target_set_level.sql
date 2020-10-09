SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_update_target_set_level] 
@target_set_id int,
@type_skeleton nvarchar(max),
@condition_id int = NULL,
@condition_name sysname = NULL
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

	DECLARE @retval int

    IF @condition_name = '' SET @condition_name = NULL

    IF(@condition_id IS NOT NULL or @condition_name IS NOT NULL)
    BEGIN
        EXEC @retval = msdb.dbo.sp_syspolicy_verify_condition_identifiers @condition_name = @condition_name OUTPUT, @condition_id = @condition_id OUTPUT
        IF (@retval <> 0)
            RETURN (1)
    END

    UPDATE msdb.[dbo].[syspolicy_target_set_levels_internal] 
        SET condition_id = @condition_id
        WHERE target_set_id = @target_set_id AND type_skeleton = @type_skeleton
    
    IF (@@ROWCOUNT = 0)
    BEGIN
        DECLARE @id nvarchar(max)
        SET @id = '@target_set_id='+LTRIM(STR(@target_set_id))+' @type_skeleton='''+@type_skeleton+''''
        RAISERROR(14262, -1, -1, 'Target Set Level', @id)
        RETURN (1)
    END

    RETURN (0)
END

GO
