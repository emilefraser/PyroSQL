SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [ETL].[vw_rpt_ETLBatchMonitoring]
AS
SELECT	etlreg.ETL_ID
		, etlreg.ETLDescription
		, etlbatch.ETLStepID
		, etlstep.StepDescription
		, etlstep.StepExecutionOrder
		, etlbatch.[BatchID]
		, etlbatch.[ExecutionStartDate]
		, etlbatch.[ExecutionEndDate]
		, CONVERT(time, etlbatch.[ExecutionEndDate] - etlbatch.[ExecutionStartDate]) as ExecutionDuration
		, etlbatch.[ExecutionStatus]
		, etlbatch.PackageName
		, etlbatch.[TransferRowCount]
		, CASE WHEN LastExecutionDate.PackageName IS NOT NULL
			THEN 'Yes'
			ELSE 'No'
		  END AS swIsLastExecution
FROM	[ETL].[ETLBatchControl] etlbatch
	left join	
				(
					SELECT	PackageName
							, MAX(ExecutionEndDate) AS LastExecutionDate
					FROM	[ETL].[ETLBatchControl] etlbatch
					GROUP BY PackageName
				) LastExecutionDate on etlbatch.PackageName = LastExecutionDate.PackageName
					and etlbatch.ExecutionEndDate = LastExecutionDate.LastExecutionDate
	left join ETL.ETLSteps etlstep on etlstep.ETLStepID = etlbatch.ETLStepID
	left join ETL.ETLRegister etlreg on etlreg.ETL_ID = etlstep.ETLID

GO
