SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[rpt_Queries]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[rpt_Queries] AS' 
END
GO

ALTER PROC [dba].[rpt_Queries] (@DateRangeInDays INT)
AS

BEGIN

DECLARE @QueryValue INT

SELECT @QueryValue = CAST(Value AS INT) FROM dba.AlertSettings WHERE VariableName = 'QueryValue' AND AlertName = 'LongRunningQueries'

SELECT
DateStamp AS DateStamp,
CAST(DATEDIFF(ss,Start_Time,DateStamp) AS INT) AS [ElapsedTime(ss)],
Session_ID AS Session_ID,
[DBName] AS [DBName],	
Login_Name AS Login_Name,
Formatted_SQL_Text AS SQL_Text
FROM dba.QueryHistory (nolock) 
WHERE (DATEDIFF(ss,Start_Time,DateStamp)) >= @QueryValue 
AND (DATEDIFF(dd,DateStamp,GETDATE())) <= @DateRangeInDays
AND [DBName] NOT IN (SELECT [DBName] FROM dba.DatabaseSettings WHERE LongQueryAlerts = 0)
AND Formatted_SQL_Text NOT LIKE '%BACKUP DATABASE%'
AND Formatted_SQL_Text NOT LIKE '%RESTORE VERIFYONLY%'
AND Formatted_SQL_Text NOT LIKE '%ALTER INDEX%'
AND Formatted_SQL_Text NOT LIKE '%DECLARE @BlobEater%'
AND Formatted_SQL_Text NOT LIKE '%DBCC%'
AND Formatted_SQL_Text NOT LIKE '%WAITFOR(RECEIVE%'
ORDER BY DateStamp DESC

END
GO
