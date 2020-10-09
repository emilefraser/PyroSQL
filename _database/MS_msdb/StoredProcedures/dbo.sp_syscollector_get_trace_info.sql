SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_get_trace_info]
    @trace_path  nvarchar(512),
    @use_default int
AS
BEGIN
    SELECT 
        CONVERT(nvarchar(30), t.start_time, 126) as start_time,
        CASE t.status 
            WHEN 1 THEN 1 
            ELSE 0 
        END AS is_running, 
        ISNULL(t.dropped_event_count,0) as dropped_event_count,
        t.id
    FROM sys.traces t
    WHERE (@use_default=1 and t.is_default=1)
          OR (@use_default=0 AND t.path LIKE (@trace_path + N'%.trc'))
END

GO
