SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [INTEGRATION].[vw_egress_ETL_Schedule_ScheduleHeader]
AS

SELECT	[SchedulerHeaderID]
		, [ETLLoadConfigID]
		, [ScheduleExecutionIntervalMinutes]
		, [ScheduleExecutionTime]
		, [IsActive]
		, [CreatedDT]
		, [UpdatedDT]
FROM	[SCHEDULER].[SchedulerHeader]


GO
