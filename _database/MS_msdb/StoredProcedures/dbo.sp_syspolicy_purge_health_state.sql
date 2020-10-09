SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_purge_health_state]
    @target_tree_root_with_id nvarchar(400) = NULL
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole';
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check;
	END
	
	IF (@target_tree_root_with_id IS NULL)
	BEGIN
	    DELETE FROM msdb.dbo.syspolicy_system_health_state_internal;
	END
	ELSE
	BEGIN
	    DECLARE @target_mask nvarchar(801);
	    SET @target_mask = @target_tree_root_with_id;
	    -- we need to escape all the characters that can be part of the 
	    -- LIKE pattern
	    SET @target_mask = REPLACE(@target_mask, '[', '\[');
	    SET @target_mask = REPLACE(@target_mask, ']', '\]');
	    SET @target_mask = REPLACE(@target_mask, '_', '\_');
	    SET @target_mask = REPLACE(@target_mask, '%', '\%');
	    SET @target_mask = @target_mask + '%';
	    DELETE FROM msdb.dbo.syspolicy_system_health_state_internal
	        WHERE target_query_expression_with_id LIKE @target_mask ESCAPE '\';
	END
	
	RETURN 0;
END

GO
