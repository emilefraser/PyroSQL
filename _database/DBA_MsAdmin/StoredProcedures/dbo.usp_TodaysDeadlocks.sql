SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON





CREATE PROC [dbo].[usp_TodaysDeadlocks]
AS
/**************************************************************************************************************
**  Purpose:
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  03/19/2013		Michael Rounds			1.0					Comments creation
**	05/15/2013		Matthew Monroe from SSC	1.1					Removed all SUM() potentially causing a conversion failure
**	07/23/2013		Michael Rounds			1.2					Tweaked to support Case-sensitive
***************************************************************************************************************/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #DEADLOCKINFO (
		DeadlockDate DATETIME,
		DBName NVARCHAR(128),	
		ProcessInfo NVARCHAR(50),
		VictimHostname NVARCHAR(128),
		VictimLogin NVARCHAR(128),	
		VictimSPID NVARCHAR(5),
		VictimSQL NVARCHAR(MAX),
		LockingHostname NVARCHAR(128),
		LockingLogin NVARCHAR(128),
		LockingSPID NVARCHAR(5),
		LockingSQL NVARCHAR(MAX)
		)

	CREATE TABLE #ERRORLOG (
		ID INT IDENTITY(1,1) NOT NULL,
		LogDate DATETIME, 
		ProcessInfo NVARCHAR(100), 
		[Text] NVARCHAR(4000),
		PRIMARY KEY (ID)
		)

	INSERT INTO #ERRORLOG
	EXEC sp_readerrorlog 0, 1

	CREATE TABLE #TEMPDATES (LogDate DATETIME)

	INSERT INTO #TEMPDATES (LogDate)
	SELECT DISTINCT CONVERT(NVARCHAR(30),LogDate,120) as LogDate
	FROM #ERRORLOG
	WHERE ProcessInfo LIKE 'spid%'
	and [Text] LIKE '   process id=%'

	INSERT INTO #DEADLOCKINFO (DeadLockDate, DBName, ProcessInfo, VictimHostname, VictimLogin, VictimSPID, LockingHostname, LockingLogin, LockingSPID)
	SELECT 
	DISTINCT CONVERT(NVARCHAR(30),b.LogDate,120) AS DeadlockDate,
	DB_NAME(SUBSTRING(RTRIM(SUBSTRING(b.[Text],PATINDEX('%currentdb=%',b.[Text]),(PATINDEX('%lockTimeout%',b.[Text])) - (PATINDEX('%currentdb=%',b.[Text]))  )),11,50)) as DBName,
	b.processinfo,
	SUBSTRING(RTRIM(SUBSTRING(a.[Text],PATINDEX('%hostname=%',a.[Text]),(PATINDEX('%hostpid%',a.[Text])) - (PATINDEX('%hostname=%',a.[Text]))  )),10,50)
		AS VictimHostname,
	CASE WHEN SUBSTRING(RTRIM(SUBSTRING(a.[Text],PATINDEX('%loginname=%',a.[Text]),(PATINDEX('%isolationlevel%',a.[Text])) - (PATINDEX('%loginname=%',a.[Text]))  )),11,50) NOT LIKE '%id%'
		THEN SUBSTRING(RTRIM(SUBSTRING(a.[Text],PATINDEX('%loginname=%',a.[Text]),(PATINDEX('%isolationlevel%',a.[Text])) - (PATINDEX('%loginname=%',a.[Text]))  )),11,50)
		ELSE NULL END AS VictimLogin,
	CASE WHEN SUBSTRING(RTRIM(SUBSTRING(a.[Text],PATINDEX('%spid=%',a.[Text]),(PATINDEX('%sbid%',a.[Text])) - (PATINDEX('%spid=%',a.[Text]))  )),6,10) NOT LIKE '%id%'
		THEN SUBSTRING(RTRIM(SUBSTRING(a.[Text],PATINDEX('%spid=%',a.[Text]),(PATINDEX('%sbid%',a.[Text])) - (PATINDEX('%spid=%',a.[Text]))  )),6,10)
		ELSE NULL END AS VictimSPID,
	SUBSTRING(RTRIM(SUBSTRING(b.[Text],PATINDEX('%hostname=%',b.[Text]),(PATINDEX('%hostpid%',b.[Text])) - (PATINDEX('%hostname=%',b.[Text]))  )),10,50)
		AS LockingHostname,
	CASE WHEN SUBSTRING(RTRIM(SUBSTRING(b.[Text],PATINDEX('%loginname=%',b.[Text]),(PATINDEX('%isolationlevel%',b.[Text])) - (PATINDEX('%loginname=%',b.[Text]))  )),11,50) NOT LIKE '%id%'
		THEN SUBSTRING(RTRIM(SUBSTRING(b.[Text],PATINDEX('%loginname=%',b.[Text]),(PATINDEX('%isolationlevel%',b.[Text])) - (PATINDEX('%loginname=%',b.[Text]))  )),11,50)
		ELSE NULL END AS LockingLogin,
	CASE WHEN SUBSTRING(RTRIM(SUBSTRING(b.[Text],PATINDEX('%spid=%',b.[Text]),(PATINDEX('%sbid=%',b.[Text])) - (PATINDEX('%spid=%',b.[Text]))  )),6,10) NOT LIKE '%id%'
		THEN SUBSTRING(RTRIM(SUBSTRING(b.[Text],PATINDEX('%spid=%',b.[Text]),(PATINDEX('%sbid=%',b.[Text])) - (PATINDEX('%spid=%',b.[Text]))  )),6,10)
		ELSE NULL END AS LockingSPID
	FROM #TEMPDATES t
	JOIN #ERRORLOG a
		ON CONVERT(NVARCHAR(30),t.LogDate,120) = CONVERT(NVARCHAR(30),a.LogDate,120)
	JOIN #ERRORLOG b
		ON CONVERT(NVARCHAR(30),t.LogDate,120) = CONVERT(NVARCHAR(30),b.LogDate,120) AND a.[Text] LIKE '   process id=%' AND b.[Text] LIKE '   process id=%' AND a.ID < b.ID 
	GROUP BY b.LogDate,b.processinfo, a.[Text], b.[Text]

	SELECT 
	DeadlockDate, 
	DBName, 
	CASE WHEN VictimLogin IS NOT NULL THEN VictimHostname ELSE NULL END AS VictimHostname, 
	VictimLogin, 
	CASE WHEN VictimLogin IS NOT NULL THEN VictimSPID ELSE NULL END AS VictimSPID, 
	LockingHostname, 
	LockingLogin,
	LockingSPID
	FROM #DEADLOCKINFO 
	WHERE DeadlockDate >=  CONVERT(DATETIME, CONVERT (NVARCHAR(10), GETDATE(), 101)) AND
	(VictimLogin IS NOT NULL OR LockingLogin IS NOT NULL)
	ORDER BY DeadlockDate ASC

	DROP TABLE #ERRORLOG
	DROP TABLE #DEADLOCKINFO
	DROP TABLE #TEMPDATES
END

GO
