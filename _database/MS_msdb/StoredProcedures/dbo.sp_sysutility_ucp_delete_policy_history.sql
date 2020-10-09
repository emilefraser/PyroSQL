SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE dbo.sp_sysutility_ucp_delete_policy_history 
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON; 
    
    DECLARE @over_utilization_trailing_window INT = 1
    DECLARE @under_utilization_trailing_window INT = 1

    DECLARE @rows_affected bigint;
    DECLARE @delete_batch_size int;

    -- As we delete the master record in the history table which cascades
    -- to foreign key records in details table; keep the delete batch size to 100.
    SET @delete_batch_size = 100;
    SET @rows_affected = -1;

    -- Get the configured over utilization trailing window
    SELECT @over_utilization_trailing_window = CAST(ci.current_value AS INT)
    FROM msdb.dbo.sysutility_ucp_configuration_internal ci
    WHERE ci.name = 'OverUtilizationTrailingWindow'

    -- Get the configured under utilization trailing window
    SELECT @under_utilization_trailing_window = CAST(ci.current_value AS INT)
    FROM msdb.dbo.sysutility_ucp_configuration_internal ci
    WHERE ci.name = 'UnderUtilizationTrailingWindow'

    -- Purge volatile resource policy evaluation history against over utilization trailing window
    DECLARE @max_end_date datetime;
    SET @max_end_date = DATEADD(HH, -@over_utilization_trailing_window, CURRENT_TIMESTAMP);
    SET @rows_affected = -1;
    WHILE (@rows_affected != 0)
    BEGIN
        -- We use sp_executesql here because the values of @delete_batch_size and @max_end_date could 
        -- influence plan selection. These are variables that have unknown values when the plan for the 
        -- proc is compiled.  By deferring compilation until the variables have taken on their final values, 
        -- we give the optimizer information that it needs to choose the best possible plan.  We could also 
        -- use an OPTION(RECOMPILE) hint to accomplish the same thing, but the sp_executesql approach avoids 
        -- paying the plan compile cost for each loop iteration. 
        EXEC sp_executesql N'
            DELETE TOP (@delete_batch_size) h
            FROM msdb.dbo.syspolicy_policy_execution_history_internal h
            INNER JOIN msdb.dbo.sysutility_ucp_policies p ON p.policy_id = h.policy_id
            WHERE p.resource_type = 3        -- processor resource type
                AND p.utilization_type = 2   -- over-utilization
                AND h.end_date < @max_end_date', 

            N'@delete_batch_size int, @max_end_date datetime', 
            @delete_batch_size = @delete_batch_size, @max_end_date = @max_end_date;

        SET @rows_affected = @@ROWCOUNT;
    END;
    
    -- Purge volatile resource policy evaluation history against under utilization trailing window
    SET @max_end_date = DATEADD(HH, -@under_utilization_trailing_window, CURRENT_TIMESTAMP);
    SET @rows_affected = -1;
    WHILE (@rows_affected != 0)
    BEGIN    
        EXEC sp_executesql N'
            DELETE TOP (@delete_batch_size) h
            FROM msdb.dbo.syspolicy_policy_execution_history_internal h
            INNER JOIN msdb.dbo.sysutility_ucp_policies p ON p.policy_id = h.policy_id
            WHERE p.resource_type = 3        -- processor resource type
                AND p.utilization_type = 1   -- under-utilization
                AND h.end_date < @max_end_date', 

            N'@delete_batch_size int, @max_end_date datetime', 
            @delete_batch_size = @delete_batch_size, @max_end_date = @max_end_date;

        SET @rows_affected = @@ROWCOUNT;
    END;
    
    -- Purge non-volatile resource policy evaluation history older than the current processing_time recorded 
    -- The latest policy evaluation results are not purged to avoid potential conflicts with the health 
    -- state computation running simultaneoulsy in the caching (master) job during the same time schedule. 
    SET @rows_affected = -1;
    -- PBM stores the end_date in local time so convert the 'latest_processing_time' datetimeoffset to a local datetime
    SELECT @max_end_date = CONVERT(DATETIME, latest_processing_time) FROM [msdb].[dbo].[sysutility_ucp_processing_state_internal];
    WHILE (@rows_affected != 0)
    BEGIN     
        EXEC sp_executesql N'
            DELETE TOP (@delete_batch_size) h
            FROM msdb.dbo.syspolicy_policy_execution_history_internal h
            INNER JOIN msdb.dbo.sysutility_ucp_policies p ON p.policy_id = h.policy_id
            WHERE p.resource_type = 1    -- storage space resource type
                AND h.end_date < @max_end_date', 

            N'@delete_batch_size int, @max_end_date datetime',  
            @delete_batch_size = @delete_batch_size, @max_end_date = @max_end_date; 
            
        SET @rows_affected = @@ROWCOUNT;
    END;            
    
END

GO
