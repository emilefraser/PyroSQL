SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [ETL].[vw_mat_ETLBatchMonitoring]
AS
SELECT	[ETL_ID] AS [ETL ID]
		,[ETLDescription] AS [ETL Description]
		,[ETLStepID] AS [ETL Step ID]
		,[StepDescription] AS [Step Description]
		,[StepExecutionOrder] AS [Step Execution Order]
		,[BatchID] AS [Batch ID]
		,[ExecutionStartDate] AS [Execution Start Date]
		,[ExecutionEndDate] AS [Execution End Date]
		,[ExecutionDuration] AS [Execution Duration]
		,[ExecutionStatus] AS [Execution Status]
		,[PackageName] AS [Package Name]
		,[TransferRowCount] AS [Transfer Row Count]
		,[swIsLastExecution] AS [IsLast Execution]
FROM	[ETL].[vw_rpt_ETLBatchMonitoring]



GO
