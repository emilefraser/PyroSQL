SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_add_target_set_level] 
@target_set_id int,
@type_skeleton nvarchar(max),
@condition_id int = NULL,
@condition_name sysname = NULL,
@level_name sysname,
@target_set_level_id int OUTPUT
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

	DECLARE @retval              INT

    IF NOT EXISTS (SELECT * FROM syspolicy_target_sets WHERE target_set_id = @target_set_id)
            RETURN (1)

    IF (@condition_name = '')
        SET @condition_name = NULL

    IF(@condition_id IS NOT NULL or @condition_name IS NOT NULL)
    BEGIN
        EXEC @retval = msdb.dbo.sp_syspolicy_verify_condition_identifiers @condition_name = @condition_name OUTPUT, @condition_id = @condition_id OUTPUT
        IF (@retval <> 0)
            RETURN (1)
    END

    
    INSERT INTO msdb.[dbo].[syspolicy_target_set_levels_internal]
                                        (target_set_id,
                                        type_skeleton,
                                        condition_id,
                                        level_name)
    VALUES                            
                                        (@target_set_id,
                                        @type_skeleton,
                                        @condition_id,
                                        @level_name)

    SELECT @retval = @@error
    SET @target_set_level_id = SCOPE_IDENTITY()
    RETURN(@retval)
END

GO
