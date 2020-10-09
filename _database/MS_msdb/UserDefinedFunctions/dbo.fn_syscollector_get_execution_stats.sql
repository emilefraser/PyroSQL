SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION [dbo].[fn_syscollector_get_execution_stats] 
(
     @log_id                BIGINT
) 
RETURNS TABLE
AS
RETURN
(
    SELECT 
        log_id,
        task_name,
        AVG(execution_row_count_in) AS avg_row_count_in,
        MIN(execution_row_count_in) AS min_row_count_in,
        MAX(execution_row_count_in) AS max_row_count_in,
        AVG(execution_row_count_out) AS avg_row_count_out,
        MIN(execution_row_count_out) AS min_row_count_out,
        MAX(execution_row_count_out) AS max_row_count_out,
        AVG(execution_row_count_errors) AS avg_row_count_errors,
        MIN(execution_row_count_errors) AS min_row_count_errors,
        MAX(execution_row_count_errors) AS max_row_count_errors,
        AVG(execution_time_ms) AS avg_duration,
        MIN(execution_time_ms) AS min_duration,
        MAX(execution_time_ms) AS max_duration
    FROM dbo.syscollector_execution_stats
    WHERE log_id = @log_id
    GROUP BY log_id, task_name
)

GO
