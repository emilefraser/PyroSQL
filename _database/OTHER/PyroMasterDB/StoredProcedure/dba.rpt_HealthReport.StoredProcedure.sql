SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[rpt_HealthReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[rpt_HealthReport] AS' 
END
GO

ALTER PROCEDURE [dba].[rpt_HealthReport] (@Recepients NVARCHAR(200) = NULL, @CC NVARCHAR(200) = NULL, @InsertFlag BIT = 0, @EmailFlag BIT = 1)
AS

/**************************************************************************************************************
**  Purpose: This procedure generates and emails (using DBMail) an HMTL formatted health report of the server
**
**	EXAMPLE USAGE:
**
**	SEND EMAIL WITHOUT RETAINING DATA
**		EXEC dba.rpt_HealthReport @Recepients = '<email address>', @CC ='<email address>', @InsertFlag = 0
**	
**	TO POPULATE THE TABLES
**		EXEC dba.rpt_HealthReport @Recepients = '<email address>', @CC ='<email address>', @InsertFlag = 1
**
**	PULL EMAIL ADDRESSES FROM ALERTSETTINGS TABLE:
**		EXEC dba.rpt_HealthReport @Recepients = NULL, @CC = NULL, @InsertFlag = 1
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  02/21/2012		Michael Rounds			1.2					Comments creation
**	02/29/2012		Michael Rounds			1.3					Added CPU usage to PerfStats section
**  03/13/2012		Michael Rounds			1.3.1				Added Category to Job Stats section
**	03/20/2012		Michael Rounds			1.3.2				Bug fixes, optimizations
**  06/10/2012		Michael Rounds			1.3					Updated to use new FileStatsHistory table, optimized use of #JOBSTATUS
**  08/31/2012		Michael Rounds			1.4					NVARCHAR now used everywhere. Now a stand-alone proc (doesn't need DBA database or objects to run)
**	09/11/2012		Michael Rounds			1.4.1				Combined Long Running Jobs section into Jobs section
**	11/05/2012		Michael Rounds			2.0					Split out System and Server Info, Added VLF info, Added Trace Flag reporting, many bug fixes
**																	Added more File information (split out into File Info and File Stats), cleaned up error log gathering
**	11/27/2012		Michael Rounds			2.1					Tweaked Health Report to show certain elements even if there is no data (eg Trace flags)
**	12/17/2012		Michael Rounds			2.1.1				Changed Health Report to use new logic to gather file stats
**	12/27/2012		Michael Rounds			2.1.2				Fixed a bug in gathering data on db's with different coallation
**	12/31/2012		Michael Rounds			2.2					Added Deadlock section when trace flag 1222 is On.
**	01/07/2013		Michael Rounds			2.2.1				Fixed Divide by zero bug in file stats section
**	02/20/2013		Michael Rounds			2.2.3				Fixed a bug in the Deadlock section where some deadlocks weren't be included in the report
**	04/07/2013		Michael Rounds			2.2.4				Extended the lengths of KBytesRead and KBytesWritte in temp table FILESTATS - NUMERIC(12,2) to (20,2)
**	04/11/2013		Michael Rounds			2.3					Changed the File Stats section to only display last 24 hours of data instead of since last restart
**	04/12/2013		Michael Rounds			2.3.1				Added SQL Server 2012 Compatibility, Changed #TEMPDATES from SELECT INTO - > CREATE, INSERT INTO
**	04/15/2013		Michael Rounds			2.3.2				Expanded Cum_IO_GB, added COALESCE to columns in HTML output to avoid blank HTML blobs, CHAGNED CASTs to BIGINT
**	04/16/2013		Michael Rounds			2.3.3				Expanded LogSize, TotalExtents and UsedExtents
**	04/17/2013		Michael Rounds			2.3.4				Changed NVARCHAR(30) to BIGINT for Read/Write columns in #FILESTATS and FileMBSize, FileMBUsed and FileMBEmpty
**																Hopefully fixed the "File Stats - Last 24 hours" section to show accurate data
**	04/22/2013		Michael Rounds			2.3.5				Updates to accomodate new QueryHistory schema
**					T_Peters from SSC							Added CAST to BIGINT on growth in #FILESTATS which fixes a bug that caused an arithmetic error
**	04/23/2013		T_Peters from SSC		2.3.6				Adjusted FileName length in #BACKUPS to NVARCHAR(255)
**	04/24/2013		Volker.Bachmann from SSC 2.3.7				Added COALESCE to MAX(ja.start_execution_date) and MAX(ja.stop_execution_date)
**																Added COALESCE to columns in Replication Publisher section of HTML generation.
**	04/25/2013		Michael Rounds								Added MIN() to MinFileDateStamp in FileStats section
**																Fixed JOIN in UPDATE to only show last 24 hours of Read/Write FileStats
**																Fixed negative file stats showing up when a server restart happened within the last 24 hours.
**																Expanded WitnessServer in #MIRRORING to NVARCHAR(128) FROM NVARCHAR(5)
**	05/02/2013		Michael Rounds								Fixed HTML formatting in Job Stats section
**																Changed Job Stats section - CREATE #TEMPJOB instead of INSERT INTO
**																Changed LongRunningQueries section to use Formatted_SQL_Text instead of SQL_Text
**																Added variables for updated AlertSettings table for turning on/off (or reducing) sections of the HealthReport
**																	and removed @IncludePerfStats parameter (now in the table as ShowPerfStats and ShowCPUStats)
**	05/03/2013		Volker.Bachmann								Added "[dbWarden]" to the start of all email subject lines
**						from SSC
***************************************************************************************************************/
    
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @HTML NVARCHAR(MAX),    
		@ReportTitle NVARCHAR(255),  
		@ServerName NVARCHAR(128),
		@Processor NVARCHAR(255),
		@ServerOS NVARCHAR(100),
		@SystemMemory NVARCHAR(20),
		@Days NVARCHAR(5),
		@Hours NVARCHAR(5),
		@Minutes NVARCHAR(5),
		@ISClustered NVARCHAR(10),		
		@SQLVersion NVARCHAR(500),
		@ServerStartDate DATETIME,
		@ServerMemory NVARCHAR(20),
		@ServerCollation NVARCHAR(128),
		@SingleUser NVARCHAR(5),
		@SQLAgent NVARCHAR(10),
		@StartDate DATETIME,
		@EndDate DATETIME,
		@LongQueriesQueryValue INT,
		@BlockingQueryValue INT,
		@DBName NVARCHAR(128),
		@SQL NVARCHAR(MAX),
		@Distributor NVARCHAR(128),
		@DistributionDB NVARCHAR(128),
		@DistSQL NVARCHAR(MAX),
		@MinFileStatsDateStamp DATETIME,
		@SQLVer NVARCHAR(20),
		@ShowFullFileInfo BIT,
		@ShowFullJobInfo BIT,
		@ShowSchemaChanges BIT,
		@ShowBackups BIT,
		@ShowPerfStats BIT,
		@ShowCPUStats BIT,
		@ShowEmptySections BIT

/* STEP 1: GATHER DATA */
IF @@Language <> 'us_english'
BEGIN
SET LANGUAGE us_english
END

SELECT @ShowFullFileInfo = [Enabled] FROM dba.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowFullFileInfo'
SELECT @ShowFullJobInfo = [Enabled] FROM dba.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowFullJobInfo'
SELECT @ShowSchemaChanges = [Enabled] FROM dba.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowSchemaChanges'
SELECT @ShowBackups = [Enabled] FROM dba.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowBackups'
SELECT @ShowCPUStats = [Enabled] FROM dba.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowCPUStats'
SELECT @ShowPerfStats = [Enabled] FROM dba.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowPerfStats'
SELECT @ShowEmptySections = [Enabled] FROM dba.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowEmptySections'

SELECT @ReportTitle = '[dbWarden]Database Health Report ('+ CONVERT(NVARCHAR(128), SERVERPROPERTY('ServerName')) + ')'
SELECT @ServerName = CONVERT(NVARCHAR(128), SERVERPROPERTY('ServerName'))

CREATE TABLE #SYSTEMMEMORY (SystemMemory NUMERIC(12,2))

SELECT @SQLVer = LEFT(CONVERT(NVARCHAR(20),SERVERPROPERTY('productversion')),4)

IF CAST(@SQLVer AS NUMERIC(4,2)) < 11
BEGIN
-- (SQL 2008R2 And Below)
EXEC sp_executesql
	N'INSERT INTO #SYSTEMMEMORY (SystemMemory)
	SELECT CAST((physical_memory_in_bytes/1048576.0) / 1024 AS NUMERIC(12,2)) AS SystemMemory FROM sys.dm_os_sys_info'	
END
ELSE BEGIN
-- (SQL 2012 And Above)
EXEC sp_executesql
	N'INSERT INTO #SYSTEMMEMORY (SystemMemory)
	SELECT CAST((physical_memory_kb/1024.0) / 1024 AS NUMERIC(12,2)) AS SystemMemory FROM sys.dm_os_sys_info'
END

SELECT @SystemMemory = SystemMemory FROM #SYSTEMMEMORY

DROP TABLE #SYSTEMMEMORY

CREATE TABLE #SYSINFO (
	[Index] INT,
	Name NVARCHAR(100),
	Internal_Value BIGINT,
	Character_Value NVARCHAR(1000)
	)

INSERT INTO #SYSINFO
EXEC master.dba.xp_msver

SELECT @ServerOS = 'Windows ' + a.[Character_Value] + ' Version ' + b.[Character_Value] 
FROM #SYSINFO a
CROSS APPLY #SYSINFO b
WHERE a.Name = 'Platform'
AND b.Name = 'WindowsVersion'

CREATE TABLE #PROCESSOR (Value NVARCHAR(128), DATA NVARCHAR(255))

INSERT INTO #PROCESSOR
EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE',
            N'HARDWARE\DESCRIPTION\System\CentralProcessor\0',
            N'ProcessorNameString';
            
SELECT @Processor = Data FROM #Processor

SELECT @ISClustered = CASE SERVERPROPERTY('IsClustered')
						WHEN 0 THEN 'No'
						WHEN 1 THEN 'Yes'
						ELSE 
						'NA' END

SELECT @ServerStartDate = crdate FROM master..sysdatabases WHERE NAME='tempdb'
SELECT @EndDate = GETDATE()
SELECT @Days = DATEDIFF(hh, @ServerStartDate, @EndDate) / 24
SELECT @Hours = DATEDIFF(hh, @ServerStartDate, @EndDate) % 24
SELECT @Minutes = DATEDIFF(mi, @ServerStartDate, @EndDate) % 60

SELECT @SQLVersion = 'Microsoft SQL Server ' + CONVERT(NVARCHAR(128), SERVERPROPERTY('productversion')) + ' ' + 
	CONVERT(NVARCHAR(128), SERVERPROPERTY('productlevel')) + ' ' + CONVERT(NVARCHAR(128), SERVERPROPERTY('edition'))

SELECT @ServerMemory = cntr_value/1024.0 FROM sys.dm_os_performance_counters WHERE counter_name = 'Total Server Memory (KB)'
SELECT @ServerCollation = CONVERT(NVARCHAR(128), SERVERPROPERTY('Collation')) 

SELECT @SingleUser = CASE SERVERPROPERTY ('IsSingleUser')
						WHEN 1 THEN 'Single'
						WHEN 0 THEN 'Multi'
						ELSE
						'NA' END

IF EXISTS (SELECT 1 FROM master..sysprocesses WHERE program_name LIKE N'SQLAgent%')
BEGIN
SET @SQLAgent = 'Up'
END ELSE
BEGIN
SET @SQLAgent = 'Down'
END

/* Cluster Info */
CREATE TABLE #CLUSTER (
	NodeName NVARCHAR(50), 
	Active BIT
	)

IF @ISClustered = 'Yes'
BEGIN

INSERT INTO #CLUSTER (NodeName)
SELECT NodeName FROM sys.dm_os_cluster_nodes 

UPDATE #CLUSTER
SET Active = 1
WHERE NodeName = (SELECT SERVERPROPERTY('ComputerNamePhysicalNetBIOS'))
END

/* Trace Flag Status */
CREATE TABLE #TRACESTATUS (TraceFlag INT,[Status] BIT,[Global] BIT,[Session] BIT)

INSERT INTO #TRACESTATUS (TraceFlag, [Status], [Global], [Session])
EXEC ('DBCC TRACESTATUS(-1) WITH NO_INFOMSGS')

/* Disk Stats */
CREATE TABLE #DRIVES ([DriveLetter] NVARCHAR(5),[FreeSpace] BIGINT, ClusterShare BIT)

INSERT INTO #DRIVES (DriveLetter,Freespace)
EXEC master..xp_fixeddrives

IF @ISClustered = 'Yes'
BEGIN
UPDATE #DRIVES
SET ClusterShare = 0

UPDATE #DRIVES
SET ClusterShare = 1
WHERE DriveLetter IN (SELECT DriveName FROM sys.dm_io_cluster_shared_drives)
END

CREATE TABLE #PERFSTATS (
	PerfStatsHistoryID INT, 
	BufferCacheHitRatio NUMERIC(38,13), 
	PageLifeExpectency BIGINT, 
	BatchRequestsPerSecond BIGINT, 
	CompilationsPerSecond BIGINT, 
	ReCompilationsPerSecond BIGINT, 
	UserConnections BIGINT, 
	LockWaitsPerSecond BIGINT, 
	PageSplitsPerSecond BIGINT, 
	ProcessesBlocked BIGINT, 
	CheckpointPagesPerSecond BIGINT, 
	StatDate DATETIME
	)
	
