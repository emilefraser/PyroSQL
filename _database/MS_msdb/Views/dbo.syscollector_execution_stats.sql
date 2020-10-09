SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [dbo].[syscollector_execution_stats] AS
    SELECT
        log_id,
        task_name,
        execution_row_count_in,
        execution_row_count_out,
        execution_row_count_errors,
        execution_time_ms,
        log_time
    FROM dbo.syscollector_execution_stats_internal

GO
