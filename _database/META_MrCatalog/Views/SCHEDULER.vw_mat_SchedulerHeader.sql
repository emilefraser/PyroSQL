SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [SCHEDULER].[vw_mat_SchedulerHeader] AS
SELECT 
SchedulerHeaderID AS [Scheduler Header ID],
ETLLoadConfigID AS [ETL Load Config ID],
ScheduleExecutionIntervalMinutes AS [Schedule Execution Interval Minutes],
ScheduleExecutionTime AS [Schedule Execution Time],
IsActive AS [Is Active],
CreatedDT AS [Created Date],
UpdatedDT AS [Updated Date]
FROM [SCHEDULER].[SchedulerHeader]

GO