CREATE TABLE #CPUSTATS (
	CPUStatsHistoryID INT, 
	SQLProcessPercent INT, 
	SystemIdleProcessPercent INT, 
	OtherProcessPerecnt INT, 
	DateStamp DATETIME
	)
	
CREATE TABLE #LONGQUERIES (
	DateStamp DATETIME,
	[ElapsedTime(ss)] INT,
	session_id SMALLINT, 
	[DBName] NVARCHAR(128), 
	login_name NVARCHAR(128), 
	SQL_Text NVARCHAR(MAX)
	)
	
CREATE TABLE #BLOCKING (
	DateStamp DATETIME,
	[DBName] NVARCHAR(128),
	Blocked_Spid SMALLINT,
	Blocking_Spid SMALLINT,
	Blocked_Login NVARCHAR(128),
	Blocked_Waittime_Seconds NUMERIC(12,2),
	Blocked_SQL_Text NVARCHAR(MAX),
	Offending_Login NVARCHAR(128),
	Offending_SQL_Text NVARCHAR(MAX)
	)

CREATE TABLE #SCHEMACHANGES (
	ObjectName NVARCHAR(128), 
	CreateDate DATETIME, 
	LoginName NVARCHAR(128), 
	ComputerName NVARCHAR(128), 
	SQLEvent NVARCHAR(255), 
	[DBName] NVARCHAR(128)
	)
	
CREATE TABLE #FILESTATS (
	[DBName] NVARCHAR(128),
	[DBID] INT,
	[FileID] INT,
	[FileName] NVARCHAR(255),
	[LogicalFileName] NVARCHAR(255),
	[VLFCount] INT,
	DriveLetter NCHAR(1),
	FileMBSize BIGINT,
	[FileMaxSize] NVARCHAR(30),
	FileGrowth NVARCHAR(30),
	FileMBUsed BIGINT,
	FileMBEmpty BIGINT,
	FilePercentEmpty NUMERIC(12,2),
	LargeLDF INT,
	[FileGroup] NVARCHAR(100),
	NumberReads BIGINT,
	KBytesRead NUMERIC(20,2),
	NumberWrites BIGINT,
	KBytesWritten NUMERIC(20,2),
	IoStallReadMS BIGINT,
	IoStallWriteMS BIGINT,
	Cum_IO_GB NUMERIC(20,2),
	IO_Percent NUMERIC(12,2)
	)
	
CREATE TABLE #JOBSTATUS (
	JobName NVARCHAR(255),
	Category NVARCHAR(255),
	[Enabled] INT,
	StartTime DATETIME,
	StopTime DATETIME,
	AvgRunTime NUMERIC(12,2),
	LastRunTime NUMERIC(12,2),
	RunTimeStatus NVARCHAR(30),
	LastRunOutcome NVARCHAR(20)
	)	

IF EXISTS (SELECT TOP 1 * FROM dba.HealthReport)
BEGIN
	SELECT @StartDate = MAX(DateStamp) FROM dba.HealthReport
END
ELSE BEGIN
	SELECT @StartDate = GETDATE() -1
END

SELECT @LongQueriesQueryValue = COALESCE(CAST(Value AS INT),0) FROM dba.AlertSettings WHERE VariableName = 'QueryValue' AND AlertName = 'LongRunningQueries'
SELECT @BlockingQueryValue = COALESCE(CAST(Value AS INT),0) FROM dba.AlertSettings WHERE VariableName = 'QueryValue' AND AlertName = 'BlockingAlert'

IF @Recepients IS NULL
BEGIN
SELECT @Recepients = EmailList FROM dba.AlertContacts WHERE AlertName = 'HealthReport'
END

IF @CC IS NULL
BEGIN
SELECT @CC = EmailList2 FROM dba.AlertContacts WHERE AlertName = 'HealthReport'
END

IF @ShowPerfStats = 1
BEGIN
	INSERT INTO #PERFSTATS (PerfStatsHistoryID, BufferCacheHitRatio, PageLifeExpectency, BatchRequestsPerSecond, CompilationsPerSecond, ReCompilationsPerSecond, 
		UserConnections, LockWaitsPerSecond, PageSplitsPerSecond, ProcessesBlocked, CheckpointPagesPerSecond, StatDate)
	SELECT PerfStatsHistoryID, BufferCacheHitRatio, PageLifeExpectency, BatchRequestsPerSecond, CompilationsPerSecond, ReCompilationsPerSecond, UserConnections, 
		LockWaitsPerSecond, PageSplitsPerSecond, ProcessesBlocked, CheckpointPagesPerSecond, StatDate
	FROM dba.PerfStatsHistory WHERE StatDate >= GETDATE() -1
	AND DATEPART(mi,StatDate) = 0
END
IF @ShowCPUStats = 1
BEGIN
	INSERT INTO #CPUSTATS (CPUStatsHistoryID, SQLProcessPercent, SystemIdleProcessPercent, OtherProcessPerecnt, DateStamp)
	SELECT CPUStatsHistoryID, SQLProcessPercent, SystemIdleProcessPercent, OtherProcessPerecnt, DateStamp
	FROM dba.CPUStatsHistory WHERE DateStamp >= GETDATE() -1
	AND DATEPART(mi,DateStamp) = 0
END

/* LongQueries */
INSERT INTO #LONGQUERIES (DateStamp, [ElapsedTime(ss)], Session_ID, [DBName], Login_Name, SQL_Text)
SELECT MAX(DateStamp) AS DateStamp,MAX(CAST(DATEDIFF(ss,Start_Time,DateStamp) AS INT)) AS [ElapsedTime(ss)],Session_ID,
	[DBName] AS [DBName],Login_Name,Formatted_SQL_Text AS SQL_Text
FROM dba.QueryHistory
WHERE (DATEDIFF(ss,Start_Time,DateStamp)) >= @LongQueriesQueryValue 
AND (DATEDIFF(dd,DateStamp,@StartDate)) < 1
AND [DBName] NOT IN (SELECT [DBName] FROM dba.DatabaseSettings WHERE LongQueryAlerts = 0)
AND Formatted_SQL_Text NOT LIKE '%BACKUP DATABASE%'
AND Formatted_SQL_Text NOT LIKE '%RESTORE VERIFYONLY%'
AND Formatted_SQL_Text NOT LIKE '%ALTER INDEX%'
AND Formatted_SQL_Text NOT LIKE '%DECLARE @BlobEater%'
AND Formatted_SQL_Text NOT LIKE '%DBCC%'
AND Formatted_SQL_Text NOT LIKE '%WAITFOR(RECEIVE%'
GROUP BY Session_ID, [DBName], Login_Name, Formatted_SQL_Text

/* Blocking */
INSERT INTO #BLOCKING (DateStamp,[DBName],Blocked_Spid,Blocking_Spid,Blocked_Login,Blocked_Waittime_Seconds,Blocked_SQL_Text,Offending_Login,Offending_SQL_Text)
SELECT DateStamp,[DBName],Blocked_Spid,Blocking_Spid,Blocked_Login,Blocked_Waittime_Seconds,Blocked_SQL_Text,Offending_Login,Offending_SQL_Text
FROM dba.BlockingHistory
WHERE DateStamp > @StartDate
AND Blocked_Waittime_Seconds >= @BlockingQueryValue

/* SchemaChanges */
IF @ShowSchemaChanges = 1
BEGIN
	CREATE TABLE #TEMP ([DBName] NVARCHAR(128), [Status] INT)

	INSERT INTO #TEMP ([DBName], [Status])
	SELECT [DBName], 0
	FROM dba.DatabaseSettings WHERE SchemaTracking = 1 AND [DBName] NOT LIKE 'AdventureWorks%'

	SET @DBName = (SELECT TOP 1 [DBName] FROM #TEMP WHERE [Status] = 0)

	WHILE @DBName IS NOT NULL
	BEGIN

	SET @SQL = 

	'SELECT ObjectName,CreateDate,LoginName,ComputerName,SQLEvent,[DBName]
	FROM '+ '[' + @DBName + ']' +'.dba.SchemaChangeLog
	WHERE CreateDate >'''+CONVERT(NVARCHAR(30),@StartDate,121)+'''
	AND SQLEvent <> ''UPDATE_STATISTICS''
	ORDER BY CreateDate DESC'

	INSERT INTO #SCHEMACHANGES (ObjectName,CreateDate,LoginName,ComputerName,SQLEvent,[DBName])
	EXEC(@SQL)

	UPDATE #TEMP
	SET [Status] = 1
	WHERE [DBName] = @DBName

	SET @DBName = (SELECT TOP 1 [DBName] FROM #TEMP WHERE [Status] = 0)

	END
	DROP TABLE #TEMP
END

/* FileStats */
CREATE TABLE #LOGSPACE (
	[DBName] NVARCHAR(128) NOT NULL,
	[LogSize] NUMERIC(20,2) NOT NULL,
	[LogPercentUsed] NUMERIC(12,2) NOT NULL,
	[LogStatus] INT NOT NULL
	)

CREATE TABLE #DATASPACE (
	[DBName] NVARCHAR(128) NULL,
	[Fileid] INT NOT NULL,
	[FileGroup] INT NOT NULL,
	[TotalExtents] NUMERIC(20,2) NOT NULL,
	[UsedExtents] NUMERIC(20,2) NOT NULL,
	[FileLogicalName] NVARCHAR(128) NULL,
	[Filename] NVARCHAR(255) NOT NULL
	)

CREATE TABLE #TMP_DB (
	[DBName] NVARCHAR(128)
	) 

SET @SQL = 'DBCC SQLPERF (LOGSPACE) WITH NO_INFOMSGS' 

INSERT INTO #LOGSPACE ([DBName],LogSize,LogPercentUsed,LogStatus)
EXEC(@SQL)

CREATE INDEX IDX_tLogSpace_Database ON #LOGSPACE ([DBName])

INSERT INTO #TMP_DB 
SELECT LTRIM(RTRIM(name)) AS [DBName]
FROM master..sysdatabases 
WHERE category IN ('0', '1','16')
AND DATABASEPROPERTYEX(name,'STATUS')='ONLINE'
ORDER BY name

CREATE INDEX IDX_TMPDB_Database ON #TMP_DB ([DBName])

