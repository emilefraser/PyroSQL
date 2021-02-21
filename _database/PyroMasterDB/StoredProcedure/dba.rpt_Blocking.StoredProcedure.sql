SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[rpt_Blocking]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[rpt_Blocking] AS' 
END
GO

ALTER PROC [dba].[rpt_Blocking] (@DateRangeInDays INT)
AS

BEGIN

SELECT 
DateStamp,
[DBName],
Blocked_Waittime_Seconds AS [ElapsedTime(ss)],
Blocked_Spid AS VictimSPID,
Blocked_Login AS VictimLogin,
Blocked_SQL_Text AS Victim_SQL,
Blocking_Spid AS BlockerSPID,
Offending_Login AS BlockerLogin,
Offending_SQL_Text AS Blocker_SQL
FROM dba.BlockingHistory (nolock)
WHERE (DATEDIFF(dd,DateStamp,GETDATE())) <= @DateRangeInDays
ORDER BY DateStamp DESC

END
GO
