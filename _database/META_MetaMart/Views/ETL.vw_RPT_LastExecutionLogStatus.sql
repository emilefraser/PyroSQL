SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [ETL].[vw_RPT_LastExecutionLogStatus] AS

SELECT ExecutionLogID, i.* from etl.executionlog el1 inner join
(select LoadConfigID, MAX(FinishDT) as FinishDT
from etl.executionlog 
GROUP BY loadconfigid) i on el1.FinishDT = i.FinishDT



GO