SET @DBName = (SELECT MIN([DBName]) FROM #TMP_DB)

WHILE @DBName IS NOT NULL 
BEGIN

SET @SQL = 'USE ' + '[' +@DBName + ']' + '
DBCC SHOWFILESTATS WITH NO_INFOMSGS'

INSERT INTO #DATASPACE ([Fileid],[FileGroup],[TotalExtents],[UsedExtents],[FileLogicalName],[Filename])
EXEC (@SQL)

UPDATE #DATASPACE
SET [DBName] = @DBName
WHERE COALESCE([DBName],'') = ''

SET @DBName = (SELECT MIN([DBName]) FROM #TMP_DB WHERE [DBName] > @DBName)

END

SET @DBName = (SELECT MIN([DBName]) FROM #TMP_DB)

WHILE @DBName IS NOT NULL 
BEGIN
 
SET @SQL = 'USE ' + '[' +@DBName + ']' + '
INSERT INTO #FILESTATS (
	[DBName],
	[DBID],
	[FileID],	
	[DriveLetter],
	[Filename],
	[LogicalFileName],
	[Filegroup],
	[FileMBSize],
	[FileMaxSize],
	[FileGrowth],
	[FileMBUsed],
	[FileMBEmpty],
	[FilePercentEmpty])
SELECT	DBName = ''' + '[' + @dbname + ']' + ''',
		DB_ID() AS [DBID],
		SF.FileID AS [FileID],
		LEFT(SF.[FileName], 1) AS DriveLetter,		
		LTRIM(RTRIM(REVERSE(SUBSTRING(REVERSE(SF.[Filename]),0,CHARINDEX(''\'',REVERSE(SF.[Filename]),0))))) AS [Filename],
		SF.name AS LogicalFileName,
		COALESCE(filegroup_name(SF.groupid),'''') AS [Filegroup],
		(SF.size * 8)/1024 AS [FileMBSize], 
		CASE SF.maxsize 
			WHEN -1 THEN N''Unlimited'' 
			ELSE CONVERT(NVARCHAR(15), (CAST(SF.maxsize AS BIGINT) * 8)/1024) + N'' MB'' 
			END AS FileMaxSize, 
		(CASE WHEN SF.[status] & 0x100000 = 0 THEN CONVERT(NVARCHAR,CEILING((CAST(growth AS BIGINT) * 8192)/(1024.0*1024.0))) + '' MB''
			ELSE CONVERT (NVARCHAR, growth) + '' %'' 
			END) AS FileGrowth,
		CAST(COALESCE(((DSP.UsedExtents * 64.00) / 1024), LSP.LogSize *(LSP.LogPercentUsed/100)) AS BIGINT) AS [FileMBUsed],
		(SF.size * 8)/1024 - CAST(COALESCE(((DSP.UsedExtents * 64.00) / 1024), LSP.LogSize *(LSP.LogPercentUsed/100)) AS BIGINT) AS [FileMBEmpty],
		(CAST(((SF.size * 8)/1024 - CAST(COALESCE(((DSP.UsedExtents * 64.00) / 1024), LSP.LogSize *(LSP.LogPercentUsed/100)) AS BIGINT)) AS DECIMAL) / 
			CAST(CASE WHEN COALESCE((SF.size * 8)/1024,0) = 0 THEN 1 ELSE (SF.size * 8)/1024 END AS DECIMAL)) * 100 AS [FilePercentEmpty]			
FROM sys.sysfiles SF
JOIN master..sysdatabases SDB
	ON db_id() = SDB.[dbid]
JOIN sys.dm_io_virtual_file_stats(NULL,NULL) b
	ON db_id() = b.[database_id] AND SF.fileid = b.[file_id]
LEFT OUTER 
JOIN #DATASPACE DSP
	ON DSP.[Filename] COLLATE DATABASE_DEFAULT = SF.[Filename] COLLATE DATABASE_DEFAULT
LEFT OUTER 
JOIN #LOGSPACE LSP
	ON LSP.[DBName] = SDB.Name
GROUP BY SDB.Name,SF.FileID,SF.[FileName],SF.name,SF.groupid,SF.size,SF.maxsize,SF.[status],growth,DSP.UsedExtents,LSP.LogSize,LSP.LogPercentUsed'

EXEC(@SQL)

SET @DBName = (SELECT MIN([DBName]) FROM #TMP_DB WHERE [DBName] > @DBName)
END

DROP TABLE #LOGSPACE
DROP TABLE #DATASPACE

UPDATE f
SET f.NumberReads = b.num_of_reads,
	f.KBytesRead = b.num_of_bytes_read / 1024,
	f.NumberWrites = b.num_of_writes,
	f.KBytesWritten = b.num_of_bytes_written / 1024,
	f.IoStallReadMS = b.io_stall_read_ms,
	f.IoStallWriteMS = b.io_stall_write_ms,
	f.Cum_IO_GB = b.CumIOGB,
	f.IO_Percent = b.IOPercent
FROM #FILESTATS f
JOIN (SELECT database_ID, [file_id], num_of_reads, num_of_bytes_read, num_of_writes, num_of_bytes_written, io_stall_read_ms, io_stall_write_ms, 
			CAST(SUM(num_of_bytes_read + num_of_bytes_written) / 1048576 AS DECIMAL(12, 2)) / 1024 AS CumIOGB,
			CAST(CAST(SUM(num_of_bytes_read + num_of_bytes_written) / 1048576 AS DECIMAL(12, 2)) / 1024 / 
				SUM(CAST(SUM(num_of_bytes_read + num_of_bytes_written) / 1048576 AS DECIMAL(12, 2)) / 1024) OVER() * 100 AS DECIMAL(5, 2)) AS IOPercent
		FROM sys.dm_io_virtual_file_stats(NULL,NULL)
		GROUP BY database_id, [file_id],num_of_reads, num_of_bytes_read, num_of_writes, num_of_bytes_written, io_stall_read_ms, io_stall_write_ms) AS b
ON f.[DBID] = b.[database_id] AND f.fileid = b.[file_id]

UPDATE b
SET b.LargeLDF = 
	CASE WHEN CAST(b.FileMBSize AS INT) > CAST(a.FileMBSize AS INT) THEN 1
	ELSE 2 
	END
FROM #FILESTATS a
JOIN #FILESTATS b
ON a.[DBName] = b.[DBName] 
AND a.[FileName] LIKE '%mdf' 
AND b.[FileName] LIKE '%ldf'

/* VLF INFO - USES SAME TMP_DB TO GATHER STATS */
CREATE TABLE #VLFINFO (
	[DBName] NVARCHAR(128) NULL,
	RecoveryUnitId NVARCHAR(3),
	FileID NVARCHAR(3), 
	FileSize NUMERIC(20,0),
	StartOffset BIGINT, 
	FSeqNo BIGINT, 
	[Status] CHAR(1),
	Parity NVARCHAR(4),
	CreateLSN NUMERIC(25,0)
	)

IF CAST(@SQLVer AS NUMERIC(4,2)) < 11
BEGIN
-- (SQL 2008R2 And Below)
SET @DBName = (SELECT MIN([DBName]) FROM #TMP_DB)

WHILE @DBName IS NOT NULL 
BEGIN

SET @SQL = 'USE ' + '[' +@DBName + ']' + '
INSERT INTO #VLFINFO (FileID,FileSize,StartOffset,FSeqNo,[Status],Parity,CreateLSN)
EXEC(''DBCC LOGINFO WITH NO_INFOMSGS'');'
EXEC(@SQL)

SET @SQL = 'UPDATE #VLFINFO SET DBName = ''' +@DBName+ ''' WHERE DBName IS NULL;'
EXEC(@SQL)

SET @DBName = (SELECT MIN([DBName]) FROM #TMP_DB WHERE [DBName] > @DBName)
END
END
ELSE BEGIN
-- (SQL 2012 And Above)
SET @DBName = (SELECT MIN([DBName]) FROM #TMP_DB)

WHILE @DBName IS NOT NULL 
BEGIN
 
SET @SQL = 'USE ' + '[' +@DBName + ']' + '
INSERT INTO #VLFINFO (RecoveryUnitID, FileID,FileSize,StartOffset,FSeqNo,[Status],Parity,CreateLSN)
EXEC(''DBCC LOGINFO WITH NO_INFOMSGS'');'
EXEC(@SQL)

SET @SQL = 'UPDATE #VLFINFO SET DBName = ''' +@DBName+ ''' WHERE DBName IS NULL;'
EXEC(@SQL)

SET @DBName = (SELECT MIN([DBName]) FROM #TMP_DB WHERE [DBName] > @DBName)
END
END

DROP TABLE #TMP_DB

UPDATE a
SET a.VLFCount = (SELECT COUNT(1) FROM #VLFINFO WHERE [DBName] = REPLACE(REPLACE(a.DBName,'[',''),']',''))
FROM #FILESTATS a
WHERE COALESCE(a.[FileGroup],'') = ''

IF @ShowFullFileInfo = 1
BEGIN
	SELECT @MinFileStatsDateStamp = MIN(FileStatsDateStamp) FROM dba.FileStatsHistory WHERE FileStatsDateStamp >= DateAdd(hh, -24, GETDATE())

	IF @MinFileStatsDateStamp IS NOT NULL
	BEGIN
		IF @ServerStartDate < @MinFileStatsDateStamp
		BEGIN
			UPDATE c
			SET c.NumberReads = d.NumberReads,
				c.KBytesRead = d.KBytesRead,
				c.NumberWrites = d.NumberWrites,
				c.KBytesWritten = d.KBytesWritten,
				c.IoStallReadMS = d.IoStallReadMS,
				c.IoStallWriteMS = d.IoStallWriteMS,
				c.Cum_IO_GB = d.Cum_IO_GB
			FROM #FILESTATS c
			LEFT OUTER
			JOIN (SELECT
					b.dbname,
					b.[FileName],
					(b.NumberReads - COALESCE(a.NumberReads,0)) AS NumberReads,
					(b.KBytesRead - COALESCE(a.KBytesRead,0)) AS KBytesRead,
					(b.NumberWrites - COALESCE(a.NumberWrites,0)) AS NumberWrites,
					(b.KBytesWritten - COALESCE(a.KBytesWritten,0)) AS KBytesWritten,
					(b.IoStallReadMS - COALESCE(a.IoStallReadMS,0)) AS IoStallReadMS,
					(b.IoStallWriteMS - COALESCE(a.IoStallWriteMS,0)) AS IoStallWriteMS,
					(b.Cum_IO_GB - COALESCE(a.Cum_IO_GB,0)) AS Cum_IO_GB
					FROM #FILESTATS b
					LEFT OUTER
					JOIN dba.FileStatsHistory a
						ON a.dbname = b.dbname 
						AND a.[FileName] = b.[FileName]
						AND a.FileStatsDateStamp = @MinFileStatsDateStamp) d
				ON c.dbname = d.dbname 
				AND c.[FileName] = d.[FileName]
		END
	END
END

/* JobStats */
CREATE TABLE #TEMPJOB (
	Job_ID NVARCHAR(255),
	Name NVARCHAR(128),
	Category NVARCHAR(128),
	[Enabled] BIT,
	Last_Run_Outcome INT,
	Last_Run_Date NVARCHAR(20)
	)

INSERT INTO #TEMPJOB (Job_ID,Name,Category,[Enabled],Last_Run_Outcome,Last_Run_Date)
SELECT sj.job_id, 
		sj.name,
		sc.name AS Category,
		sj.[Enabled], 
		sjs.last_run_outcome,
		(SELECT MAX(run_date) 
			FROM msdb..sysjobhistory(nolock) sjh 
			WHERE sjh.job_id = sj.job_id) AS last_run_date
FROM msdb..sysjobs(nolock) sj
JOIN msdb..sysjobservers(nolock) sjs
	ON sjs.job_id = sj.job_id
JOIN msdb..syscategories sc
	ON sj.category_id = sc.category_id	

INSERT INTO #JOBSTATUS (JobName,Category,[Enabled],StartTime,StopTime,AvgRunTime,LastRunTime,RunTimeStatus,LastRunOutcome)
SELECT
	t.name AS JobName,
	t.Category,
	t.[Enabled],
	MAX(ja.start_execution_date) AS [StartTime],
	MAX(ja.stop_execution_date) AS [StopTime],
	COALESCE(AvgRunTime,0) AS AvgRunTime,
	CASE 
		WHEN ja.stop_execution_date IS NULL THEN COALESCE(DATEDIFF(ss,ja.start_execution_date,GETDATE()),0)
		ELSE DATEDIFF(ss,ja.start_execution_date,ja.stop_execution_date) END AS [LastRunTime],
	CASE 
			WHEN ja.stop_execution_date IS NULL AND ja.start_execution_date IS NOT NULL THEN
				CASE WHEN DATEDIFF(ss,ja.start_execution_date,GETDATE())
					> (AvgRunTime + AvgRunTime * .25) THEN 'LongRunning-NOW'				
				ELSE 'NormalRunning-NOW'
				END
			WHEN DATEDIFF(ss,ja.start_execution_date,ja.stop_execution_date) 
				> (AvgRunTime + AvgRunTime * .25) THEN 'LongRunning-History'
			WHEN ja.stop_execution_date IS NULL AND ja.start_execution_date IS NULL THEN 'NA'
			ELSE 'NormalRunning-History'
	END AS [RunTimeStatus],	
	CASE
		WHEN ja.stop_execution_date IS NULL AND ja.start_execution_date IS NOT NULL THEN 'InProcess'
		WHEN ja.stop_execution_date IS NOT NULL AND t.last_run_outcome = 3 THEN 'CANCELLED'
		WHEN ja.stop_execution_date IS NOT NULL AND t.last_run_outcome = 0 THEN 'ERROR'			
		WHEN ja.stop_execution_date IS NOT NULL AND t.last_run_outcome = 1 THEN 'SUCCESS'			
		ELSE 'NA'
	END AS [LastRunOutcome]
FROM #TEMPJOB AS t
LEFT OUTER
JOIN (SELECT MAX(session_id) as session_id,job_id FROM msdb..sysjobactivity(nolock) WHERE run_requested_date IS NOT NULL GROUP BY job_id) AS ja2
	ON t.job_id = ja2.job_id
LEFT OUTER
JOIN msdb..sysjobactivity(nolock) ja
	ON ja.session_id = ja2.session_id and ja.job_id = t.job_id
LEFT OUTER 
JOIN (SELECT job_id,
			AVG	((run_duration/10000 * 3600) + ((run_duration%10000)/100*60) + (run_duration%10000)%100) + 	STDEV ((run_duration/10000 * 3600) + 
				((run_duration%10000)/100*60) + (run_duration%10000)%100) AS [AvgRuntime]
		FROM msdb..sysjobhistory(nolock)
		WHERE step_id = 0 AND run_status = 1 and run_duration >= 0
		GROUP BY job_id) art 
	ON t.job_id = art.job_id
GROUP BY t.name,t.Category,t.[Enabled],t.last_run_outcome,ja.start_execution_date,ja.stop_execution_date,AvgRunTime
ORDER BY t.name

DROP TABLE #TEMPJOB

/* Replication Distributor */
CREATE TABLE #REPLINFO (
	distributor NVARCHAR(128) NULL, 
	[distribution database] NVARCHAR(128) NULL, 
	directory NVARCHAR(500), 
	account NVARCHAR(200), 
	[min distrib retention] INT, 
	[max distrib retention] INT, 
	[history retention] INT,
	[history cleanup agent] NVARCHAR(500),
	[distribution cleanup agent] NVARCHAR(500),
	[rpc server name] NVARCHAR(200),
	[rpc login name] NVARCHAR(200),
	publisher_type NVARCHAR(200)
	)

INSERT INTO #REPLINFO
EXEC sp_helpdistributor

/* Replication Publisher */	
CREATE TABLE #PUBINFO (
	publisher_db NVARCHAR(128),
	publication NVARCHAR(128),
	publication_id INT,
	publication_type INT,
	[status] INT,
	warning INT,
	worst_latency INT,
	best_latency INT,
	average_latency INT,
	last_distsync DATETIME,
	[retention] INT,
	latencythreshold INT,
	expirationthreshold INT,
	agentnotrunningthreshold INT,
	subscriptioncount INT,
	runningdisagentcount INT,
	snapshot_agentname NVARCHAR(128) NULL,
	logreader_agentname NVARCHAR(128) NULL,
	qreader_agentname NVARCHAR(128) NULL,
	worst_runspeedPerf INT,
	best_runspeedPerf INT,
	average_runspeedPerf INT,
	retention_period_unit INT
	)
	
SELECT @Distributor = distributor, @DistributionDB = [distribution database] FROM #REPLINFO

IF @Distributor = @@SERVERNAME
BEGIN

SET @DistSQL = 
'USE ' + @DistributionDB + '; EXEC sp_replmonitorhelppublication @@SERVERNAME

INSERT 
INTO #PUBINFO
EXEC sp_replmonitorhelppublication @@SERVERNAME'

EXEC(@DistSQL)

END

/* Replication Subscriber */
CREATE TABLE #REPLSUB (
	Publisher NVARCHAR(128),
	Publisher_DB NVARCHAR(128),
	Publication NVARCHAR(128),
	Distribution_Agent NVARCHAR(128),
	[Time] DATETIME,
	Immediate_Sync BIT
	)

INSERT INTO #REPLSUB
EXEC master.sys.sp_MSForEachDB 'USE [?]; 
								IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name = ''MSreplication_subscriptions'') 
								BEGIN 
								SELECT Publisher,Publisher_DB,Publication,Distribution_Agent,[time],immediate_sync FROM MSreplication_subscriptions 
								END'

/* Databases */
CREATE TABLE #DATABASES (
	[DBName] NVARCHAR(128),
	CreateDate DATETIME,
	RestoreDate DATETIME,
	[Size(GB] NUMERIC(20,5),
	[State] NVARCHAR(20),
	[Recovery] NVARCHAR(20),
	[Replication] NVARCHAR(5) DEFAULT('No'),
	Mirroring NVARCHAR(5) DEFAULT('No')
	)

INSERT INTO #DATABASES ([DBName],CreateDate,RestoreDate,[Size(GB],[State],[Recovery])
SELECT MST.Name,MST.create_date,rs.RestoreDate,SUM(CONVERT(DECIMAL,(f.FileMBSize)) / 1024) AS [Size(GB],MST.state_desc,MST.recovery_model_desc
FROM sys.databases MST
JOIN #FILESTATS F
	ON MST.database_id = f.[dbID]
LEFT OUTER
JOIN (SELECT destination_database_name AS DBName,
		MAX(restore_date) AS RestoreDate
		FROM msdb..restorehistory
		GROUP BY destination_database_name) AS rs
	ON MST.Name = rs.DBName	
GROUP BY MST.Name,MST.create_date,rs.RestoreDate,MST.state_desc,MST.recovery_model_desc

UPDATE d
SET d.Mirroring = 'Yes'
FROM #Databases d
JOIN master..sysdatabases a
	ON d.[DBName] = a.Name
JOIN sys.database_mirroring b
	ON b.database_id = a.[dbid]
WHERE b.mirroring_state IS NOT NULL

UPDATE d
SET d.[Replication] = 'Yes'
FROM #Databases d
JOIN #REPLSUB r
	ON d.[DBName] = r.Publication

UPDATE d
SET d.[Replication] = 'Yes'
FROM #Databases d
JOIN #PUBINFO p
	ON d.[DBName] = p.Publisher_DB

UPDATE d
SET d.[Replication] = 'Yes'
FROM #Databases d
JOIN #REPLINFO r
	ON d.[DBName] = r.[distribution database]

/* LogShipping */
SELECT b.primary_server, b.primary_database, a.monitor_server, c.secondary_server, c.secondary_database, a.last_backup_date, a.last_backup_file, backup_share
INTO #LOGSHIP
FROM msdb..log_shipping_primary_databases a
JOIN  msdb..log_shipping_monitor_primary b
	ON a.primary_id = b.primary_id
JOIN msdb..log_shipping_primary_secondaries c
	ON a.primary_id = c.primary_id

/* Mirroring */

CREATE TABLE #MIRRORING (
	[DBName] NVARCHAR(128),
	[State] NVARCHAR(50),
	[ServerRole] NVARCHAR(25),
	[PartnerInstance] NVARCHAR(128),
	[SafetyLevel] NVARCHAR(25),
	[AutomaticFailover] NVARCHAR(128),
	WitnessServer NVARCHAR(128)
	)

INSERT INTO #MIRRORING ([DBName], [State], [ServerRole], [PartnerInstance], [SafetyLevel], [AutomaticFailover], [WitnessServer])
SELECT s.name AS [DBName], 
	m.mirroring_state_desc AS [State], 
	m.mirroring_role_desc AS [ServerRole], 
	m.mirroring_partner_instance AS [PartnerInstance],
	CASE WHEN m.mirroring_safety_level_desc = 'FULL' THEN 'HIGH SAFETY' ELSE 'HIGH PERFORMANCE' END AS [SafetyLevel], 
	CASE WHEN m.mirroring_witness_name <> '' THEN 'Yes' ELSE 'No' END AS [AutomaticFailover],
	CASE WHEN m.mirroring_witness_name <> '' THEN m.mirroring_witness_name ELSE 'N/A' END AS [WitnessServer]
FROM master..sysdatabases s
JOIN sys.database_mirroring m
	ON s.[dbid] = m.database_id
WHERE m.mirroring_state IS NOT NULL


/* ErrorLog */
CREATE TABLE #DEADLOCKINFO (
	DeadlockDate DATETIME,
	DBName NVARCHAR(128),	
	ProcessInfo NVARCHAR(50),
	VictimHostname NVARCHAR(128),
	VictimLogin NVARCHAR(128),	
	VictimSPID NVARCHAR(5),
	VictimSQL NVARCHAR(500),
	LockingHostname NVARCHAR(128),
	LockingLogin NVARCHAR(128),
	LockingSPID NVARCHAR(5),
	LockingSQL NVARCHAR(500)
	)

CREATE TABLE #ERRORLOG (
	ID INT IDENTITY(1,1) NOT NULL
		CONSTRAINT PK_ERRORLOGTEMP
			PRIMARY KEY CLUSTERED (ID),
	LogDate DATETIME, 
	ProcessInfo NVARCHAR(100), 
	[Text] NVARCHAR(4000)
	)
	
CREATE TABLE #TEMPDATES (LogDate DATETIME)

INSERT INTO #ERRORLOG
EXEC sp_readerrorlog 0, 1

IF EXISTS (SELECT * FROM #TRACESTATUS WHERE TraceFlag = 1222)
BEGIN
	INSERT INTO #TEMPDATES (LogDate)
	SELECT DISTINCT CONVERT(VARCHAR(30),LogDate,120) as LogDate
	FROM #ERRORLOG
	WHERE ProcessInfo LIKE 'spid%'
	and [text] LIKE '   process id=%'

	INSERT INTO #DEADLOCKINFO (DeadLockDate, DBName, ProcessInfo, VictimHostname, VictimLogin, VictimSPID, LockingHostname, LockingLogin, LockingSPID)
	SELECT 
	DISTINCT CONVERT(VARCHAR(30),b.LogDate,120) AS DeadlockDate,
	DB_NAME(SUBSTRING(RTRIM(SUBSTRING(b.[text],PATINDEX('%currentdb=%',b.[text]),SUM((PATINDEX('%lockTimeout%',b.[text])) - (PATINDEX('%currentdb=%',b.[text])) ) )),11,50)) as DBName,
	b.processinfo,
	SUBSTRING(RTRIM(SUBSTRING(a.[text],PATINDEX('%hostname=%',a.[text]),SUM((PATINDEX('%hostpid%',a.[text])) - (PATINDEX('%hostname=%',a.[text])) ) )),10,50)
		AS VictimHostname,
	CASE WHEN SUBSTRING(RTRIM(SUBSTRING(a.[text],PATINDEX('%loginname=%',a.[text]),SUM((PATINDEX('%isolationlevel%',a.[text])) - (PATINDEX('%loginname=%',a.[text])) ) )),11,50) NOT LIKE '%id%'
		THEN SUBSTRING(RTRIM(SUBSTRING(a.[text],PATINDEX('%loginname=%',a.[text]),SUM((PATINDEX('%isolationlevel%',a.[text])) - (PATINDEX('%loginname=%',a.[text])) ) )),11,50)
		ELSE NULL END AS VictimLogin,
	CASE WHEN SUBSTRING(RTRIM(SUBSTRING(a.[text],PATINDEX('%spid=%',a.[text]),SUM((PATINDEX('%sbid%',a.[text])) - (PATINDEX('%spid=%',a.[text])) ) )),6,10) NOT LIKE '%id%'
		THEN SUBSTRING(RTRIM(SUBSTRING(a.[text],PATINDEX('%spid=%',a.[text]),SUM((PATINDEX('%sbid%',a.[text])) - (PATINDEX('%spid=%',a.[text])) ) )),6,10)
		ELSE NULL END AS VictimSPID,
	SUBSTRING(RTRIM(SUBSTRING(b.[text],PATINDEX('%hostname=%',b.[text]),SUM((PATINDEX('%hostpid%',b.[text])) - (PATINDEX('%hostname=%',b.[text])) ) )),10,50)
		AS LockingHostname,
	CASE WHEN SUBSTRING(RTRIM(SUBSTRING(b.[text],PATINDEX('%loginname=%',b.[text]),SUM((PATINDEX('%isolationlevel%',b.[text])) - (PATINDEX('%loginname=%',b.[text])) ) )),11,50) NOT LIKE '%id%'
		THEN SUBSTRING(RTRIM(SUBSTRING(b.[text],PATINDEX('%loginname=%',b.[text]),SUM((PATINDEX('%isolationlevel%',b.[text])) - (PATINDEX('%loginname=%',b.[text])) ) )),11,50)
		ELSE NULL END AS LockingLogin,
	CASE WHEN SUBSTRING(RTRIM(SUBSTRING(b.[text],PATINDEX('%spid=%',b.[text]),SUM((PATINDEX('%sbid=%',b.[text])) - (PATINDEX('%spid=%',b.[text])) ) )),6,10) NOT LIKE '%id%'
		THEN SUBSTRING(RTRIM(SUBSTRING(b.[text],PATINDEX('%spid=%',b.[text]),SUM((PATINDEX('%sbid=%',b.[text])) - (PATINDEX('%spid=%',b.[text])) ) )),6,10)
		ELSE NULL END AS LockingSPID
	FROM #TEMPDATES t
	JOIN #ERRORLOG a
		ON CONVERT(VARCHAR(30),t.LogDate,120) = CONVERT(VARCHAR(30),a.LogDate,120)
	JOIN #ERRORLOG b
		ON CONVERT(VARCHAR(30),t.LogDate,120) = CONVERT(VARCHAR(30),b.LogDate,120) AND a.[text] LIKE '   process id=%' AND b.[text] LIKE '   process id=%' AND a.ID < b.ID 
	GROUP BY b.LogDate,b.processinfo, a.[Text], b.[Text]

	DELETE FROM #ERRORLOG
	WHERE CONVERT(VARCHAR(30),LogDate,120) IN (SELECT DeadlockDate FROM #DEADLOCKINFO)

	DELETE FROM #DEADLOCKINFO
	WHERE (DeadlockDate <  CONVERT(DATETIME, CONVERT (VARCHAR(10), GETDATE(), 101)) -1)
	OR (DeadlockDate >= CONVERT(DATETIME, CONVERT (VARCHAR(10), GETDATE(), 101)))
END

DELETE FROM #ERRORLOG
WHERE LogDate < (GETDATE() -1)
OR ProcessInfo = 'Backup'

/* BackupStats */
CREATE TABLE #BACKUPS (
	ID INT IDENTITY(1,1) NOT NULL
		CONSTRAINT PK_BACKUPS
			PRIMARY KEY CLUSTERED (ID),
	[DBName] NVARCHAR(128),
	[Type] NVARCHAR(50),
	[Filename] NVARCHAR(255),
	Backup_Set_Name NVARCHAR(255),
	Backup_Start_Date DATETIME,
	Backup_Finish_Date DATETIME,
	Backup_Size NUMERIC(20,2),
	Backup_Age INT
	)

IF @ShowBackups = 1
BEGIN
	INSERT INTO #BACKUPS ([DBName],[Type],[Filename],Backup_Set_Name,backup_start_date,backup_finish_date,backup_size,backup_age)
	SELECT a.database_name AS [DBName],
			CASE a.[Type]
			WHEN 'D' THEN 'Full'
			WHEN 'I' THEN 'Diff'
			WHEN 'L' THEN 'Log'
			WHEN 'F' THEN 'File/Filegroup'
			WHEN 'G' THEN 'File Diff'
			WHEN 'P' THEN 'Partial'
			WHEN 'Q' THEN 'Partial Diff'
			ELSE 'Unknown' END AS [Type],
			COALESCE(b.Physical_Device_Name,'N/A') AS [Filename],
			a.name AS Backup_Set_Name,		
			a.backup_start_date,
			a.backup_finish_date,
			CAST((a.backup_size/1024)/1024/1024 AS DECIMAL(10,2)) AS Backup_Size,
			DATEDIFF(hh, MAX(a.backup_finish_date), GETDATE()) AS [Backup_Age] 
	FROM msdb..backupset a
	JOIN msdb..backupmediafamily b
		ON a.media_set_id = b.media_set_id
	WHERE a.backup_start_date > GETDATE() -1
	GROUP BY a.database_name, a.[Type],a.name, b.Physical_Device_Name,a.backup_start_date,a.backup_finish_date,a.backup_size
END
/* STEP 2: CREATE HTML BLOB */

SET @HTML =    
	'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html><head><style type="text/css">
	table { border: 0px; border-spacing: 0px; border-collapse: collapse;}
	th {color:#FFFFFF; font-size:12px; font-family:arial; background-color:#7394B0; font-weight:bold;border: 0;}
	th.header {color:#FFFFFF; font-size:13px; font-family:arial; background-color:#41627E; font-weight:bold;border: 0;border-top-left-radius: 15px 10px; 
		border-top-right-radius: 15px 10px;}  
	td {font-size:11px; font-family:arial;border-right: 0;border-bottom: 1px solid #C1DAD7;padding: 5px 5px 5px 8px;}
	td.c2 {background-color: #F0F0F0}
	td.c1 {background-color: #E0E0E0}
	td.master {border-bottom:0px}
	.Perfth {text-align:center; vertical-align:bottom; color:#FFFFFF; font-size:12px; font-family:arial; background-color:#7394B0; font-weight:bold;
		border-right: 1px solid #41627E; padding: 3px 3px 3px 3px;}
	.Perfthheader {color:#FFFFFF; font-size:13px; font-family:arial; background-color:#41627E; font-weight:bold;border: 0;border-top-left-radius: 15px 10px; 
		border-top-right-radius: 15px 10px;}  
	.Perftd {text-align:center; vertical-align:bottom; font-size:9px; font-family:arial;border-right: 1px solid #C1DAD7;border-bottom: 1px solid #C1DAD7;
		padding: 3px 1px 3px 1px;}
	.Text {background-color: #E0E0E0}
	.Text2 {background-color: #F0F0F0}	
	.Alert {background-color: #FF0000}
	.Warning {background-color: #FFFF00} 	
	</style></head><body><div>
	<table width="1150"> <tr><th class="header" width="1150">System</th></tr></table></div><div>
	<table width="1150">
	<tr>
	<th width="200">Name</th>
	<th width="300">Processor</th>	
	<th width="250">Operating System</th>	
	<th width="125">Total Memory (GB)</th>
	<th width="200">Uptime</th>
	<th width="75">Clustered</th>	
	</tr>'
SELECT @HTML = @HTML + 
	'<tr><td width="200" class="c1">'+@ServerName +'</td>' +
	'<td width="300" class="c2">'+@Processor +'</td>' +
	'<td width="250" class="c1">'+@ServerOS +'</td>' +
	'<td width="125" class="c2">'+@SystemMemory+'</td>' +	
	'<td width="200" class="c1">'+@Days+' days, '+@Hours+' hours & '+@Minutes+' minutes' +'</td>' +
	'<td width="75" class="c2"><b>'+@ISClustered+'</b></td></tr>'
SELECT @HTML = @HTML + 	'</table></div>'

SELECT @HTML = @HTML + 
'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">SQL Server</th></tr></table></div><div>
	<table width="1150">
	<tr>
	<th width="350">Version</th>	
	<th width="150">Start Up Date</th>
	<th width="100">Used Memory (MB)</th>
	<th width="100">Collation</th>
	<th width="75">User Mode</th>
	<th width="75">SQL Agent</th>	
	</tr>'
SELECT @HTML = @HTML + 
	'<tr><td width="350" class="c1">'+@SQLVersion +'</td>' +
	'<td width="150" class="c2">'+CAST(@ServerStartDate AS NVARCHAR)+'</td>' +
	'<td width="100" class="c1">'+CAST(@ServerMemory AS NVARCHAR)+'</td>' +
	'<td width="100" class="c2">'+@ServerCollation+'</td>' +
	CASE WHEN @SingleUser = 'Multi' THEN '<td width="75" class="c1"><b>Multi</b></td>'  
		 WHEN @SingleUser = 'Single' THEN '<td width="75" bgcolor="#FFFF00"><b>Single</b></td>'
	ELSE '<td width="75" bgcolor="#FF0000"><b>UNKNOWN</b></td>'
	END +	
	CASE WHEN @SQLAgent = 'Up' THEN '<td width="75" bgcolor="#00FF00"><b>Up</b></td></tr>'  
		 WHEN @SQLAgent = 'Down' THEN '<td width="75" bgcolor="#FF0000"><b>DOWN</b></td></tr>'  
	ELSE '<td width="75" bgcolor="#FF0000"><b>UNKNOWN</b></td></tr>'  
	END

SELECT @HTML = @HTML + '</table></div>'

SELECT @HTML = @HTML +
'&nbsp;<table width="1150"><tr><td class="master" width="850" rowspan="3">
	<div><table width="850"> <tr><th class="header" width="850">Databases</th></tr></table></div><div>
	<table width="850">
	  <tr>
		<th width="175">Database</th>
		<th width="150">Create Date</th>
		<th width="150">Restore Date</th>
		<th width="80">Size (GB)</th>
		<th width="70">State</th>
		<th width="75">Recovery</th>
		<th width="75">Replicated</th>
		<th width="75">Mirrored</th>				
	 </tr>'
SELECT @HTML = @HTML +   
	'<tr><td width="175" class="c1">' + [DBName] +'</td>' +
	'<td width="150" class="c2">' + CAST(CreateDate AS NVARCHAR) +'</td>' +
	'<td width="150" class="c1">' + COALESCE(CAST(RestoreDate AS NVARCHAR),'N/A') +'</td>' +   	 
	'<td width="80" class="c2">' + CAST([Size(GB] AS NVARCHAR) +'</td>' +    
 	CASE [State]    
		WHEN 'OFFLINE' THEN '<td width="70" bgColor="#FF0000"><b>OFFLINE</b></td>'
		WHEN 'ONLINE' THEN '<td width="70" class="c1">ONLINE</td>'  
	ELSE '<td width="70" bgcolor="#FF0000"><b>UNKNOWN</b></td>'
	END +
	'<td width="75" class="c2">' + [Recovery] +'</td>' +
	'<td width="75" class="c1">' + [Replication] +'</td>' +
	'<td width="75" class="c2">' + Mirroring +'</td></tr>'		
FROM #DATABASES
ORDER BY [DBName]

SELECT @HTML = @HTML + '</table></div>'

SELECT @HTML = @HTML + '</td><td class="master" width="250" valign="top">'

SELECT @HTML = @HTML + 
	'<div><table width="250"> <tr><th class="header" width="250">Disks</th></tr></table></div><div>
	<table width="250">
	  <tr>
		<th width="50">Drive</th>
		<th width="100">Free Space (GB)</th>
		<th width="100">Cluster Share</th>		
	 </tr>'
SELECT @HTML = @HTML +   
	'<tr><td width="50" class="c1">' + DriveLetter + ':' +'</td>' +    
	CASE  
		WHEN (COALESCE(CAST(CAST(FreeSpace AS DECIMAL(10,2))/1024 AS DECIMAL(10,2)), 0) <= 20) 
			THEN '<td width="100" bgcolor="#FF0000"><b>' + COALESCE(CONVERT(NVARCHAR(50), COALESCE(CAST(CAST(FreeSpace AS DECIMAL(10,2))/1024 AS DECIMAL(10,2)), 0)),'') +'</b></td>'
		ELSE '<td width="100" class="c2">' + COALESCE(CONVERT(NVARCHAR(50), COALESCE(CAST(CAST(FreeSpace AS DECIMAL(10,2))/1024 AS DECIMAL(10,2)), 0)),'') +'</td>' 
		END +
	CASE ClusterShare
		WHEN 1 THEN '<td width="100" class="c1">Yes</td></tr>'
		WHEN 0 THEN '<td width="100" class="c1">No</td></tr>'
		ELSE '<td width="100" class="c1">N/A</td></tr>'
		END
FROM #DRIVES

SELECT @HTML = @HTML + '</table></div>'

SELECT @HTML = @HTML + '<tr><td class="master" width="250" valign="top">'

IF EXISTS (SELECT * FROM #CLUSTER)
BEGIN
SELECT @HTML = @HTML + 
	'&nbsp;<div><table width="250"> <tr><th class="header" width="250">Clustering</th></tr></table></div><div>
	<table width="250">
	  <tr>
		<th width="175">Cluster Name</th>
		<th width="75">Active</th>
	 </tr>'
SELECT @HTML = @HTML +   
	'<tr><td width="175" class="c1">' + NodeName +'</td>' +    
	CASE Active
		WHEN 1 THEN '<td width="75" class="c2">Yes</td></tr>'
		ELSE '<td width="75" class="c2">No</td></tr>'
		END
FROM #CLUSTER

SELECT @HTML = @HTML + '</table></div>'
END

SELECT @HTML = @HTML + '<tr><td class="master" width="250" valign="top">'

IF EXISTS (SELECT * FROM #TRACESTATUS)
BEGIN
SELECT @HTML = @HTML + 
	'&nbsp;<div><table width="250"> <tr><th class="header" width="250">Trace Flags</th></tr></table></div><div>
	<table width="250">
	  <tr>
		<th width="65">Trace Flag</th>
		<th width="65">Status</th>
		<th width="60">Global</th>
		<th width="60">Session</th>				
	 </tr>'
SELECT @HTML = @HTML + '<tr><td width="65" class="c1">' + CAST([TraceFlag] AS NVARCHAR) + '</td>' +    
	CASE [Status]
		WHEN 1 THEN '<td width="65" class="c2">Active</td>'
		ELSE '<td width="65" class="c2">Inactive</td>'
		END +
	CASE [Global]
		WHEN 1 THEN '<td width="60" class="c1">On</td>'
		ELSE '<td width="60" class="c1">Off</td>'
		END +
	CASE [Session]
		WHEN 1 THEN '<td width="60" class="c2">On</td></tr>'
		ELSE '<td width="60" class="c2">Off</td></tr>'
		END	
FROM #TRACESTATUS

SELECT @HTML = @HTML + '</table></div>'
END ELSE
BEGIN
	IF @ShowEmptySections = 1
	BEGIN
		SELECT @HTML = @HTML + 
			'&nbsp;<div><table width="250"> <tr><th class="header" width="250">Trace Flags</th></tr></table></div><div>
			<table width="250">
			  <tr>
				<th width="250"><b>No Trace Flags Are Active</b></th>			
			 </tr>'

		SELECT @HTML = @HTML + '</table></div>'
	END
END

SELECT @HTML = @HTML + '</td></tr></table>'

SELECT @HTML = @HTML + 
	'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">File Info</th></tr></table></div><div>
	<table width="1150">
	  <tr>
		<th width="150">Database</th>
		<th width="50">Drive</th>
		<th width="250">Filename</th>
		<th width="150">Logical Name</th>
		<th width="100">Group</th>
		<th width="75">VLF Count</th>
		<th width="75">Size (MB)</th>
		<th width="75">Growth</th>
		<th width="75">Used (MB)</th>
		<th width="75">Empty (MB)</th>
		<th width="75">% Empty</th>
	 </tr>'
SELECT @HTML = @HTML +
	'<tr><td width="150" class="c1">' + [DBName] +'</td>' +
	'<td width="50" class="c2">' + COALESCE(DriveLetter,'N/A') + ':' +'</td>' +
	'<td width="250" class="c1">' + [Filename] +'</td>' +
	'<td width="150" class="c2">' + [LogicalFilename] +'</td>' +	
	CASE
		WHEN COALESCE([FileGroup],'') <> '' THEN '<td width="100" class="c1">' + [FileGroup] +'</td>'
		ELSE '<td width="100" class="c1">' + 'N/A' +'</td>'
		END +
	'<td width="75" class="c2">' + CAST(COALESCE(VLFCount,'') AS NVARCHAR) +'</td>' +
	CASE
		WHEN (LargeLDF = 1 AND [FileName] LIKE '%ldf') THEN '<td width="75" bgColor="#FFFF00">' + CAST(FileMBSize AS NVARCHAR) +'</td>'
		ELSE '<td width="75" class="c1">' + CAST(FileMBSize AS NVARCHAR) +'</td>'
		END +
	'<td width="75" class="c2">' + FileGrowth +'</td>' +
	'<td width="75" class="c1">' + CAST(FileMBUsed AS NVARCHAR) +'</td>' +
	'<td width="75" class="c2">' + CAST(FileMBEmpty AS NVARCHAR) +'</td>' +
	'<td width="75" class="c1">' + CAST(FilePercentEmpty AS NVARCHAR) + '</td>' + '</tr>'
FROM #FILESTATS

SELECT @HTML = @HTML + '</table></div>'

IF @ShowFullFileInfo = 1
BEGIN
	SELECT @HTML = @HTML + 
		'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">File Stats - Last 24 Hours</th></tr></table></div><div>
		<table width="1150">
		  <tr>
			<th width="200">Filename</th>
			<th width="75"># Reads</th>
			<th width="175">KBytes Read</th>
			<th width="75"># Writes</th>
			<th width="175">KBytes Written</th>
			<th width="125">IO Read Wait (MS)</th>
			<th width="125">IO Write Wait (MS)</th>
			<th width="125">Cumulative IO (GB)</th>
			<th width="75">IO %</th>				
		 </tr>'
	SELECT @HTML = @HTML +
		'<tr><td width="200" class="c1">' + COALESCE([FileName],'N/A') +'</td>' +
		'<td width="75" class="c2">' + CAST(COALESCE(NumberReads,'0') AS NVARCHAR) +'</td>' +
		'<td width="175" class="c1">' + COALESCE(CONVERT(NVARCHAR(50), KBytesRead),'') + ' (' + COALESCE(CONVERT(NVARCHAR(50), CAST(KBytesRead / 1024 AS NUMERIC(18,2))),'') +
			  ' MB)' +'</td>' +
		'<td width="75" class="c2">' + CAST(COALESCE(NumberWrites,'0') AS NVARCHAR) +'</td>' +
		'<td width="175" class="c1">' + COALESCE(CONVERT(NVARCHAR(50), KBytesWritten),'') + ' (' + COALESCE(CONVERT(NVARCHAR(50), CAST(KBytesWritten / 1024 AS NUMERIC(18,2)) ),'') +
			  ' MB)' +'</td>' +
		'<td width="125" class="c2">' + CAST(COALESCE(IoStallReadMS,'0') AS NVARCHAR) +'</td>' +
		'<td width="125" class="c1">' + CAST(COALESCE(IoStallWriteMS,'0') AS NVARCHAR) + '</td>' +
		'<td width="125" class="c2">' + CAST(COALESCE(Cum_IO_GB,'0') AS NVARCHAR) + '</td>' +
		'<td width="75" class="c1">' + CAST(COALESCE(IO_Percent,'0') AS NVARCHAR) + '</td>' + '</tr>'	
	FROM #FILESTATS

	SELECT @HTML = @HTML + '</table></div>'
END

IF EXISTS (SELECT * FROM #MIRRORING)
BEGIN
SELECT 
	@HTML = @HTML +
	'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Mirroring</th></tr></table></div><div>
	<table width="1150">   
	<tr> 
	<th width="150">Database</th>      
	<th width="150">State</th>   
	<th width="150">Server Role</th>   
	<th width="150">Partner Instance</th>
	<th width="150">Safety Level</th>
	<th width="200">Automatic Failover</th>
	<th width="250">Witness Server</th>   
	</tr>'	
SELECT
	@HTML = @HTML +   
	'<tr><td width="150" class="c1">' + COALESCE([DBName],'N/A') +'</td>' +
	'<td width="150" class="c2">' + COALESCE([State],'N/A') +'</td>' +  
	'<td width="150" class="c1">' + COALESCE([ServerRole],'N/A') +'</td>' +  
	'<td width="150" class="c2">' + COALESCE([PartnerInstance],'N/A') +'</td>' +  
	'<td width="150" class="c1">' + COALESCE([SafetyLevel],'N/A') +'</td>' +  
	'<td width="200" class="c2">' + COALESCE([AutomaticFailover],'N/A') +'</td>' +  
	'<td width="250" class="c1">' + COALESCE([WitnessServer],'N/A') +'</td>' +  
	 '</tr>'
FROM #MIRRORING
ORDER BY [DBName]

SELECT @HTML = @HTML + '</table></div>'
END ELSE
BEGIN
	IF @ShowEmptySections = 1
	BEGIN
		SELECT 
			@HTML = @HTML +
			'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Mirroring</th></tr></table></div><div>
			<table width="1150">   
				<tr> 
					<th width="1150">Mirroring is not setup on this system</th>
				</tr>'

		SELECT @HTML = @HTML + '</table></div>'
	END
END

IF EXISTS (SELECT * FROM #LOGSHIP)
BEGIN
SELECT 
	@HTML = @HTML +
	'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Log Shipping</th></tr></table></div><div>
	<table width="1150">   
	<tr> 
	<th width="150">Primary Server</th>      
	<th width="150">Primary DB</th>   
	<th width="150">Monitoring Server</th>   
	<th width="150">Secondary Server</th>
	<th width="150">Secondary DB</th>
	<th width="200">Last Backup Date</th>
	<th width="250">Backup Share</th>   
	</tr>'
SELECT
	@HTML = @HTML +   
	'<tr><td width="150" class="c1">' + COALESCE(primary_server,'N/A') +'</td>' +
	'<td width="150" class="c2">' + COALESCE(primary_database,'N/A') +'</td>' +  
	'<td width="150" class="c1">' + COALESCE(monitor_server,'N/A') +'</td>' +  
	'<td width="150" class="c2">' + COALESCE(secondary_server,'N/A') +'</td>' +  
	'<td width="150" class="c1">' + COALESCE(secondary_database,'N/A') +'</td>' +  
	'<td width="200" class="c2">' + COALESCE(CAST(last_backup_date AS NVARCHAR),'N/A') +'</td>' +  
	'<td width="250" class="c1">' + COALESCE(backup_share,'N/A') +'</td>' +  
	 '</tr>'
FROM #LOGSHIP
ORDER BY Primary_Database

SELECT @HTML = @HTML + '</table></div>'
END ELSE
BEGIN
	IF @ShowEmptySections = 1
	BEGIN
		SELECT 
			@HTML = @HTML +
			'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Log Shipping</th></tr></table></div><div>
			<table width="1150">   
				<tr> 
					<th width="1150">Log Shipping is not setup on this system</th>
				</tr>'

		SELECT @HTML = @HTML + '</table></div>'
	END
END

IF EXISTS (SELECT * FROM #REPLINFO WHERE Distributor IS NOT NULL)
BEGIN
SELECT 
	@HTML = @HTML +
	'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Replication Distributor</th></tr></table></div><div>
	<table width="1150">   
		<tr> 
			<th width="150">Distributor</th>      
			<th width="150">Distribution DB</th>   
			<th width="500">Replcation Share</th>   
			<th width="200">Replication Account</th>
			<th width="150">Publisher Type</th>
		</tr>'
SELECT
	@HTML = @HTML +   
	'<tr><td width="150" class="c1">' + COALESCE(Distributor,'N/A') +'</td>' +
	'<td width="150" class="c2">' + COALESCE([distribution database],'N/A') +'</td>' +  
	'<td width="500" class="c1">' + COALESCE(CAST(directory AS NVARCHAR),'N/A') +'</td>' +  
	'<td width="200" class="c2">' + COALESCE(CAST(account AS NVARCHAR),'N/A') +'</td>' +  
	'<td width="150" class="c1">' + COALESCE(CAST(publisher_type AS NVARCHAR),'N/A') +'</td></tr>'
FROM #REPLINFO

SELECT @HTML = @HTML + '</table></div>'
END ELSE
BEGIN
	IF @ShowEmptySections = 1
	BEGIN
		SELECT 
			@HTML = @HTML +
			'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Replication Distributor</th></tr></table></div><div>
			<table width="1150">   
				<tr> 
					<th width="1150">Distributor is not setup on this system</th>
				</tr>'

		SELECT @HTML = @HTML + '</table></div>'
	END
END

IF EXISTS (SELECT * FROM #PUBINFO)
BEGIN
SELECT 
	@HTML = @HTML +
	'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Replication Publisher</th></tr></table></div><div>
	<table width="1150">   
	<tr> 
	<th width="150">Publisher DB</th>      
	<th width="150">Publication</th>   
	<th width="150">Publication Type</th>   
	<th width="75">Status</th>
	<th width="100">Warnings</th>
	<th width="125">Best Latency</th>
	<th width="125">Worst Latency</th>
	<th width="125">Average Latency</th>
	<th width="150">Last Dist Sync</th>				
	</tr>'
SELECT
	@HTML = @HTML +   
	'<tr> 
	<td width="150" class="c1">' + COALESCE(publisher_db,'N/A') +'</td>' +
	'<td width="150" class="c2">' + COALESCE(publication,'N/A') +'</td>' +  
	CASE
		WHEN publication_type = 0 THEN '<td width="150" class="c1">' + 'Transactional Publication' +'</td>'
		WHEN publication_type = 1 THEN '<td width="150" class="c1">' + 'Snapshot Publication' +'</td>'
		WHEN publication_type = 2 THEN '<td width="150" class="c1">' + 'Merge Publication' +'</td>'
		ELSE '<td width="150" class="c1">' + 'N/A' +'</td>'
	END +
	CASE
		WHEN [status] = 1 THEN '<td width="75" class="c2">' + 'Started' +'</td>'
		WHEN [status] = 2 THEN '<td width="75" class="c2">' + 'Succeeded' +'</td>'
		WHEN [status] = 3 THEN '<td width="75" class="c2">' + 'In Progress' +'</td>'
		WHEN [status] = 4 THEN '<td width="75" class="c2">' + 'Idle' +'</td>'
		WHEN [status] = 5 THEN '<td width="75" class="c2">' + 'Retrying' +'</td>'
		WHEN [status] = 6 THEN '<td width="75" class="c2">' + 'Failed' +'</td>'
		ELSE '<td width="75" class="c2">' + 'N/A' +'</td>'
	END +
	CASE
		WHEN Warning = 1 THEN '<td width="100" bgcolor="#FFFF00">' + 'Expiration' +'</td>'
		WHEN Warning = 2 THEN '<td width="100" bgcolor="#FFFF00">' + 'Latency' +'</td>'
		WHEN Warning = 4 THEN '<td width="100" bgcolor="#FFFF00">' + 'Merge Expiration' +'</td>'
		WHEN Warning = 8 THEN '<td width="100" bgcolor="#FFFF00">' + 'Merge Fast Run Duration' +'</td>'
		WHEN Warning = 16 THEN '<td width="100" bgcolor="#FFFF00">' + 'Merge Slow Run Duration' +'</td>'
		WHEN Warning = 32 THEN '<td width="100" bgcolor="#FFFF00">' + 'Marge Fast Run Speed' +'</td>'
		WHEN Warning = 64 THEN '<td width="100" bgcolor="#FFFF00">' + 'Merge Slow Run Speed' +'</td>'
		ELSE '<td width="100" class="c1">' + 'N/A'														
	END +
	CASE
		WHEN publication_type = 0 THEN '<td width="125" class="c2">' + COALESCE(CAST(Best_Latency AS NVARCHAR),'N/A') +'</td>'
		WHEN publication_type = 1 THEN '<td width="125" class="c2">' + COALESCE(CAST(Best_RunSpeedPerf AS NVARCHAR),'N/A') +'</td>'
	END +
	CASE
		WHEN publication_type = 0 THEN '<td width="125" class="c1">' + COALESCE(CAST(Worst_Latency AS NVARCHAR),'N/A') +'</td>'
		WHEN publication_type = 1 THEN '<td width="125" class="c1">' + COALESCE(CAST(Worst_RunSpeedPerf AS NVARCHAR),'N/A') +'</td>'
	END +
	CASE
		WHEN publication_type = 0 THEN '<td width="125" class="c2">' + COALESCE(CAST(Average_Latency AS NVARCHAR),'N/A') +'</td>'
		WHEN publication_type = 1 THEN '<td width="125" class="c2">' + COALESCE(CAST(Average_RunSpeedPerf AS NVARCHAR),'N/A') +'</td>'
	END +
	'<td width="150" class="c1">' + COALESCE(CAST(Last_DistSync AS NVARCHAR),'N/A') +'</td>' + 
	'</tr>'
FROM #PUBINFO

SELECT @HTML = @HTML + '</table></div>'
END ELSE
BEGIN
	IF @ShowEmptySections = 1
	BEGIN
		SELECT 
			@HTML = @HTML +
			'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Replication Publisher</th></tr></table></div><div>
			<table width="1150">   
				<tr> 
					<th width="1150">Publisher is not setup on this system</th>
				</tr>'

		SELECT @HTML = @HTML + '</table></div>'
	END
END

IF EXISTS (SELECT * FROM #REPLSUB)
BEGIN
SELECT 
	@HTML = @HTML +
	'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Replication Subscriptions</th></tr></table></div><div>
	<table width="1150">   
	<tr> 
	<th width="150">Publisher</th>      
	<th width="150">Publisher DB</th>   
	<th width="150">Publication</th>   
	<th width="450">Distribution Job</th>
	<th width="150">Last Sync</th>
	<th width="100">Immediate Sync</th>
	</tr>'
SELECT
	@HTML = @HTML +   
	'<tr><td width="150" class="c1">' + COALESCE(Publisher,'N/A') +'</td>' +
	'<td width="150" class="c2">' + COALESCE(Publisher_DB,'N/A') +'</td>' +  
	'<td width="150" class="c1">' + COALESCE(Publication,'N/A') +'</td>' +  
	'<td width="450" class="c2">' + COALESCE(Distribution_Agent,'N/A') +'</td>' +  
	'<td width="150" class="c1">' + COALESCE(CAST([time] AS NVARCHAR),'N/A') +'</td>' +  
	CASE [Immediate_sync]
		WHEN 0 THEN '<td width="100" class="c2">' + 'No'  +'</td>'
		WHEN 1 THEN '<td width="100" class="c2">' + 'Yes'  +'</td>'
		ELSE 'N/A'
	END +
	 '</tr>'
FROM #REPLSUB

SELECT @HTML = @HTML + '</table></div>'
END ELSE
BEGIN
	IF @ShowEmptySections = 1
	BEGIN
		SELECT 
			@HTML = @HTML +
			'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Replication Subscriptions</th></tr></table></div><div>
			<table width="1150">   
				<tr> 
					<th width="1150">Subscriptions are not setup on this system</th>
				</tr>'

		SELECT @HTML = @HTML + '</table></div>'
	END
END

IF EXISTS (SELECT * FROM #PERFSTATS) AND @ShowPerfStats = 1
BEGIN
	SELECT @HTML = @HTML + 
		'&nbsp;<div><table width="1150"> <tr><th class="Perfthheader" width="1150">Connections - Last 24 Hours</th></tr></table></div><div>
		<table width="1150">
			<tr>'
	SELECT @HTML = @HTML + '<th class="Perfth"><img src="foo" style="background-color:white;" height="'+ CAST((COALESCE(UserConnections,0) / 2) AS NVARCHAR) +'" width="10" /></th>'
	FROM #PERFSTATS
	GROUP BY StatDate, UserConnections
	ORDER BY StatDate ASC

	SELECT @HTML = @HTML + '</tr><tr>'
	SELECT @HTML = @HTML + '<td class="Perftd"><p class="Text2">'+ CAST(COALESCE(UserConnections,0) AS NVARCHAR) +'</p></td>'
	FROM #PERFSTATS
	GROUP BY StatDate, UserConnections
	ORDER BY StatDate ASC

	SELECT @HTML = @HTML + '</tr><tr>'
	SELECT @HTML = @HTML + '<td class="Perftd"><div class="Text">'+ 
	CAST(CAST(DATEPART(mm, StatDate)AS NVARCHAR) + '/' + 
	CAST(DATEPART(dd, StatDate)AS NVARCHAR) + '/' + 
	CAST(DATEPART(yyyy, StatDate)AS NVARCHAR)
	 + '  ' + 
	RIGHT('0' + CONVERT(NVARCHAR(2), DATEPART(hh, StatDate)), 2) + ':' +
	RIGHT('0' + CONVERT(NVARCHAR(2), DATEPART(mi, StatDate)), 2)
	 AS NVARCHAR) +'</div></td>'
	FROM #PERFSTATS
	GROUP BY StatDate, UserConnections
	ORDER BY StatDate ASC

	SELECT @HTML = @HTML + '</tr></table></div>&nbsp;'
	SELECT @HTML = @HTML +
		'<div><table width="1150"> <tr><th class="Perfthheader" width="1150">Buffer Hit Cache Ratio - Last 24 Hours</th></tr></table></div><div>
		<table width="1150">
			<tr>'
	SELECT @HTML = @HTML + '<th class="Perfth"><img src="foo" style="background-color:white;" height="'+ CAST((BufferCacheHitRatio/2) AS NVARCHAR) +'" width="10" /></th>'
	FROM #PERFSTATS
	GROUP BY StatDate, BufferCacheHitRatio
	ORDER BY StatDate ASC

	SELECT @HTML = @HTML + '</tr><tr>'
	SELECT @HTML = @HTML + '<td class="Perftd">' + 

	CASE WHEN BufferCacheHitRatio < 98 THEN '<p class="Alert">'+ LEFT(CAST(BufferCacheHitRatio AS NVARCHAR),6) 
		WHEN BufferCacheHitRatio < 99.5 THEN '<p class="Warning">'+ LEFT(CAST(BufferCacheHitRatio AS NVARCHAR),6) 
	ELSE '<p class="Text2">'+ LEFT(CAST(BufferCacheHitRatio AS NVARCHAR),6) 
	END + '</p></td>'
	FROM #PERFSTATS
	GROUP BY StatDate, BufferCacheHitRatio
	ORDER BY StatDate ASC

	SELECT @HTML = @HTML + '</tr><tr>'
	SELECT @HTML = @HTML + '<td class="Perftd"><div class="Text">'+ 
	CAST(CAST(DATEPART(mm, StatDate)AS NVARCHAR) + '/' + 
	CAST(DATEPART(dd, StatDate)AS NVARCHAR) + '/' + 
	CAST(DATEPART(yyyy, StatDate)AS NVARCHAR)
	 + '  ' + 
	RIGHT('0' + CONVERT(NVARCHAR(2), DATEPART(hh, StatDate)), 2) + ':' +
	RIGHT('0' + CONVERT(NVARCHAR(2), DATEPART(mi, StatDate)), 2)
	 AS NVARCHAR) +'</div></td>'
	FROM #PERFSTATS
	GROUP BY StatDate, BufferCacheHitRatio
	ORDER BY StatDate ASC

	SELECT @HTML = @HTML + '</tr></table></div>'
END

IF EXISTS (SELECT * FROM #CPUSTATS) AND @ShowCPUStats = 1
BEGIN
	SELECT @HTML = @HTML + 
		'&nbsp;<div><table width="1150"> <tr><th class="Perfthheader" width="1150">SQL Server CPU Usage (Percent) - Last 24 Hours</th></tr></table></div><div>
		<table width="1150">
			<tr>'
	SELECT @HTML = @HTML + '<th class="Perfth"><img src="foo" style="background-color:white;" height="'+ CAST((COALESCE(SQLProcessPercent,0) / 2) AS NVARCHAR) +'" width="10" /></th>'
	FROM #CPUSTATS
	GROUP BY DateStamp, SQLProcessPercent
	ORDER BY DateStamp ASC

	SELECT @HTML = @HTML + '</tr><tr>'
	SELECT @HTML = @HTML + '<td class="Perftd"><p class="Text2">'+ CAST(COALESCE(SQLProcessPercent,0) AS NVARCHAR) +'</p></td>'
	FROM #CPUSTATS
	GROUP BY DateStamp, SQLProcessPercent
	ORDER BY DateStamp ASC

	SELECT @HTML = @HTML + '</tr><tr>'
	SELECT @HTML = @HTML + '<td class="Perftd"><div class="Text">'+ 
	CAST(CAST(DATEPART(mm, DateStamp)AS NVARCHAR) + '/' + 
	CAST(DATEPART(dd, DateStamp)AS NVARCHAR) + '/' + 
	CAST(DATEPART(yyyy, DateStamp)AS NVARCHAR)
	 + '  ' + 
	RIGHT('0' + CONVERT(NVARCHAR(2), DATEPART(hh, DateStamp)), 2) + ':' +
	RIGHT('0' + CONVERT(NVARCHAR(2), DATEPART(mi, DateStamp)), 2)
	 AS NVARCHAR) +'</div></td>'
	FROM #CPUSTATS
	GROUP BY DateStamp, SQLProcessPercent
	ORDER BY DateStamp ASC

	SELECT @HTML = @HTML + '</tr></table></div>'
END

IF EXISTS (SELECT * FROM #JOBSTATUS)
BEGIN
	IF EXISTS (SELECT * FROM #JOBSTATUS WHERE LastRunOutcome = 'ERROR' OR RunTimeStatus = 'LongRunning-History' OR RunTimeStatus = 'LongRunning-NOW') AND @ShowFullJobInfo = 0
		BEGIN
			SELECT @HTML = @HTML + 
				'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">SQL Agent Jobs</th></tr></table></div><div>
				<table width="1150"> 
				<tr> 
				<th width="375">Job Name</th>
				<th width="150">Category</th> 
				<th width="75">Enabled</th> 
				<th width="150">Last Outcome</th> 
				<th width="150">Last Date Run</th> 
				<th width="125">Avg RunTime ss(mi)</th> 
				<th width="125">Last RunTime ss(mi)</th>
				</tr>'
			SELECT @HTML = @HTML +   
				'<tr><td width="375" class="c1">' + LEFT(JobName,75) +'</td>' +    
				'<td width="150" class="c2">' + COALESCE(Category,'N/A') +'</td>' +    
				CASE [Enabled]
					WHEN 0 THEN '<td width="75" bgcolor="#FFFF00">False</td>'  
					WHEN 1 THEN '<td width="75" class="c1">True</td>'  
				ELSE '<td width="75" class="c1"><b>Unknown</b></td>'  
				END  +   
 				CASE      
					WHEN LastRunOutcome = 'ERROR' AND RunTimeStatus = 'NormalRunning-History' THEN '<td width="150" bgColor="#FF0000"><b>FAILED</b></td>'
					WHEN LastRunOutcome = 'ERROR' AND RunTimeStatus = 'LongRunning-History' THEN '<td width="150"  bgColor="#FF0000"><b>ERROR - Long Running</b></td>'  
					WHEN LastRunOutcome = 'SUCCESS' AND RunTimeStatus = 'NormalRunning-History' THEN '<td width="150"  bgColor="#00FF00">Success</td>'  
					WHEN LastRunOutcome = 'Success' AND RunTimeStatus = 'LongRunning-History' THEN '<td width="150"  bgColor="#99FF00">Success - Long Running</td>'  
					WHEN LastRunOutcome = 'InProcess' THEN '<td width="150" bgColor="#00FFFF">InProcess</td>'  
					WHEN LastRunOutcome = 'InProcess' AND RunTimeStatus = 'LongRunning-NOW' THEN '<td width="150" bgColor="#00FFFF">InProcess</td>'  
					WHEN LastRunOutcome = 'CANCELLED' THEN '<td width="150" bgColor="#FFFF00"><b>CANCELLED</b></td>'  
					WHEN LastRunOutcome = 'NA' THEN '<td width="150" class="c2">NA</td>'  
				ELSE '<td width="150" class="c2">NA</td>' 
				END + 
				'<td width="150" class="c1">' + COALESCE(CAST(StartTime AS NVARCHAR),'N/A') + '</td>' +
				'<td width="125" class="c2">' + COALESCE(CONVERT(NVARCHAR(50), AvgRuntime),'') + ' (' + COALESCE(CONVERT(NVARCHAR(50), CAST(AvgRuntime / 60 AS NUMERIC(12,2))),'') +  ')' + '</td>' +
				'<td width="125" class="c1">' + COALESCE(CONVERT(NVARCHAR(50), LastRunTime),'') + ' (' + COALESCE(CONVERT(NVARCHAR(50), CAST(LastRunTime / 60 AS NUMERIC(12,2))),'') +  ')' + '</td></tr>'   
			FROM #JOBSTATUS
			WHERE LastRunOutcome = 'ERROR' OR RunTimeStatus = 'LongRunning-History' OR RunTimeStatus = 'LongRunning-NOW'
			ORDER BY JobName

			SELECT @HTML = @HTML + '</table></div>'
		END
	IF @ShowFullJobInfo = 1
		BEGIN
			SELECT @HTML = @HTML + 
				'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">SQL Agent Jobs</th></tr></table></div><div>
				<table width="1150"> 
				<tr> 
				<th width="375">Job Name</th>
				<th width="150">Category</th> 
				<th width="75">Enabled</th> 
				<th width="150">Last Outcome</th> 
				<th width="150">Last Date Run</th> 
				<th width="125">Avg RunTime ss(mi)</th> 
				<th width="125">Last RunTime ss(mi)</th>
				</tr>'
			SELECT @HTML = @HTML +   
				'<tr><td width="375" class="c1">' + LEFT(JobName,75) +'</td>' +    
				'<td width="150" class="c2">' + COALESCE(Category,'N/A') +'</td>' +    
				CASE [Enabled]
					WHEN 0 THEN '<td width="75" bgcolor="#FFFF00">False</td>'  
					WHEN 1 THEN '<td width="75" class="c1">True</td>'  
				ELSE '<td width="75" class="c1"><b>Unknown</b></td>'  
				END  +   
 				CASE      
					WHEN LastRunOutcome = 'ERROR' AND RunTimeStatus = 'NormalRunning-History' THEN '<td width="150" bgColor="#FF0000"><b>FAILED</b></td>'
					WHEN LastRunOutcome = 'ERROR' AND RunTimeStatus = 'LongRunning-History' THEN '<td width="150"  bgColor="#FF0000"><b>ERROR - Long Running</b></td>'  
					WHEN LastRunOutcome = 'SUCCESS' AND RunTimeStatus = 'NormalRunning-History' THEN '<td width="150"  bgColor="#00FF00">Success</td>'  
					WHEN LastRunOutcome = 'Success' AND RunTimeStatus = 'LongRunning-History' THEN '<td width="150"  bgColor="#99FF00">Success - Long Running</td>'  
					WHEN LastRunOutcome = 'InProcess' THEN '<td width="150" bgColor="#00FFFF">InProcess</td>'  
					WHEN LastRunOutcome = 'InProcess' AND RunTimeStatus = 'LongRunning-NOW' THEN '<td width="150" bgColor="#00FFFF">InProcess</td>'  
					WHEN LastRunOutcome = 'CANCELLED' THEN '<td width="150" bgColor="#FFFF00"><b>CANCELLED</b></td>'  
					WHEN LastRunOutcome = 'NA' THEN '<td width="150" class="c2">NA</td>'  
				ELSE '<td width="150" class="c2">NA</td>' 
				END + 
				'<td width="150" class="c1">' + COALESCE(CAST(StartTime AS NVARCHAR),'N/A') + '</td>' +
				'<td width="125" class="c2">' + COALESCE(CONVERT(NVARCHAR(50), AvgRuntime),'') + ' (' + COALESCE(CONVERT(NVARCHAR(50), CAST(AvgRuntime / 60 AS NUMERIC(12,2))),'') +  ')' + '</td>' +
				'<td width="125" class="c1">' + COALESCE(CONVERT(NVARCHAR(50), LastRunTime),'') + ' (' + COALESCE(CONVERT(NVARCHAR(50), CAST(LastRunTime / 60 AS NUMERIC(12,2))),'') +  ')' + '</td></tr>'   
			FROM #JOBSTATUS
			ORDER BY JobName
			SELECT @HTML = @HTML + '</table></div>'	
		END
END
		
IF EXISTS (SELECT * FROM #LONGQUERIES)
BEGIN
SELECT @HTML = @HTML +   
	'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Long Running Queries</th></tr></table></div><div>
	<table width="1150">
	<tr>
	<th width="150">Date Stamp</th> 	
	<th width="150">Database</th>
	<th width="75">Time (ss)</th> 
	<th width="75">SPID</th> 	
	<th width="175">Login</th> 	
	<th width="425">Query Text</th>
	</tr>'
SELECT @HTML = @HTML +   
	'<tr>
	<td width="150" class="c1">' + CAST(DateStamp AS NVARCHAR) +'</td>	
	<td width="150" class="c2">' + COALESCE([DBName],'N/A') +'</td>
	<td width="75" class="c1">' + CAST([ElapsedTime(ss)] AS NVARCHAR) +'</td>
	<td width="75" class="c2">' + CAST(Session_id AS NVARCHAR) +'</td>
	<td width="175" class="c1">' + COALESCE(login_name,'N/A') +'</td>	
	<td width="425" class="c2">' + COALESCE(LEFT(SQL_Text,100),'N/A') +'</td>			
	</tr>'
FROM #LONGQUERIES
ORDER BY DateStamp

SELECT @HTML = @HTML + '</table></div>'
END ELSE
BEGIN
	IF @ShowEmptySections = 1
	BEGIN
		SELECT 
			@HTML = @HTML +
			'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Long Running Queries</th></tr></table></div><div>
			<table width="1150">   
				<tr> 
					<th width="1150">There has been no recent recorded long running queries</th>
				</tr>'

		SELECT @HTML = @HTML + '</table></div>'
	END
END

IF EXISTS (SELECT * FROM #BLOCKING)
BEGIN
SELECT @HTML = @HTML +
	'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Blocking</th></tr></table></div><div>
	<table width="1150">
	<tr> 
	<th width="150">Date Stamp</th> 
	<th width="150">Database</th> 	
	<th width="60">Time (ss)</th> 
	<th width="60">Victim SPID</th>
	<th width="145">Victim Login</th>
	<th width="190">Victim SQL Text</th> 
	<th width="60">Blocking SPID</th> 	
	<th width="145">Blocking Login</th>
	<th width="190">Blocking SQL Text</th> 
	</tr>'
SELECT @HTML = @HTML +   
	'<tr>
	<td width="150" class="c1">' + CAST(DateStamp AS NVARCHAR) +'</td>
	<td width="130" class="c2">' + COALESCE([DBName],'N/A') + '</td>
	<td width="60" class="c1">' + CAST(Blocked_WaitTime_Seconds AS NVARCHAR) +'</td>
	<td width="60" class="c2">' + CAST(Blocked_SPID AS NVARCHAR) +'</td>
	<td width="145" class="c1">' + COALESCE(Blocked_Login,'NA') +'</td>		
	<td width="200" class="c2">' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LEFT(Blocked_SQL_Text,100),'CREATE',''),'TRIGGER',''),'PROCEDURE',''),'FUNCTION',''),'PROC','') +'</td>
	<td width="60" class="c1">' + CAST(Blocking_SPID AS NVARCHAR) +'</td>
	<td width="145" class="c2">' + COALESCE(Offending_Login,'NA') +'</td>
	<td width="200" class="c1">' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LEFT(Offending_SQL_Text,100),'CREATE',''),'TRIGGER',''),'PROCEDURE',''),'FUNCTION',''),'PROC','') +'</td>	
	</tr>'
FROM #BLOCKING
ORDER BY DateStamp

SELECT @HTML = @HTML + '</table></div>'
END ELSE
BEGIN
	IF @ShowEmptySections = 1
	BEGIN
		SELECT 
			@HTML = @HTML +
			'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Blocking</th></tr></table></div><div>
			<table width="1150">   
				<tr> 
					<th width="1150">There has been no recent recorded blocking</th>
				</tr>'

		SELECT @HTML = @HTML + '</table></div>'
	END
END

IF EXISTS (SELECT * FROM #DEADLOCKINFO)
BEGIN
SELECT @HTML = @HTML +
	'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Deadlocks - Prior Day</th></tr></table></div><div>
	<table width="1150">
	<tr> 
	<th width="150">Date Stamp</th> 
	<th width="150">Database</th> 	
	<th width="75">Victim Hostname</th> 
	<th width="75">Victim Login</th>
	<th width="75">Victim SPID</th>
	<th width="200">Victim Objects</th> 	
	<th width="75">Locking Hostname</th>
	<th width="75">Locking Login</th> 
	<th width="75">Locking SPID</th> 
	<th width="200">Locking Objects</th>
	</tr>'
SELECT @HTML = @HTML +   
	'<tr>
	<td width="150" class="c1">' + CAST(DeadlockDate AS NVARCHAR) +'</td>
	<td width="150" class="c2">' + COALESCE([DBName],'N/A') + '</td>' +
	CASE 
		WHEN VictimLogin IS NOT NULL THEN '<td width="75" class="c1">' + COALESCE(VictimHostname,'NA') +'</td>'
	ELSE '<td width="75" class="c1">NA</td>' 
	END +
	'<td width="75" class="c2">' + COALESCE(VictimLogin,'NA') +'</td>' +
	CASE 
		WHEN VictimLogin IS NOT NULL THEN '<td width="75" class="c1">' + COALESCE(VictimSPID,'NA') +'</td>'
	ELSE '<td width="75" class="c1">NA</td>' 
	END +	
	'<td width="200" class="c2">' + COALESCE(VictimSQL,'N/A') +'</td>
	<td width="75" class="c1">' + COALESCE(LockingHostname,'N/A') +'</td>
	<td width="75" class="c2">' + COALESCE(LockingLogin,'N/A') +'</td>
	<td width="75" class="c1">' + COALESCE(LockingSPID,'N/A') +'</td>		
	<td width="200" class="c2">' + COALESCE(LockingSQL,'N/A') +'</td>
	</tr>'
FROM #DEADLOCKINFO 
WHERE (VictimLogin IS NOT NULL OR LockingLogin IS NOT NULL)
ORDER BY DeadlockDate ASC

SELECT @HTML = @HTML + '</table></div>'
END ELSE
BEGIN
	IF @ShowEmptySections = 1
	BEGIN
		SELECT 
			@HTML = @HTML +
			'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Deadlocks - Previous Day</th></tr></table></div><div>
			<table width="1150">   
				<tr> 
					<th width="1150">There has been no recent recorded Deadlocks OR TraceFlag 1222 is not Active</th>
				</tr>'

		SELECT @HTML = @HTML + '</table></div>'
	END
END

IF EXISTS (SELECT * FROM #SCHEMACHANGES) AND @ShowSchemaChanges = 1
BEGIN
SELECT @HTML = @HTML +
	'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Schema Changes</th></tr></table></div><div>
	<table width="1150">
	  <tr>
	  	<th width="150">Create Date</th>
	  	<th width="150">Database</th>
		<th width="150">SQL Event</th>	  		
		<th width="350">Object Name</th>
		<th width="175">Login Name</th>
		<th width="175">Computer Name</th>
	 </tr>'
SELECT @HTML = @HTML +   
	'<tr><td width="150" class="c1">' + CAST(CreateDate AS NVARCHAR) +'</td>' +  
	'<td width="150" class="c2">' + COALESCE([DBName],'N/A') +'</td>' +
	'<td width="150" class="c1">' + COALESCE(SQLEvent,'N/A') +'</td>' +
	'<td width="350" class="c2">' + COALESCE(ObjectName,'N/A') +'</td>' +  
	'<td width="175" class="c1">' + COALESCE(LoginName,'N/A') +'</td>' +  
	'<td width="175" class="c2">' + COALESCE(ComputerName,'N/A') +'</td></tr>'
FROM #SCHEMACHANGES
ORDER BY [DBName], CreateDate

SELECT 
	@HTML = @HTML + '</table></div>'
END ELSE
BEGIN
	IF @ShowEmptySections = 1
	BEGIN
		SELECT 
			@HTML = @HTML +
			'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Schema Changes</th></tr></table></div><div>
			<table width="1150">   
				<tr> 
					<th width="1150">There has been no recent recorded schema changes</th>
				</tr>'

		SELECT @HTML = @HTML + '</table></div>'
	END
END

IF EXISTS (SELECT * FROM #ERRORLOG)
BEGIN
SELECT 
	@HTML = @HTML +
	'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Error Log - Last 24 Hours (Does not include Backup or Deadlock info)</th></tr></table></div><div>
	<table width="1150">
	<tr>
	<th width="150">Log Date</th>
	<th width="150">Process Info</th>
	<th width="850">Message</th>
	</tr>'
SELECT
	@HTML = @HTML +
	'<tr>
	<td width="150" class="c1">' + COALESCE(CAST(LogDate AS NVARCHAR),'N/A') +'</td>' +
	'<td width="150" class="c2">' + COALESCE(ProcessInfo,'N/A') +'</td>' +
	'<td width="850" class="c1">' + COALESCE([text],'N/A') +'</td>' +
	 '</tr>'
FROM #ERRORLOG
ORDER BY LogDate DESC

SELECT @HTML = @HTML + '</table></div>'
END

IF EXISTS (SELECT * FROM #BACKUPS) AND @ShowBackups = 1
BEGIN
SELECT
	@HTML = @HTML +
	'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Backup Stats - Last 24 Hours</th></tr></table></div><div>
	<table width="1150">
	<tr>
	<th width="150">Database</th>
	<th width="90">Type</th>
	<th width="300">File Name</th>
	<th width="160">Backup Set Name</th>		
	<th width="150">Start Date</th>
	<th width="150">End Date</th>
	<th width="75">Size (GB)</th>
	<th width="75">Age (hh)</th>
	</tr>'
SELECT
	@HTML = @HTML +   
	'<tr> 
	<td width="150" class="c1">' + COALESCE([DBName],'N/A') +'</td>' +
	'<td width="90" class="c2">' + COALESCE([Type],'N/A') +'</td>' +
	'<td width="300" class="c1">' + COALESCE([Filename],'N/A') +'</td>' +
	'<td width="160" class="c2">' + COALESCE(backup_set_name,'N/A') +'</td>' +	
	'<td width="150" class="c1">' + COALESCE(CAST(backup_start_date AS NVARCHAR),'N/A') +'</td>' +  
	'<td width="150" class="c2">' + COALESCE(CAST(backup_finish_date AS NVARCHAR),'N/A') +'</td>' +  
	'<td width="75" class="c1">' + COALESCE(CAST(backup_size AS NVARCHAR),'N/A') +'</td>' +  
	'<td width="75" class="c2">' + COALESCE(CAST(backup_age AS NVARCHAR),'N/A') +'</td>' +  	
	 '</tr>'
FROM #BACKUPS
ORDER BY backup_start_date DESC

SELECT @HTML = @HTML + '</table></div>'
END ELSE
BEGIN
	IF @ShowEmptySections = 1
	BEGIN
		SELECT 
			@HTML = @HTML +
			'&nbsp;<div><table width="1150"> <tr><th class="header" width="1150">Backup Stats - Last 24 Hours</th></tr></table></div><div>
			<table width="1150">   
				<tr> 
					<th width="1150">No backups have been created on this server in the last 24 hours</th>
				</tr>'

		SELECT @HTML = @HTML + '</table></div>'
	END
END

SELECT @HTML = @HTML + '&nbsp;<div><table width="1150"><tr><td class="master">Generated on ' + CAST(GETDATE() AS NVARCHAR) + '</td></tr></table></div>'

SELECT @HTML = @HTML + '</body></html>'

/* STEP 3: SEND REPORT */

IF @EmailFlag = 1
BEGIN
EXEC msdb..sp_send_dbmail
	@recipients=@Recepients,
	@copy_recipients=@CC,  
	@subject = @ReportTitle,    
	@body = @HTML,    
	@body_format = 'HTML'
END

/* STEP 4: PRESERVE DATA */

IF @InsertFlag = 1
BEGIN
	INSERT INTO dba.HealthReport (GeneratedHTML)
	SELECT @HTML
END

DROP TABLE #SYSINFO
DROP TABLE #PROCESSOR
DROP TABLE #DRIVES
DROP TABLE #CLUSTER
DROP TABLE #TRACESTATUS
DROP TABLE #DATABASES
DROP TABLE #FILESTATS
DROP TABLE #VLFINFO
DROP TABLE #JOBSTATUS
DROP TABLE #LONGQUERIES
DROP TABLE #BLOCKING
DROP TABLE #SCHEMACHANGES
DROP TABLE #REPLINFO
DROP TABLE #PUBINFO
DROP TABLE #REPLSUB
DROP TABLE #LOGSHIP
DROP TABLE #MIRRORING
DROP TABLE #ERRORLOG
DROP TABLE #BACKUPS
DROP TABLE #PERFSTATS
DROP TABLE #CPUSTATS
DROP TABLE #DEADLOCKINFO
DROP TABLE #TEMPDATES

END
GO
