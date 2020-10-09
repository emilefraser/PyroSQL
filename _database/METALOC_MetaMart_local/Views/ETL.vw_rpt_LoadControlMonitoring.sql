SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [ETL].[vw_rpt_LoadControlMonitoring]
AS 

select	lc.LoadConfigID
		
		, lc.SourceServerName
		, lc.SourceDatabaseName
		, lc.SourceSchemaName
		, lc.SourceDataEntityName

		, lc.TargetServerName
		, lc.TargetDatabaseName
		, lc.TargetSchemaName
		, lc.TargetDataEntityName
		
		, lc.LoadType
		, lc.IsSetForReloadOnNextRun

		, sch.IsActive
		, sch.ScheduleExecutionIntervalMinutes
		, sch.ScheduleExecutionTime

		, lctrl.QueuedForProcessingDT
		, lctrl.ProcessingStartDT
		, lctrl.ProcessingFinishedDT
		, ISNULL(lctrl.IsLastRunFailed, 0) AS IsLastRunFailed
		, lctrl.ProcessingState
		, lctrl.NextScheduledRunTime

		, loadevent.EventDT
		, loadevent.EventDescription
		, loadevent.ErrorMessage

		, lasterror.LastErrorEventDT
		, lasterror.LastErrorEventDescription
		, lasterror.LastErrorMessage
from	ETL.LoadConfig lc
	inner join ETL.LoadControl lctrl on lc.LoadConfigID = lctrl.LoadConfigID
	left join 
				(
					select	lev.LoadControlID
							, lev.EventDT
							, lev.EventDescription
							, ISNULL(lev.ErrorMessage, '') AS ErrorMessage
					from	ETL.LoadControlEventLog lev
						inner join 
									(
										select	LoadControlID, MAX(EventDT) as LastEventDT
										from	ETL.LoadControlEventLog lev
										group by LoadControlID
									)LastEvent on lev.LoadControlID = LastEvent.LoadControlID
										and lev.EventDT = LastEvent.LastEventDT
				)loadevent on loadevent.LoadControlID = lctrl.LoadControlID
	left join 
				(
					select	lev.LoadControlID
							, lev.EventDT as LastErrorEventDT
							, lev.EventDescription as LastErrorEventDescription
							, ISNULL(lev.ErrorMessage, '') AS LastErrorMessage
					from	ETL.LoadControlEventLog lev
						inner join 
									(
										select	LoadControlID, MAX(EventDT) as LastEventDT
										from	ETL.LoadControlEventLog lev
										where	lev.EventDescription like '%error%'
										group by LoadControlID
									)LastEvent on lev.LoadControlID = LastEvent.LoadControlID
										and lev.EventDT = LastEvent.LastEventDT	
				)lasterror on lasterror.LoadControlID = lctrl.LoadControlID
	left join SCHEDULER.SchedulerHeader sch on sch.ETLLoadConfigID = lc.LoadConfigID

GO
