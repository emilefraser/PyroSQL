SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_purge_history] @include_system bit=0
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole';
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check;
	END

    DECLARE @retention_interval_in_days_variant sql_variant
    SET @retention_interval_in_days_variant = (SELECT current_value 
                                        FROM msdb.dbo.syspolicy_configuration
                                        WHERE name = N'HistoryRetentionInDays');
                                        
    DECLARE @retention_interval_in_days int;
    SET @retention_interval_in_days = CONVERT(int, @retention_interval_in_days_variant);
    
    IF( @retention_interval_in_days <= 0)
        RETURN 0;
	
	DECLARE @cutoff_date datetime;
	SET @cutoff_date = DATEADD(day, -@retention_interval_in_days, GETDATE());

    -- delete old policy history records
    BEGIN TRANSACTION
    
    DELETE d 
    FROM msdb.dbo.syspolicy_policy_execution_history_details_internal d
    INNER JOIN msdb.dbo.syspolicy_policy_execution_history_internal h ON d.history_id = h.history_id
    INNER JOIN msdb.dbo.syspolicy_policies p ON h.policy_id = p.policy_id
    WHERE h.end_date < @cutoff_date AND (p.is_system = 0 OR p.is_system = @include_system)
    
    DELETE h
    FROM msdb.dbo.syspolicy_policy_execution_history_internal h
    INNER JOIN msdb.dbo.syspolicy_policies p ON h.policy_id = p.policy_id
    WHERE h.end_date < @cutoff_date AND (p.is_system = 0 OR p.is_system = @include_system)
    
    COMMIT TRANSACTION
    
    -- delete policy subscriptions that refer to the nonexistent databases
    DELETE s
    FROM msdb.dbo.syspolicy_policy_category_subscriptions_internal s
    LEFT OUTER JOIN master.sys.databases d ON s.target_object = d.name
    WHERE s.target_type = 'DATABASE' AND d.database_id IS NULL
    
    RETURN 0;
END

GO
