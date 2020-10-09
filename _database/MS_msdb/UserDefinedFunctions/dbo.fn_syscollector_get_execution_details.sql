SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_syscollector_get_execution_details] 
(
     @log_id                BIGINT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (100) PERCENT
        l.source,
        l.event,
        l.message,
        l.starttime AS start_time,
        l.endtime AS finish_time,
        l.datacode,
        l.databytes
    FROM sysssislog l
    JOIN dbo.syscollector_execution_log e ON (e.package_execution_id = l.executionid)
    WHERE e.log_id = @log_id
    ORDER BY l.starttime
)

GO
