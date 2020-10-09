SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_delete_policy] 
@name sysname = NULL,
@policy_id int = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

	DECLARE @retval              INT

    EXEC @retval = sp_syspolicy_verify_policy_identifiers @name, @policy_id OUTPUT
    IF (@retval <> 0)
        RETURN (1)

    DELETE msdb.dbo.syspolicy_policies_internal 
        WHERE policy_id = @policy_id

    RETURN (0)
END

GO
