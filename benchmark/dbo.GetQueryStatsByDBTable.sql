SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE GetQueryStatsByDBTable
@DbName varchar(200),
@TableName varchar(200),
@MinSubtreeCost decimal (10,2)=0,
@MinPlans int=1
AS 
DECLARE @vTableName AS NVARCHAR(200) =QUOTENAME(@TableName)
;WITH XMLNAMESPACES 
(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
,QueryStatsCTE As (
SELECT [SQLInstanceName]
,[DbName]
,Left([ParentQueryTxt],200) as ParentQueryTxt
,LEFT([QueryTxt],200) as QueryTxt
,[TotalElapsedTime_Msec]
,[MaxElapsedTime_Msec]
,[MinElapsedTime_Msec]
,[Avg_elapsedTime_Msec]
,[TotalWorkerTime_Msec]
,[MaxWorkerTime_Msec]
,[MinWorkerTime_Msec]
,[Avg_WorkerTime_Msec]
,[TotalLogicalReads]
,[MaxLogicalReads]
,[MinLogicalReads]
,[Avg_Logical_Reads]
,[ExecutionCount]
,[QueryHash]
,[PlanHash]
,cast(CollectionDateTime as date) as CollectionDateTime
,stmt.value('(@StatementSubTreeCost)[1]', 'decimal(10,2)') AS SubtreeCost
FROM [dbo].[vQueryStats_Plans] (NOLOCK) cp 
CROSS APPLY cp.queryplan.nodes('//ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple[@QueryHash=sql:column("QueryHash")]') AS batch(stmt)
CROSS APPLY stmt.nodes('//Object[@Table=sql:variable("@vTableName")]') AS vObj(obj) 
WHERE DbName=@DbName AND QueryHash IN (Select QueryHash FROM [dbo].vQueryStats_Plans 
GROUP BY QueryHash HAVING COUNT(1)>=@MinPlans)
)
SELECT * from QueryStatsCTE QS Where SubtreeCost >=@MinSubtreeCost ORDER BY SubtreeCost Desc ;

GO
