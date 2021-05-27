SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE [PERFMASTER].[sp_Update_MetricsLog]
	@LogID INT
AS

	SELECT 0
/*

CREATE TABLE [dbo].[TableRowStats](
[RecID] [int] IDENTITY(1,1) NOT NULL,
[SQLInstanceName] [varchar](200) NULL,
[DbName] [varchar](100) NULL,
[TableName] [varchar](100) NULL,
[ObjId] [bigint] NULL,
[IndId] [int] NULL,
[IndName] [varchar](200) NULL,
[RowCnt] [bigint] NULL,
[DateInserted] [datetime] NULL CONSTRAINT [DF_IndexRowStats_DateInserted] DEFAULT (getdate()),
CONSTRAINT [PK_IndexRowStats] PRIMARY KEY CLUSTERED ([RecID] ASC)) 
GO

CREATE PROCEDURE [dbo].[GetRowCounts]
@MinRows int=1,
@vDbName varchar(200)
AS
IF EXISTS (Select 1 FROM tempdb.sys.objects where name='##IndList')
 DROP TABLE ##IndList
Declare @SqlStr varchar(max)=N'
SELECT SO.Name as TableName,SI.id as ObjId,indid,SI.name as IndName ,rowcnt 
 INTO ##IndList
 FROM '+@vDbName +'.sys.sysindexes (nolock) SI 
  JOIN '+@vDbName +'.sys.sysobjects (nolock) SO ON SI.id=So.id
  WHERE SO.TYPE =''U'' AND Indid <2 and rowcnt >'+RTRIM(STR(@MinRows))
EXEC (@SqlStr) 
MERGE TableRowStats RS
USING ##IndList I ON RS.SQLInstanceName=@@SERVERNAME AND RS.DbName=@vDbName 
 AND RS.ObjId=I.ObjId AND RS.IndId=I.Indid
 WHEN MATCHED THEN
UPDATE Set RS.RowCnt=I.RowCnt
WHEN NOT MATCHED THEN
INSERT (SQLInstanceName,DbName,TableName,ObjId,IndId,IndName,RowCnt)
VALUES(@@SERVERNAME,@vDbName,I.TableName,I.ObjId,I.IndId,I.IndName,I.RowCnt);
GO;


ALTER PROCEDURE [dbo].[CollectPerfStats]
@DbList varchar(200),
@GetQueryStats bit=1,
@TopN int,
@OrderBy varchar(200) ='TotalElapsedTime_MSec',
@FilterStr varchar(max) =NULL,
@CollectStatsInfo bit=0,
@GetWaitStats bit=0
AS
IF @GetQueryStats=1 
 EXEC [CollectQueryStats] @vTopNRows=@TopN,@vDbList=@DbList,@vOrderBy=@OrderBy,@vFilterStr=@FilterStr,@vCollectStatsInfo=@CollectStatsInfo;
IF @GetWaitStats=1 exec GetWaitStats 10,5;
EXEC [dbo].[GetRowCounts] 1,@DbList;
GO


USE [PerfStats]
GO

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
4 - On the central server execute the following script to enable XML indexes on the QueryPlan table:

USE [PerfStats]
GO

ALTER INDEX [PXML_QueryPlans] ON [dbo].[QueryPlans] REBUILD 
ALTER INDEX [IXML_QueryPlans_Path] ON [dbo].[QueryPlans] REBUILD 
ALTER INDEX [IXML_QueryPlans_Value] ON [dbo].[QueryPlans] REBUILD 
GO


					--System info – 
					select * from sys.dm_os_performance_counters
					select * from sys.dm_os_wait_stats
					--Query info – sys.dm_exec_requests
					select * from  sys.dm_exec_requests
					--Index info – sys.dm_db_index_usage_stats, sys.dm_io_virtual_file_stats
					select * from sys.dm_db_index_usage_stats
					select * from sys.dm_io_virtual_file_stats
*/

GO
