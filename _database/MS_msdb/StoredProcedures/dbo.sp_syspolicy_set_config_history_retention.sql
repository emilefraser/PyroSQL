SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_set_config_history_retention] 
	@value sql_variant
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

    UPDATE [msdb].[dbo].[syspolicy_configuration_internal]
        SET current_value = @value
        WHERE name = N'HistoryRetentionInDays';
    
END

GO
