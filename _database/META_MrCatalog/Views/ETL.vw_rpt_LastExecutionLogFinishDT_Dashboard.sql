SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON





CREATE VIEW [ETL].[vw_rpt_LastExecutionLogFinishDT_Dashboard] AS

SELECT	ExecutionLogID
		, el1.DatabaseName
		, el1.SchemaName
		, el1.DataEntityName
		, i.LoadConfigID
		, Result as LastLoadStatus
		, k.LoadTypeName
		, i.FinishDT as LastFinishDT
		, DATEDIFF(second, el1.startdt, el1.finishdt) AS LastLoadDuration
		, j.LastWeekAverageDuration
		, g.TotalAverageDuration
		, v.StandardDev AS WeekStandardDev
		, k.StandardDEV AS TotalStandardDev
		, v.LoadsPerWeek as LoadsInLastWeek
		, k.TotalLoads as TotalLoads
         ,CASE
		             WHEN(v.StandardDev + j.LastWeekAverageDuration) > DATEDIFF(second, el1.startdt, el1.finishdt) 
					      AND DATEDIFF(second, el1.startdt, el1.finishdt)> (j.LastWeekAverageDuration - v.StandardDev) THEN 'AVERAGE'
                     WHEN (v.StandardDev + j.LastWeekAverageDuration) < DATEDIFF(second, el1.startdt, el1.finishdt) THEN 'SLOWER'
					 WHEN (j.LastWeekAverageDuration - v.StandardDev) > DATEDIFF(second, el1.startdt, el1.finishdt) THEN 'FASTER'
					 ELSE 'NULL'
	       END AS LastLoadSpeedWeek
		,  CASE
		             WHEN(k.StandardDEV + g.TotalAverageDuration) > DATEDIFF(second, el1.startdt, el1.finishdt) 
					      AND DATEDIFF(second, el1.startdt, el1.finishdt)> (g.TotalAverageDuration - k.StandardDEV) THEN 'AVERAGE'
                     WHEN (k.StandardDEV + g.TotalAverageDuration) < DATEDIFF(second, el1.startdt, el1.finishdt) THEN 'SLOWER'
					 WHEN (g.TotalAverageDuration - k.StandardDEV) > DATEDIFF(second, el1.startdt, el1.finishdt) THEN 'FASTER'
					 ELSE 'NULL'
	       END AS LastLoadSpeedTotal
         ,	CASE
		            WHEN q.LastFailedDT >= dateadd(DAY,-1, GETDATE()) THEN 1
					ELSE 0
			END AS FailedInLast24Hr
         , q.LastFailedDT
		 ,lc.QueuedForProcessingDT


from	etl.executionlog el1 
	INNER JOIN
				(
					select	LoadConfigID
							, MAX(FinishDT) as FinishDT
					from	etl.executionlog 
					GROUP BY loadconfigid
				) 
	i ON el1.FinishDT = i.FinishDT
	LEFT JOIN
	           (
			        SELECT LoadConfigID, AVG(DurationSeconds) as LastWeekAverageDuration
                    FROM etl.vw_rpt_executionlog_Dashboard
                    WHERE FinishDT >= dateadd(DAY,-7, GETDATE())
                    GROUP BY LoadConfigID
			   ) j ON j.LoadConfigID = i.LoadConfigID
    LEFT JOIN
	           (
                    SELECT LoadConfigID, AVG(DurationSeconds) as TotalAverageDuration
                    FROM etl.vw_rpt_executionlog_Dashboard
                    GROUP BY LoadConfigID
			   ) g ON g.LoadConfigID = i.LoadConfigID
    LEFT JOIN
	           (
                    SELECT LoadConfigID, STDEV(DurationSeconds) as StandardDEV, COUNT(1) AS TotalLoads, loadtypename
                    FROM etl.vw_rpt_executionlog_Dashboard
                    GROUP BY LoadConfigID,loadtypename  --double check that this doesnt affect result by doing screenshot test
			   ) k ON k.LoadConfigID = i.LoadConfigID
    LEFT JOIN
	           (
                    SELECT LoadConfigID, STDEV(DurationSeconds) as StandardDEV, COUNT(1) AS LoadsPerWeek
                    FROM etl.vw_rpt_executionlog_Dashboard
					WHERE FinishDT >= dateadd(DAY,-7, GETDATE())
                    GROUP BY LoadConfigID
			   ) v ON v.LoadConfigID = i.LoadConfigID
	LEFT JOIN
				(
					select	LoadConfigID
							, MAX(FinishDT) as LastFailedDT
					from	etl.executionlog 
					WHERE IsError = 1
					GROUP BY loadconfigid
				) q ON q.LoadConfigID = i.LoadConfigID
    LEFT JOIN ETL.LoadControl lc 
	ON lc.LoadConfigID = el1.LoadConfigID


GO
