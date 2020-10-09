SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE   PROCEDURE [dbo].[rpt_HealthReport] (@Recepients NVARCHAR(200) = NULL, @CC NVARCHAR(200) = NULL, @InsertFlag BIT = 0, @EmailFlag BIT = 1)
AS
/**************************************************************************************************************
**  Purpose: This procedure generates and emails (using DBMail) an HMTL formatted health report of the server
**
**     EXAMPLE USAGE:
**
**     SEND EMAIL WITHOUT RETAINING DATA
**            EXEC dbo.rpt_HealthReport @Recepients = 'marius.williamson@gmail.com', @CC = NULL, @InsertFlag = 0
**     
**     TO POPULATE THE TABLES
**            EXEC dbo.rpt_HealthReport @Recepients = '<email address>', @CC ='<email address>', @InsertFlag = 1
**
**     PULL EMAIL ADDRESSES FROM ALERTSETTINGS TABLE:
**            EXEC dbo.rpt_HealthReport @Recepients = marius.williamson@gmail.com, @CC = NULL, @InsertFlag = 1
**
**  Revision History  
**  
**  Date                   Author                            Version                           Revision  
**  ----------             -------------------- -------------        -------------
**  02/21/2012             Michael Rounds                    1.2                               Comments creation
**     02/29/2012           Michael Rounds                    1.3                               Added CPU usage to PerfStats section
**  03/13/2012             Michael Rounds                    1.3.1                      Added Category to Job Stats section
**     03/20/2012           Michael Rounds                    1.3.2                      Bug fixes, optimizations
**  06/10/2012             Michael Rounds                    1.3                               Updated to use new FileStatsHistory table, optimized use of #JOBSTATUS
**  08/31/2012             Michael Rounds                    1.4                                NVARCHAR now used everywhere. Now a stand-alone proc (doesn't need DBA database or objects to run)
**     09/11/2012           Michael Rounds                    1.4.1                      Combined Long Running Jobs section into Jobs section
**     11/05/2012           Michael Rounds                    2.0                               Split out System and Server Info, Added VLF info, Added Trace Flag reporting, many bug fixes
**                                                                                                                   Added more File information (split out into File Info and File Stats), cleaned up error log gathering
**     11/27/2012           Michael Rounds                    2.1                               Tweaked Health Report to show certain elements even if there is no data (eg Trace flags)
**     12/17/2012           Michael Rounds                    2.1.1                      Changed Health Report to use new logic to gather file stats
**     12/27/2012           Michael Rounds                    2.1.2                      Fixed a bug in gathering data on db's with different coallation
**     12/31/2012           Michael Rounds                    2.2                               Added Deadlock section when trace flag 1222 is On.
**     01/07/2013           Michael Rounds                    2.2.1                      Fixed Divide by zero bug in file stats section
**     02/20/2013           Michael Rounds                    2.2.3                      Fixed a bug in the Deadlock section where some deadlocks weren't be included in the report
**     04/07/2013           Michael Rounds                    2.2.4                      Extended the lengths of KBytesRead and KBytesWritte in temp table FILESTATS - NUMERIC(12,2) to (20,2)
**     04/11/2013           Michael Rounds                    2.3                               Changed the File Stats section to only display last 24 hours of data instead of since last restart
**     04/12/2013           Michael Rounds                    2.3.1                      Added SQL Server 2012 Compatibility, Changed #TEMPDATES from SELECT INTO - > CREATE, INSERT INTO
**     04/15/2013           Michael Rounds                    2.3.2                      Expanded Cum_IO_GB, added COALESCE to columns in HTML output to avoid blank HTML blobs, CHAGNED CASTs to BIGINT
**     04/16/2013           Michael Rounds                    2.3.3                      Expanded LogSize, TotalExtents and UsedExtents
**     04/17/2013           Michael Rounds                    2.3.4                      Changed NVARCHAR(30) to BIGINT for Read/Write columns in #FILESTATS and FileMBSize, FileMBUsed and FileMBEmpty
**                                                                                                            Hopefully fixed the "File Stats - Last 24 hours" section to show accurate data
**     04/22/2013           Michael Rounds                    2.3.5                      Updates to accomodate new QueryHistory schema
**                                T_Peters from SSC                                             Added CAST to BIGINT on growth in #FILESTATS which fixes a bug that caused an arithmetic error
**     04/23/2013           T_Peters from SSC          2.3.6                      Adjusted FileName length in #BACKUPS to NVARCHAR(255)
**     04/24/2013           Volker.Bachmann from SSC 2.3.7                         Added COALESCE to MAX(ja.start_execution_date) and MAX(ja.stop_execution_date)
**                                                                                                            Added COALESCE to columns in Replication Publisher section of HTML generation.
**     04/25/2013           Michael Rounds                                                       Added MIN() to MinFileDateStamp in FileStats section
**                                                                                                            Fixed JOIN in UPDATE to only show last 24 hours of Read/Write FileStats
**                                                                                                            Fixed negative file stats showing up when a server restart happened within the last 24 hours.
**                                                                                                            Expanded WitnessServer in #MIRRORING to NVARCHAR(128) FROM NVARCHAR(5)
**     05/02/2013           Michael Rounds                                                       Fixed HTML formatting in Job Stats section
**                                                                                                            Changed Job Stats section - CREATE #TEMPJOB instead of INSERT INTO
**                                                                                                            Changed LongRunningQueries section to use Formatted_SQL_Text instead of SQL_Text
**                                                                                                            Added variables for updated AlertSettings table for turning on/off (or reducing) sections of the HealthReport
**                                                                                                                   and removed @IncludePerfStats parameter (now in the table as ShowPerfStats and ShowCPUStats)
**     05/03/2013           Volker.Bachmann                                                      Added "[MsAdmin]" to the start of all email subject lines
**                                       from SSC
**     05/10/2013           Michael Rounds                                                       Added many COALESCE() to the HTML output to avoid producing a blank report
**     05/14/2013           Michael Rounds                    2.4                               Added AlertSettings and DatabaseSettings sections and new @ShowMsAdminSettings to turn On/Off
**                                                                                                            IF @ShowMsAdminSettings is enabled, will also display databases NOT listed in DatabaseSettings table
**                                Mathew Monroe from SSC                                        Removed all SUM() potentially causing a conversion failure
**     05/16/2013           Michael Rounds                    2.4.1                      Added compatibility level to Database list
**                                                                                                            Changed SELECTs to use sys.databases instead of master..sysdatabases
**                                                                                                            Added new sections Database Settings and Modified SQL Server Config, turned On/Off via new AlertSetting, ShowDatabaseSettings and ShowModifiedServerConfig
**                                                                                                            Split out SQL Agent Jobs into SQL Agent Job Info and SQL Agent Job Stats - Added Owner and Next Run Date to the report
**                                                                                                            Changed Database section to show Last Backup Date, with red/yellow highlighting for old or missing backups
**                                                                                                            Moved Compatility level to Database Settings section and added Owner to Database Settings
**                                                                                                            Added ShowLogBackups to show/hide TLog's from the Backup section
**                                                                                                            Added ShowErrorLog to show/hide the Error Log section
**     05/28/2013           Michael Rounds                                                       Fixed bug that caused failure when a database has been deleted, but records still exist in DatabaseSettings table and SchemaTracking was Enabled (Schema Change section would error out)
**                                                                                                            Added section to DatabaseSettings section to show databases that no longer exist on the server, but still contain records in the DatabaseSettings table
**                                                                                                            Changed Blocking History to pull historical data the same as the Long Running Queries section
**                                                                                                            Added current version of MsAdmin to the footer of the report
**                                                                                                            Changed Long running queries data gathering to use RunTime instead of calculating it from Start_Time and DateStamp
**     06/21/2013           Michael Rounds                                                       Added new column (HealthReport) into DatabaseSettings table to switch databases on/off from appearing in the Health Report.
**     06/24/2013           Michael Rounds                                                       Fixed bug preventing report from running when a Single user DB was had an active connection
**     07/09/2013           Michael Rounds                                                       Added Orphaned Users section
**     07/23/2013           Michael Rounds                    2.5                               Tweaked to support Case-sensitive
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
                     @ShowEmptySections BIT,
                     @ShowMsAdminSettings BIT,
                     @ShowDatabaseSettings BIT,
                     @ShowModifiedServerConfig BIT,
                     @ShowLogBackups BIT,
                     @ShowErrorLog BIT,
                     @ShowOrphanedUsers BIT

       /* STEP 1: GATHER DATA */
       IF @@Language <> 'us_english'
       BEGIN
              SET LANGUAGE us_english
       END

       SELECT @ShowDatabaseSettings = COALESCE([Enabled],1) FROM [MsAdmin].dbo.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowDatabaseSettings'
       SELECT @ShowModifiedServerConfig = COALESCE([Enabled],1) FROM [MsAdmin].dbo.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowModifiedServerConfig'
       SELECT @ShowMsAdminSettings = COALESCE([Enabled],1) FROM [MsAdmin].dbo.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowMsAdminSettings'
       SELECT @ShowFullFileInfo = COALESCE([Enabled],1) FROM [MsAdmin].dbo.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowFullFileInfo'
       SELECT @ShowFullJobInfo = COALESCE([Enabled],1) FROM [MsAdmin].dbo.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowFullJobInfo'
       SELECT @ShowSchemaChanges = COALESCE([Enabled],1) FROM [MsAdmin].dbo.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowSchemaChanges'
       SELECT @ShowBackups = COALESCE([Enabled],1) FROM [MsAdmin].dbo.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowBackups'
       SELECT @ShowCPUStats = COALESCE([Enabled],1) FROM [MsAdmin].dbo.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowCPUStats'
       SELECT @ShowPerfStats = COALESCE([Enabled],1) FROM [MsAdmin].dbo.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowPerfStats'
       SELECT @ShowEmptySections = COALESCE([Enabled],1) FROM [MsAdmin].dbo.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowEmptySections'
       SELECT @ShowLogBackups = COALESCE([Enabled],1) FROM [MsAdmin].dbo.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowLogBackups'
       SELECT @ShowErrorLog = COALESCE([Enabled],1) FROM [MsAdmin].dbo.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowErrorLog'
       SELECT @ShowOrphanedUsers = COALESCE([Enabled],1) FROM [MsAdmin].dbo.AlertSettings WHERE AlertName = 'HealthReport' AND VariableName = 'ShowOrphanedUsers'    

       SELECT @ReportTitle = '[MsAdmin]Database Health Report ('+ CONVERT(NVARCHAR(128), SERVERPROPERTY('ServerName')) + ')'
       SELECT @ServerName = CONVERT(NVARCHAR(128), SERVERPROPERTY('ServerName'))

       DROP TABLE IF EXISTS #SYSTEMMEMORY
 CREATE TABLE  #SYSTEMMEMORY (SystemMemory NUMERIC(12,2))

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

       SELECT @SystemMemory = COALESCE(CAST(SystemMemory AS NVARCHAR),'N/A') FROM #SYSTEMMEMORY

       DROP TABLE #SYSTEMMEMORY

       DROP TABLE IF EXISTS #SYSINFO
 CREATE TABLE  #SYSINFO (
              [Index] INT,
              Name NVARCHAR(100),
              Internal_Value BIGINT,
              Character_Value NVARCHAR(1000)
              )

       INSERT INTO #SYSINFO
       EXEC master.dbo.xp_msver

       SELECT @ServerOS = 'Windows ' + COALESCE(a.[Character_Value],'N/A') + ' Version ' + COALESCE(b.[Character_Value],'N/A')
       FROM #SYSINFO a
       CROSS APPLY #SYSINFO b
       WHERE a.Name = 'Platform'
       AND b.Name = 'WindowsVersion'

       DROP TABLE IF EXISTS #PROCESSOR
 CREATE TABLE  #PROCESSOR (Value NVARCHAR(128), DATA NVARCHAR(255))

       INSERT INTO #PROCESSOR
       EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE',
                           N'HARDWARE\DESCRIPTION\System\CentralProcessor\0',
                           N'ProcessorNameString';
                   
       SELECT @Processor = COALESCE(Data,'N/A') FROM #Processor

       SELECT @ISClustered = CASE SERVERPROPERTY('IsClustered')
                                                WHEN 0 THEN 'No'
                                                WHEN 1 THEN 'Yes'
                                                ELSE 'NA' END

       SELECT @ServerStartDate = COALESCE(create_date,GETDATE()) FROM sys.databases WHERE NAME='tempdb'
       SELECT @EndDate = GETDATE()
       SELECT @Days = DATEDIFF(hh, @ServerStartDate, @EndDate) / 24
       SELECT @Hours = DATEDIFF(hh, @ServerStartDate, @EndDate) % 24
       SELECT @Minutes = DATEDIFF(mi, @ServerStartDate, @EndDate) % 60

       SELECT @SQLVersion = 'Microsoft SQL Server ' + CONVERT(NVARCHAR(128), SERVERPROPERTY('productversion')) + ' ' + 
              CONVERT(NVARCHAR(128), SERVERPROPERTY('productlevel')) + ' ' + CONVERT(NVARCHAR(128), SERVERPROPERTY('edition'))

       SELECT @ServerMemory = COALESCE(CAST(cntr_value/1024.0 AS NVARCHAR),'N/A') FROM sys.dm_os_performance_counters WHERE counter_name = 'Total Server Memory (KB)'
       SELECT @ServerCollation = COALESCE(CONVERT(NVARCHAR(128), SERVERPROPERTY('Collation')),'N/A')

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
       DROP TABLE IF EXISTS #CLUSTER
 CREATE TABLE  #CLUSTER (
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
       DROP TABLE IF EXISTS #TRACESTATUS
 CREATE TABLE  #TRACESTATUS (TraceFlag INT,[Status] BIT,[Global] BIT,[Session] BIT)

       INSERT INTO #TRACESTATUS (TraceFlag, [Status], [Global], [Session])
       EXEC ('DBCC TRACESTATUS(-1) WITH NO_INFOMSGS')

       /* Disk Stats */
       DROP TABLE IF EXISTS #DRIVES
 CREATE TABLE  #DRIVES ([DriveLetter] NVARCHAR(5),[FreeSpace] BIGINT, ClusterShare BIT CONSTRAINT df_drives_Cluster DEFAULT(0))

       INSERT INTO #DRIVES (DriveLetter,Freespace)
       EXEC master..xp_fixeddrives

       IF @ISClustered = 'Yes'
       BEGIN
              UPDATE #DRIVES
              SET ClusterShare = 1
              WHERE DriveLetter IN (SELECT DriveName FROM sys.dm_io_cluster_shared_drives)
       END

       DROP TABLE IF EXISTS #ORPHANEDUSERS
 CREATE TABLE  #ORPHANEDUSERS (
              [DBName] NVARCHAR(128), 
              [OrphanedUser] NVARCHAR(128), 
              [UID] SMALLINT, 
              CreateDate DATETIME,
              UpdateDate DATETIME
              )

       DROP TABLE IF EXISTS #SERVERCONFIGSETTINGS
 CREATE TABLE  #SERVERCONFIGSETTINGS (
              ConfigName NVARCHAR(100),
              ConfigDesc NVARCHAR(500),
              DefaultValue SQL_VARIANT,
              CurrentValue SQL_VARIANT,
              Is_Dynamic BIT,
              Is_Advanced BIT
              )

       DROP TABLE IF EXISTS #DATABASESETTINGS
 CREATE TABLE  #DATABASESETTINGS (
              DBName NVARCHAR(128),
              [Owner] NVARCHAR(255),
              [Compatibility_Level] SQL_VARIANT,
              User_Access_Desc NVARCHAR(128),
              is_read_only SQL_VARIANT,
              is_auto_create_stats_on SQL_VARIANT,
              is_auto_update_stats_on SQL_VARIANT,
              is_quoted_identifier_on SQL_VARIANT,
              is_fulltext_enabled SQL_VARIANT,
              is_trustworthy_on SQL_VARIANT,
              is_encrypted SQL_VARIANT
              )

       DROP TABLE IF EXISTS #PERFSTATS
 CREATE TABLE  #PERFSTATS (
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
              
       DROP TABLE IF EXISTS #CPUSTATS
 CREATE TABLE  #CPUSTATS (
              CPUStatsHistoryID INT, 
              SQLProcessPercent INT, 
              SystemIdleProcessPercent INT, 
              OtherProcessPerecnt INT, 
              DateStamp DATETIME
              )
              
       DROP TABLE IF EXISTS #LONGQUERIES
 CREATE TABLE  #LONGQUERIES (
              DateStamp DATETIME,
              [ElapsedTime(ss)] INT,
              Session_ID SMALLINT, 
              [DBName] NVARCHAR(128), 
              Login_Name NVARCHAR(128), 
              SQL_Text NVARCHAR(MAX)
              )
              
       DROP TABLE IF EXISTS #BLOCKING
 CREATE TABLE  #BLOCKING (
              DateStamp DATETIME,
              [DBName] NVARCHAR(128),
              Blocked_SPID SMALLINT,
              Blocking_SPID SMALLINT,
              Blocked_Login NVARCHAR(128),
              Blocked_WaitTime_Seconds NUMERIC(12,2),
              Blocked_SQL_Text NVARCHAR(MAX),
              Offending_Login NVARCHAR(128),
              Offending_SQL_Text NVARCHAR(MAX)
              )

       DROP TABLE IF EXISTS #SCHEMACHANGES
 CREATE TABLE  #SCHEMACHANGES (
              ObjectName NVARCHAR(128), 
              CreateDate DATETIME, 
              LoginName NVARCHAR(128), 
              ComputerName NVARCHAR(128), 
              SQLEvent NVARCHAR(255), 
              [DBName] NVARCHAR(128)
              )
              
       DROP TABLE IF EXISTS #FILESTATS
 CREATE TABLE  #FILESTATS (
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
              
       DROP TABLE IF EXISTS #JOBSTATUS
 CREATE TABLE  #JOBSTATUS (
              JobName NVARCHAR(255),
              [Owner] NVARCHAR(255),     
              Category NVARCHAR(255),
              [Enabled] INT,
              StartTime DATETIME,
              StopTime DATETIME,
              AvgRunTime NUMERIC(12,2),
              LastRunTime NUMERIC(12,2),
              RunTimeStatus NVARCHAR(30),
              LastRunOutcome NVARCHAR(20)
              )      

       IF EXISTS (SELECT TOP 1 * FROM [MsAdmin].dbo.HealthReport)
       BEGIN
              SELECT @StartDate = MAX(DateStamp) FROM [MsAdmin].dbo.HealthReport
       END
       ELSE BEGIN
              SELECT @StartDate = GETDATE() -1
       END

       SELECT @LongQueriesQueryValue = COALESCE(CAST(Value AS INT),1) FROM [MsAdmin].dbo.AlertSettings WHERE VariableName = 'QueryValue' AND AlertName = 'LongRunningQueries'
       SELECT @BlockingQueryValue = COALESCE(CAST(Value AS INT),1) FROM [MsAdmin].dbo.AlertSettings WHERE VariableName = 'QueryValue' AND AlertName = 'BlockingAlert'

       IF @Recepients IS NULL
       BEGIN
              SELECT @Recepients = EmailList FROM [MsAdmin].dbo.AlertContacts WHERE AlertName = 'HealthReport'
       END

       IF @CC IS NULL
       BEGIN
              SELECT @CC = EmailList2 FROM [MsAdmin].dbo.AlertContacts WHERE AlertName = 'HealthReport'
       END

       INSERT INTO #SERVERCONFIGSETTINGS (ConfigName,DefaultValue)
       SELECT 'access check cache bucket count', 0 UNION ALL
       SELECT 'access check cache quota', 0 UNION ALL
       SELECT 'Ad Hoc Distributed Queries', 0 UNION ALL
       SELECT 'affinity I/O mask', 0 UNION ALL
       SELECT 'affinity mask', 0 UNION ALL
       SELECT 'affinity64 mask', 0 UNION ALL
       SELECT 'affinity64 I/O mask', 0 UNION ALL
       SELECT 'Agent XPs', 0 UNION ALL
       SELECT 'allow updates', 0 UNION ALL
       SELECT 'awe enabled', 0 UNION ALL
       SELECT 'backup compression default', 0 UNION ALL
       SELECT 'blocked process threshold', 0 UNION ALL
       SELECT 'blocked process threshold (s)', 0 UNION ALL
       SELECT 'c2 audit mode', 0 UNION ALL
       SELECT 'clr enabled', 0 UNION ALL
       SELECT 'common criteria compliance enabled', 0 UNION ALL
       SELECT 'contained database authentication', 0 UNION ALL
       SELECT 'cost threshold for parallelism', 5 UNION ALL
       SELECT 'cross db ownership chaining', 0 UNION ALL
       SELECT 'cursor threshold', -1 UNION ALL
       SELECT 'Database Mail XPs', 0 UNION ALL
       SELECT 'default full-text language', 1033 UNION ALL
       SELECT 'default language', 0 UNION ALL
       SELECT 'default trace enabled', 1 UNION ALL
       SELECT 'disallow results from triggers', 0 UNION ALL
       SELECT 'EKM provider enabled', 0 UNION ALL
       SELECT 'filestream access level', 0 UNION ALL
       SELECT 'fill factor (%)', 0 UNION ALL
       SELECT 'ft crawl bandwidth (max)', 100 UNION ALL
       SELECT 'ft crawl bandwidth (min)', 0 UNION ALL
       SELECT 'ft notify bandwidth (max)', 100 UNION ALL
       SELECT 'ft notify bandwidth (min)', 0 UNION ALL
       SELECT 'index create memory (KB)', 0 UNION ALL
       SELECT 'in-doubt xact resolution', 0 UNION ALL
       SELECT 'lightweight pooling', 0 UNION ALL
       SELECT 'locks', 0 UNION ALL
       SELECT 'max degree of parallelism', 0 UNION ALL
       SELECT 'max full-text crawl range', 4 UNION ALL
       SELECT 'max server memory (MB)', 2147483647 UNION ALL
       SELECT 'max text repl size (B)', 65536 UNION ALL
       SELECT 'max worker threads', 0 UNION ALL
       SELECT 'media retention', 0 UNION ALL
       SELECT 'min memory per query (KB)', 1024 UNION ALL
       SELECT 'min server memory (MB)', 0 UNION ALL
       SELECT 'nested triggers', 1 UNION ALL
       SELECT 'network packet size (B)', 4096 UNION ALL
       SELECT 'Ole Automation Procedures', 0 UNION ALL
       SELECT 'open objects', 0 UNION ALL
       SELECT 'optimize for ad hoc workloads', 0 UNION ALL
       SELECT 'PH timeout (s)', 60 UNION ALL
       SELECT 'precompute rank', 0 UNION ALL
       SELECT 'priority boost', 0 UNION ALL
       SELECT 'query governor cost limit', 0 UNION ALL
       SELECT 'query wait (s)', -1 UNION ALL
       SELECT 'recovery interval (min)', 0 UNION ALL
       SELECT 'remote access', 1 UNION ALL
       SELECT 'remote admin connections', 0 UNION ALL
       SELECT 'remote login timeout (s)', 20 UNION ALL
       SELECT 'remote proc trans', 0 UNION ALL
       SELECT 'remote query timeout (s)', 600 UNION ALL
       SELECT 'Replication XPs', 0 UNION ALL
       SELECT 'scan for startup procs', 0 UNION ALL
       SELECT 'server trigger recursion', 1 UNION ALL
       SELECT 'set working set size', 0 UNION ALL
       SELECT 'show advanced options', 0 UNION ALL
       SELECT 'SMO and DMO XPs', 1 UNION ALL
       SELECT 'SQL Mail XPs', 0 UNION ALL
       SELECT 'transform noise words', 0 UNION ALL
       SELECT 'two digit year cutoff', 2049 UNION ALL
       SELECT 'user connections', 0 UNION ALL
       SELECT 'user options', 0 UNION ALL
       SELECT 'Web Assistant Procedures', 0 UNION ALL
       SELECT 'xp_cmdshell', 0

       UPDATE scs
       SET scs.CurrentValue = sc.value_in_use,
              scs.ConfigDesc = sc.[description],
              scs.Is_Dynamic = sc.is_dynamic,
              scs.Is_Advanced = sc.is_advanced
       FROM #SERVERCONFIGSETTINGS scs
       JOIN sys.configurations sc
              ON scs.ConfigName = sc.name

       DELETE FROM #SERVERCONFIGSETTINGS WHERE CurrentValue IS NULL

       IF @ShowDatabaseSettings = 1
       BEGIN
              --SQL Server 2005
              IF CAST(@SQLVer AS NUMERIC(4,2)) < 10
              BEGIN
                     EXEC sp_executesql
                     N'INSERT INTO #DATABASESETTINGS (DBName,[Owner],Compatibility_Level,User_Access_Desc,is_read_only,is_auto_create_stats_on,is_auto_update_stats_on,is_quoted_identifier_on,is_fulltext_enabled,is_trustworthy_on)
                     SELECT d.Name,SUSER_SNAME(d.owner_sid) AS [Owner],d.compatibility_level,d.user_access_desc,d.is_read_only,d.is_auto_create_stats_on,d.is_auto_update_stats_on,d.is_quoted_identifier_on,d.is_fulltext_enabled,d.is_trustworthy_on
                     FROM sys.databases d
                     LEFT OUTER
                     JOIN [MsAdmin].dbo.DatabaseSettings ds
                           ON d.Name COLLATE DATABASE_DEFAULT = ds.DBName COLLATE DATABASE_DEFAULT AND ds.HealthReport = 1'
              END
              --SQL Server 2008 and above
              IF CAST(@SQLVer AS NUMERIC(4,2)) >= 10
              BEGIN
                     EXEC sp_executesql
                     N'INSERT INTO #DATABASESETTINGS (DBName,[Owner],Compatibility_Level,User_Access_Desc,is_read_only,is_auto_create_stats_on,is_auto_update_stats_on,is_quoted_identifier_on,is_fulltext_enabled,is_trustworthy_on,is_encrypted)
                     SELECT d.Name,SUSER_SNAME(d.owner_sid) AS [Owner],d.compatibility_level,d.user_access_desc,d.is_read_only,d.is_auto_create_stats_on,d.is_auto_update_stats_on,d.is_quoted_identifier_on,d.is_fulltext_enabled,d.is_trustworthy_on,d.is_encrypted
                     FROM sys.databases d
                     LEFT OUTER
                     JOIN [MsAdmin].dbo.DatabaseSettings ds
                           ON d.Name COLLATE DATABASE_DEFAULT = ds.DBName COLLATE DATABASE_DEFAULT AND ds.HealthReport = 1'
              END
       END

       IF @ShowPerfStats = 1
       BEGIN
              INSERT INTO #PERFSTATS (PerfStatsHistoryID, BufferCacheHitRatio, PageLifeExpectency, BatchRequestsPerSecond, CompilationsPerSecond, ReCompilationsPerSecond, 
                     UserConnections, LockWaitsPerSecond, PageSplitsPerSecond, ProcessesBlocked, CheckpointPagesPerSecond, StatDate)
              SELECT PerfStatsHistoryID, BufferCacheHitRatio, PageLifeExpectency, BatchRequestsPerSecond, CompilationsPerSecond, ReCompilationsPerSecond, UserConnections, 
                     LockWaitsPerSecond, PageSplitsPerSecond, ProcessesBlocked, CheckpointPagesPerSecond, StatDate
              FROM [MsAdmin].dbo.PerfStatsHistory WHERE StatDate >= GETDATE() -1
              AND DATEPART(mi,StatDate) = 0
       END
       IF @ShowCPUStats = 1
       BEGIN
              INSERT INTO #CPUSTATS (CPUStatsHistoryID, SQLProcessPercent, SystemIdleProcessPercent, OtherProcessPerecnt, DateStamp)
              SELECT CPUStatsHistoryID, SQLProcessPercent, SystemIdleProcessPercent, OtherProcessPerecnt, DateStamp
              FROM [MsAdmin].dbo.CPUStatsHistory WHERE DateStamp >= GETDATE() -1
              AND DATEPART(mi,DateStamp) = 0
       END

       /* LongQueries */
       INSERT INTO #LONGQUERIES (DateStamp, [ElapsedTime(ss)], Session_ID, [DBName], Login_Name, SQL_Text)
       SELECT MAX(qh.DateStamp) AS DateStamp,qh.RunTime AS [ElapsedTime(ss)],qh.Session_ID,qh.DBName,qh.Login_Name,qh.Formatted_SQL_Text AS SQL_Text
       FROM [MsAdmin].dbo.QueryHistory qh
       LEFT OUTER
       JOIN [MsAdmin].dbo.DatabaseSettings ds
              ON qh.DBName = ds.DBName AND ds.HealthReport = 1
       WHERE ds.LongQueryAlerts = 1
       AND qh.RunTime >= @LongQueriesQueryValue 
       AND (DATEDIFF(dd,qh.DateStamp,@StartDate)) < 1
       AND qh.Formatted_SQL_Text NOT LIKE '%BACKUP DATABASE%'
       AND qh.Formatted_SQL_Text NOT LIKE '%RESTORE VERIFYONLY%'
       AND qh.Formatted_SQL_Text NOT LIKE '%ALTER INDEX%'
       AND qh.Formatted_SQL_Text NOT LIKE '%DECLARE @BlobEater%'
       AND qh.Formatted_SQL_Text NOT LIKE '%DBCC%'
       AND qh.Formatted_SQL_Text NOT LIKE '%FETCH API_CURSOR%'       
       AND qh.Formatted_SQL_Text NOT LIKE '%WAITFOR(RECEIVE%'
       GROUP BY qh.RunTime,qh.Session_ID,qh.DBName,qh.Login_Name,qh.Formatted_SQL_Text

       /* Blocking */
       INSERT INTO #BLOCKING (DateStamp,[DBName],Blocked_SPID,Blocking_SPID,Blocked_Login,Blocked_WaitTime_Seconds,Blocked_SQL_Text,Offending_Login,Offending_SQL_Text)
       SELECT bh.DateStamp,bh.[DBName],bh.Blocked_SPID,bh.Blocking_SPID,bh.Blocked_Login,bh.Blocked_WaitTime_Seconds,bh.Blocked_SQL_Text,bh.Offending_Login,bh.Offending_SQL_Text
       FROM [MsAdmin].dbo.BlockingHistory bh
       LEFT OUTER
       JOIN [MsAdmin].dbo.DatabaseSettings ds
              ON bh.DBName = ds.DBName AND ds.HealthReport = 1
       WHERE (DATEDIFF(dd,bh.DateStamp,@StartDate)) < 1
       AND bh.Blocked_WaitTime_Seconds >= @BlockingQueryValue

       /* SchemaChanges */
       IF @ShowSchemaChanges = 1
       BEGIN
              DROP TABLE IF EXISTS #TEMP
 CREATE TABLE  #TEMP ([DBName] NVARCHAR(128), [Status] INT)

              INSERT INTO #TEMP ([DBName], [Status])
              SELECT ds.[DBName], 0
              FROM [MsAdmin].dbo.DatabaseSettings ds
              JOIN sys.databases sb
                     ON ds.DBName COLLATE DATABASE_DEFAULT = sb.name COLLATE DATABASE_DEFAULT
              WHERE ds.SchemaTracking = 1 AND ds.HealthReport = 1 AND ds.[DBName] NOT LIKE 'AdventureWorks%'
              AND (sb.user_access = 0 OR sb.user_access = 1 AND sb.database_id NOT IN (SELECT r.database_id 
                                                                                                                                                FROM sys.dm_exec_sessions s
                                                                                                                                                JOIN sys.dm_exec_requests r
                                                                                                                                                       ON s.session_id = r.session_id))

              SET @DBName = (SELECT TOP 1 [DBName] FROM #TEMP WHERE [Status] = 0)

              WHILE @DBName IS NOT NULL
              BEGIN

                     SET @SQL = 

                     'SELECT ObjectName,CreateDate,LoginName,ComputerName,SQLEvent,[DBName]
                     FROM '+ '[' + @DBName + ']' +'.dbo.SchemaChangeLog
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
       DROP TABLE IF EXISTS  #LOGSPACE 
 CREATE TABLE  #LOGSPACE (
              [DBName] NVARCHAR(128) NOT NULL,
              [LogSize] NUMERIC(20,2) NOT NULL,
              [LogPercentUsed] NUMERIC(12,2) NOT NULL,
              [LogStatus] INT NOT NULL
              )

       DROP TABLE IF EXISTS #DATASPACE
 CREATE TABLE  #DATASPACE (
              [DBName] NVARCHAR(128) NULL,
              [Fileid] INT NOT NULL,
              [FileGroup] INT NOT NULL,
              [TotalExtents] NUMERIC(20,2) NOT NULL,
              [UsedExtents] NUMERIC(20,2) NOT NULL,
              [FileLogicalName] NVARCHAR(128) NULL,
              [FileName] NVARCHAR(255) NOT NULL
              )

       DROP TABLE IF EXISTS #TMP_DB
 CREATE TABLE  #TMP_DB (
              [DBName] NVARCHAR(128)
              ) 

       SET @SQL = 'DBCC SQLPERF (LOGSPACE) WITH NO_INFOMSGS' 

       INSERT INTO #LOGSPACE ([DBName],LogSize,LogPercentUsed,LogStatus)
       EXEC(@SQL)

       INSERT INTO #TMP_DB 
       SELECT LTRIM(RTRIM(d.name)) AS [DBName]
       FROM sys.databases d
       LEFT OUTER
       JOIN [MsAdmin].dbo.DatabaseSettings ds
              ON d.Name COLLATE DATABASE_DEFAULT = ds.DBName COLLATE DATABASE_DEFAULT AND ds.HealthReport = 1  
       WHERE d.is_subscribed = 0
       AND d.[state] = 0
       AND (d.user_access = 0 OR d.user_access = 1 AND d.database_id NOT IN (SELECT r.database_id 
                                                                                                                                                FROM sys.dm_exec_sessions s
                                                                                                                                                JOIN sys.dm_exec_requests r
                                                                                                                                                       ON s.session_id = r.session_id))

       SET @DBName = (SELECT MIN([DBName]) FROM #TMP_DB)

       WHILE @DBName IS NOT NULL 
       BEGIN
              SET @SQL = 'USE ' + '[' +@DBName + ']' + '
              DBCC SHOWFILESTATS WITH NO_INFOMSGS'

              INSERT INTO #DATASPACE ([Fileid],[FileGroup],[TotalExtents],[UsedExtents],[FileLogicalName],[FileName])
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
                     [FileName],
                     [LogicalFileName],
                     [FileGroup],
                     [FileMBSize],
                     [FileMaxSize],
                     [FileGrowth],
                     [FileMBUsed],
                     [FileMBEmpty],
                     [FilePercentEmpty])
              SELECT DBName = ''' + '[' + @dbname + ']' + ''',
                           DB_ID() AS [DBID],
                           SF.fileid AS [FileID],
                           LEFT(SF.[filename], 1) AS DriveLetter,          
                     LTRIM(RTRIM(REVERSE(SUBSTRING(REVERSE(SF.[filename]),0,CHARINDEX(''\'',REVERSE(SF.[filename]),0))))) AS [Filename],
                           SF.name AS LogicalFileName,
                           COALESCE(filegroup_name(SF.groupid),'''') AS [FileGroup],
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
              JOIN sys.databases SDB
                     ON DB_ID() = SDB.[database_id]
              JOIN sys.dm_io_virtual_file_stats(NULL,NULL) b
                     ON DB_ID() = b.[database_id] AND SF.fileid = b.[file_id]
              LEFT OUTER 
              JOIN #DATASPACE DSP
                     ON DSP.[Filename] COLLATE DATABASE_DEFAULT = SF.[filename] COLLATE DATABASE_DEFAULT
              LEFT OUTER 
              JOIN #LOGSPACE LSP
                     ON LSP.[DBName] = SDB.name
              GROUP BY SDB.name,SF.fileid,SF.[filename],SF.name,SF.groupid,SF.size,SF.maxsize,SF.[status],growth,DSP.UsedExtents,LSP.LogSize,LSP.LogPercentUsed'

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
       JOIN (SELECT database_id, [file_id], num_of_reads, num_of_bytes_read, num_of_writes, num_of_bytes_written, io_stall_read_ms, io_stall_write_ms, 
                           CAST(SUM(num_of_bytes_read + num_of_bytes_written) / 1048576 AS DECIMAL(12, 2)) / 1024 AS CumIOGB,
                           CAST(CAST(SUM(num_of_bytes_read + num_of_bytes_written) / 1048576 AS DECIMAL(12, 2)) / 1024 / 
                                  SUM(CAST(SUM(num_of_bytes_read + num_of_bytes_written) / 1048576 AS DECIMAL(12, 2)) / 1024) OVER() * 100 AS DECIMAL(5, 2)) AS IOPercent
                     FROM sys.dm_io_virtual_file_stats(NULL,NULL)
                     GROUP BY database_id, [file_id],num_of_reads, num_of_bytes_read, num_of_writes, num_of_bytes_written, io_stall_read_ms, io_stall_write_ms) AS b
       ON f.[DBID] = b.[database_id] AND f.FileID = b.[file_id]

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
       DROP TABLE IF EXISTS #VLFINFO
 CREATE TABLE  #VLFINFO (
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
                     SET @SQL = 'USE ' + '[' + @DBName + ']' + '
                     INSERT INTO #VLFINFO (RecoveryUnitID, FileID,FileSize,StartOffset,FSeqNo,[Status],Parity,CreateLSN)
                     EXEC(''DBCC LOGINFO WITH NO_INFOMSGS'');'
                     EXEC(@SQL)

                     SET @SQL = 'UPDATE #VLFINFO SET DBName = ''' + @DBName + ''' WHERE DBName IS NULL;'
                     EXEC(@SQL)

                     SET @DBName = (SELECT MIN([DBName]) FROM #TMP_DB WHERE [DBName] > @DBName)
              END
       END

       SET @DBName = (SELECT MIN([DBName]) FROM #TMP_DB)

       WHILE @DBName IS NOT NULL 
       BEGIN
              SET @SQL = 'SELECT '''+ @DBName +''' AS [Database Name], 
              Name AS [Orphaned User],
              [uid] AS [UID],
              createdate AS CreateDate,
              updatedate AS UpdateDate
              FROM ' + QUOTENAME(@DBName) + '..sysusers su
              WHERE su.islogin = 1
              AND su.name NOT IN (''guest'',''sys'',''INFORMATION_SCHEMA'',''dbo'')
              AND NOT EXISTS (SELECT *
                                         FROM master..syslogins sl
                                         WHERE su.sid = sl.sid)'

              INSERT INTO #ORPHANEDUSERS
              EXEC(@SQL)

              SET @DBName = (SELECT MIN([DBName]) FROM #TMP_DB WHERE [DBName] > @DBName)
       END

       DROP TABLE #TMP_DB

       UPDATE a
       SET a.VLFCount = (SELECT COUNT(1) FROM #VLFINFO WHERE [DBName] = REPLACE(REPLACE(a.DBName,'[',''),']',''))
       FROM #FILESTATS a
       WHERE COALESCE(a.[FileGroup],'') = ''

       IF @ShowFullFileInfo = 1
       BEGIN
              SELECT @MinFileStatsDateStamp = MIN(FileStatsDateStamp) FROM [MsAdmin].dbo.FileStatsHistory WHERE FileStatsDateStamp >= DateAdd(hh, -24, GETDATE())

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
                                         b.DBName,
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
                                         JOIN [MsAdmin].dbo.FileStatsHistory a
                                                ON a.DBName COLLATE DATABASE_DEFAULT = b.DBName COLLATE DATABASE_DEFAULT 
                                                AND a.[FileName] COLLATE DATABASE_DEFAULT = b.[FileName] COLLATE DATABASE_DEFAULT
                                                AND a.FileStatsDateStamp = @MinFileStatsDateStamp) d
                                  ON c.DBName = d.DBName 
                                  AND c.[FileName] = d.[FileName]
                     END
              END
       END

       /* JobStats */
       DROP TABLE IF EXISTS #TEMPJOB
 CREATE TABLE  #TEMPJOB (
              Job_ID NVARCHAR(255),
              [Owner] NVARCHAR(255),     
              Name NVARCHAR(128),
              Category NVARCHAR(128),
              [Enabled] BIT,
              Last_Run_Outcome INT,
              Last_Run_Date NVARCHAR(20)
              )

       INSERT INTO #TEMPJOB (Job_ID,[Owner],Name,Category,[Enabled],Last_Run_Outcome,Last_Run_Date)
       SELECT sj.job_id,
              SUSER_SNAME(sj.owner_sid) AS [Owner],
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

       INSERT INTO #JOBSTATUS (JobName,[Owner],Category,[Enabled],StartTime,StopTime,AvgRunTime,LastRunTime,RunTimeStatus,LastRunOutcome)
       SELECT
              t.name AS JobName,
              t.[Owner],
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
                           AVG    ((run_duration/10000 * 3600) + ((run_duration%10000)/100*60) + (run_duration%10000)%100) +       STDEV ((run_duration/10000 * 3600) + 
                                  ((run_duration%10000)/100*60) + (run_duration%10000)%100) AS [AvgRunTime]
                     FROM msdb..sysjobhistory(nolock)
                     WHERE step_id = 0 AND run_status = 1 and run_duration >= 0
                     GROUP BY job_id) art 
              ON t.job_id = art.job_id
       GROUP BY t.name,t.[Owner],t.Category,t.[Enabled],t.last_run_outcome,ja.start_execution_date,ja.stop_execution_date,AvgRunTime
       ORDER BY t.name

       DROP TABLE #TEMPJOB

       --/* Replication Distributor */
       --DROP TABLE IF EXISTS 
-- CREATE TABLE  #REPLINFO (
       --     distributor NVARCHAR(128) NULL, 
       --     [distribution database] NVARCHAR(128) NULL, 
       --     directory NVARCHAR(500), 
       --     account NVARCHAR(200), 
       --     [min distrib retention] INT, 
       --     [max distrib retention] INT, 
       --     [history retention] INT,
       --     [history cleanup agent] NVARCHAR(500),
       --     [distribution cleanup agent] NVARCHAR(500),
       --     [rpc server name] NVARCHAR(200),
       --     [rpc login name] NVARCHAR(200),
       --     publisher_type NVARCHAR(200)
       --     )

       --INSERT INTO #REPLINFO
       --EXEC sp_helpdistributor

       --/* Replication Publisher */     
 --      DROP TABLE IF EXISTS #PUBINFO
 --CREATE TABLE  #PUBINFO (
 --      --     publisher_db NVARCHAR(128),
 --      --     publication NVARCHAR(128),
 --      --     publication_id INT,
 --      --     publication_type INT,
 --      --     [status] INT,
 --      --     warning INT,
 --      --     worst_latency INT,
 --      --     best_latency INT,
 --      --     average_latency INT,
 --      --     last_distsync DATETIME,
 --      --     [retention] INT,
 --      --     latencythreshold INT,
 --      --     expirationthreshold INT,
 --      --     agentnotrunningthreshold INT,
 --      --     subscriptioncount INT,
 --      --     runningdisagentcount INT,
 --      --     snapshot_agentname NVARCHAR(128) NULL,
 --      --     logreader_agentname NVARCHAR(128) NULL,
 --      --     qreader_agentname NVARCHAR(128) NULL,
 --      --     worst_runspeedperf INT,
 --      --     best_runspeedperf INT,
 --      --     average_runspeedperf INT,
 --      --     retention_period_unit INT
 --      --     )
              
 --      --SELECT @Distributor = distributor, @DistributionDB = [distribution database] FROM #REPLINFO

 --      --IF @Distributor = @@SERVERNAME
 --      --BEGIN
 --      --     SET @DistSQL = 
 --      --     'USE ' + @DistributionDB + '; EXEC sp_replmonitorhelppublication @@SERVERNAME

 --      --     INSERT 
 --      --     INTO #PUBINFO
 --      --     EXEC sp_replmonitorhelppublication @@SERVERNAME'

 --      --     EXEC(@DistSQL)
 --      --END

 --      --/* Replication Subscriber */
 --      --DROP TABLE IF EXISTS 
 --CREATE TABLE  #REPLSUB (
 --      --     Publisher NVARCHAR(128),
 --      --     Publisher_DB NVARCHAR(128),
 --      --     Publication NVARCHAR(128),
 --      --     Distribution_Agent NVARCHAR(128),
 --      --     [Time] DATETIME,
 --      --     Immediate_Sync BIT
 --      --     )

 --      --INSERT INTO #REPLSUB
 --      --EXEC master.sys.sp_MSForEachDB 'USE [?]; 
 --      --                                                     IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name = ''MSreplication_subscriptions'') 
 --      --                                                     BEGIN 
 --      --                                                     SELECT publisher AS Publisher,publisher_db AS Publisher_DB,publication AS Publication,distribution_agent AS Distribution_Agent,[Time],immediate_sync AS Immediate_Sync FROM MSreplication_subscriptions 
 --      --                                                     END'

       /* Databases */
       DROP TABLE IF EXISTS #DATABASES
 CREATE TABLE  #DATABASES (
              Database_ID INT,
              [DBName] NVARCHAR(128),
              CreateDate DATETIME,
              RestoreDate DATETIME,
              LastBackupDate DATETIME,
              [Size(GB] NUMERIC(20,5),
              [State] NVARCHAR(20),
              [Recovery] NVARCHAR(20),
              [Replication] NVARCHAR(5) DEFAULT('No'),
              Mirroring NVARCHAR(5) DEFAULT('No')
              )

       INSERT INTO #DATABASES (Database_ID,[DBName],CreateDate,RestoreDate,LastBackupDate,[Size(GB],[State],[Recovery])
       SELECT MST.Database_id,MST.Name,MST.create_date,rs.RestoreDate,bs.LastBackupDate,SUM(CONVERT(DECIMAL,(f.FileMBSize)) / 1024) AS [Size(GB],MST.state_desc,MST.recovery_model_desc
       FROM sys.databases MST
       LEFT OUTER
       JOIN [MsAdmin].dbo.DatabaseSettings ds
              ON MST.name COLLATE DATABASE_DEFAULT = ds.DBName COLLATE DATABASE_DEFAULT AND ds.HealthReport = 1
       JOIN #FILESTATS f
              ON MST.database_id = f.[DBID]
       LEFT OUTER
       JOIN (SELECT destination_database_name AS DBName,
                     MAX(restore_date) AS RestoreDate
                     FROM msdb..restorehistory
                     GROUP BY destination_database_name) AS rs
              ON MST.Name = rs.DBName
       LEFT OUTER
       JOIN (SELECT database_name AS DBName,
                     MAX(backup_finish_date) AS LastBackupDate
                     FROM msdb..backupset bs
                     GROUP BY database_name) AS bs
              ON MST.Name = bs.DBName
       GROUP BY MST.database_id,MST.Name,MST.create_date,rs.RestoreDate,bs.LastBackupDate,MST.state_desc,MST.recovery_model_desc

       --UPDATE d
       --SET d.Mirroring = 'Yes'
       --FROM #DATABASES d
       --JOIN sys.database_mirroring b
       --     ON b.database_id = d.Database_ID
       --WHERE b.mirroring_state IS NOT NULL

       --UPDATE d
       --SET d.[Replication] = 'Yes'
       --FROM #DATABASES d
       --JOIN #REPLSUB r
       --     ON d.[DBName] COLLATE DATABASE_DEFAULT = r.Publication COLLATE DATABASE_DEFAULT

       --UPDATE d
       --SET d.[Replication] = 'Yes'
       --FROM #DATABASES d
       --JOIN #PUBINFO p
       --     ON d.[DBName] COLLATE DATABASE_DEFAULT = p.publisher_db COLLATE DATABASE_DEFAULT

       --UPDATE d
       --SET d.[Replication] = 'Yes'
       --FROM #DATABASES d
       --JOIN #REPLINFO r
       --     ON d.[DBName] COLLATE DATABASE_DEFAULT = r.[distribution database] COLLATE DATABASE_DEFAULT

       --/* LogShipping */
       --DROP TABLE IF EXISTS 
-- CREATE TABLE  #LOGSHIP (
       --     Primary_Server SYSNAME,
       --     Primary_Database SYSNAME,
       --     Monitor_Server SYSNAME,
       --     Secondary_Server SYSNAME,
       --     Secondary_Database SYSNAME,
       --     Last_Backup_Date DATETIME,
       --     Last_Backup_File NVARCHAR(500),
       --     Backup_Share NVARCHAR(500)
       --     )      
       
       --INSERT INTO #LOGSHIP (Primary_Server, Primary_Database, Monitor_Server, Secondary_Server, Secondary_Database, Last_Backup_Date, Last_Backup_File, Backup_Share)
       --SELECT b.primary_server AS Primary_Server, b.primary_database AS Primary_Database, a.monitor_server AS Monitor_Server, c.secondary_server AS Secondary_Server, c.secondary_database AS Secondary_Database, a.last_backup_date AS Last_Backup_Date, a.last_backup_file AS Last_Backup_File, a.backup_share AS Backup_Share
       --FROM msdb..log_shipping_primary_databases a
       --JOIN  msdb..log_shipping_monitor_primary b
       --     ON a.primary_id = b.primary_id
       --JOIN msdb..log_shipping_primary_secondaries c
       --     ON a.primary_id = c.primary_id

       --/* Mirroring */
       --DROP TABLE IF EXISTS 
 --CREATE TABLE  #MIRRORING (
       --     [DBName] NVARCHAR(128),
       --     [State] NVARCHAR(50),
       --     [ServerRole] NVARCHAR(25),
       --     [PartnerInstance] NVARCHAR(128),
       --     [SafetyLevel] NVARCHAR(25),
       --     [AutomaticFailover] NVARCHAR(128),
       --     WitnessServer NVARCHAR(128)
       --     )

       --INSERT INTO #MIRRORING ([DBName], [State], [ServerRole], [PartnerInstance], [SafetyLevel], [AutomaticFailover], [WitnessServer])
       --SELECT s.name AS [DBName], 
       --     m.mirroring_state_desc AS [State], 
       --     m.mirroring_role_desc AS [ServerRole], 
       --     m.mirroring_partner_instance AS [PartnerInstance],
       --     CASE WHEN m.mirroring_safety_level_desc = 'FULL' THEN 'HIGH SAFETY' ELSE 'HIGH PERFORMANCE' END AS [SafetyLevel], 
       --     CASE WHEN m.mirroring_witness_name <> '' THEN 'Yes' ELSE 'No' END AS [AutomaticFailover],
       --     CASE WHEN m.mirroring_witness_name <> '' THEN m.mirroring_witness_name ELSE 'N/A' END AS [WitnessServer]
       --FROM sys.databases s
       --JOIN [MsAdmin].dbo.DatabaseSettings ds
       --     ON s.Name COLLATE DATABASE_DEFAULT = ds.DBName COLLATE DATABASE_DEFAULT
       --JOIN sys.database_mirroring m
       --     ON s.database_id = m.database_id
       --WHERE m.mirroring_state IS NOT NULL
       --AND ds.HealthReport = 1

       /* ErrorLog */
       DROP TABLE IF EXISTS #DEADLOCKINFO
 CREATE TABLE  #DEADLOCKINFO (
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

       DROP TABLE IF EXISTS #ERRORLOG
 CREATE TABLE  #ERRORLOG (
              ID INT IDENTITY(1,1) NOT NULL
                     CONSTRAINT PK_ERRORLOGTEMP
                           PRIMARY KEY CLUSTERED (ID),
              LogDate DATETIME, 
              ProcessInfo NVARCHAR(100), 
              [Text] NVARCHAR(4000)
              )
              
       DROP TABLE IF EXISTS #TEMPDATES
 CREATE TABLE  #TEMPDATES (LogDate DATETIME)

       INSERT INTO #ERRORLOG
       EXEC sp_readerrorlog 0, 1

       IF EXISTS (SELECT * FROM #TRACESTATUS WHERE TraceFlag = 1222)
       BEGIN
              INSERT INTO #TEMPDATES (LogDate)
              SELECT DISTINCT CONVERT(NVARCHAR(30),LogDate,120) as LogDate
              FROM #ERRORLOG
              WHERE ProcessInfo LIKE 'spid%'
              and [Text] LIKE '   process id=%'

              INSERT INTO #DEADLOCKINFO (DeadLockDate, DBName, ProcessInfo, VictimHostname, VictimLogin, VictimSPID, LockingHostname, LockingLogin, LockingSPID)
              SELECT 
              DISTINCT CONVERT(NVARCHAR(30),b.LogDate,120) AS DeadlockDate,
              DB_NAME(SUBSTRING(RTRIM(SUBSTRING(b.[Text],PATINDEX('%currentdb=%',b.[Text]),(PATINDEX('%lockTimeout%',b.[Text])) - (PATINDEX('%currentdb=%',b.[Text]))  )),11,50)) as DBName,
              b.ProcessInfo,
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
              GROUP BY b.LogDate,b.ProcessInfo, a.[Text], b.[Text]

              DELETE FROM #ERRORLOG
              WHERE CONVERT(NVARCHAR(30),LogDate,120) IN (SELECT DeadlockDate FROM #DEADLOCKINFO)

              DELETE FROM #DEADLOCKINFO
              WHERE (DeadlockDate <  CONVERT(DATETIME, CONVERT (NVARCHAR(10), GETDATE(), 101)) -1)
              OR (DeadlockDate >= CONVERT(DATETIME, CONVERT (NVARCHAR(10), GETDATE(), 101)))
       END

       DELETE FROM #ERRORLOG
       WHERE LogDate < (GETDATE() -1)
       OR ProcessInfo = 'Backup'

       /* BackupStats */
       DROP TABLE IF EXISTS #BACKUPS
 CREATE TABLE  #BACKUPS (
              ID INT IDENTITY(1,1) NOT NULL
                     CONSTRAINT PK_BACKUPS
                           PRIMARY KEY CLUSTERED (ID),
              [DBName] NVARCHAR(128),
              [Type] NVARCHAR(50),
              [FileName] NVARCHAR(255),
              Backup_Set_Name NVARCHAR(255),
              Backup_Start_Date DATETIME,
              Backup_Finish_Date DATETIME,
              Backup_Size NUMERIC(20,2),
              Backup_Age INT
              )

       IF @ShowBackups = 1
       BEGIN
              INSERT INTO #BACKUPS ([DBName],[Type],[FileName],Backup_Set_Name,Backup_Start_Date,Backup_Finish_Date,Backup_Size,Backup_Age)
              SELECT a.database_name AS [DBName],
                           CASE a.[type]
                           WHEN 'D' THEN 'Full'
                           WHEN 'I' THEN 'Diff'
                           WHEN 'L' THEN 'Log'
                           WHEN 'F' THEN 'File/FileGroup'
                           WHEN 'G' THEN 'File Diff'
                           WHEN 'P' THEN 'Partial'
                           WHEN 'Q' THEN 'Partial Diff'
                           ELSE 'Unknown' END AS [Type],
                           COALESCE(b.physical_device_name,'N/A') AS [FileName],
                           a.name AS Backup_Set_Name,        
                           a.backup_start_date AS Backup_Start_Date,
                           a.backup_finish_date AS Backup_Finish_Date,
                           CAST((a.backup_size/1024)/1024/1024 AS DECIMAL(10,2)) AS Backup_Size,
                           DATEDIFF(hh, MAX(a.backup_finish_date), GETDATE()) AS [Backup_Age] 
              FROM msdb..backupset a
              LEFT OUTER
              JOIN [MsAdmin].dbo.DatabaseSettings ds
                     ON a.database_name COLLATE DATABASE_DEFAULT = ds.DBName COLLATE DATABASE_DEFAULT AND ds.HealthReport = 1
              JOIN msdb..backupmediafamily b
                     ON a.media_set_id = b.media_set_id
              WHERE a.backup_start_date > GETDATE() -1
              GROUP BY a.database_name, a.[type],a.name, b.physical_device_name,a.backup_start_date,a.backup_finish_date,a.backup_size
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
              <table width="1250"> <tr><th class="header" width="1250">System</th></tr></table></div><div>
              <table width="1250">
              <tr>
              <th width="225">Name</th>
              <th width="325">Processor</th>    
              <th width="275">Operating System</th>    
              <th width="125">Total Memory (GB)</th>
              <th width="200">Uptime</th>
              <th width="75">Clustered</th>     
              </tr>'
       SELECT @HTML = @HTML + 
              '<tr><td width="225" class="c1">'+@ServerName +'</td>' +
              '<td width="325" class="c2">'+@Processor +'</td>' +
              '<td width="275" class="c1">'+@ServerOS +'</td>' +
              '<td width="125" class="c2">'+@SystemMemory+'</td>' +  
              '<td width="200" class="c1">'+@Days+' days, '+@Hours+' hours & '+@Minutes+' minutes' +'</td>' +
              '<td width="75" class="c2"><b>'+@ISClustered+'</b></td></tr>'
       SELECT @HTML = @HTML +     '</table></div>'

       SELECT @HTML = @HTML + 
       '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">SQL Server</th></tr></table></div><div>
              <table width="1250">
              <tr>
              <th width="400">Version</th>      
              <th width="130">Start Up Date</th>
              <th width="100">Used Memory (MB)</th>
              <th width="170">Collation</th>
              <th width="75">User Mode</th>
              <th width="75">SQL Agent</th>     
              </tr>'
       SELECT @HTML = @HTML + 
              '<tr><td width="400" class="c1">'+@SQLVersion +'</td>' +
              '<td width="130" class="c2">'+CAST(@ServerStartDate AS NVARCHAR)+'</td>' +
              '<td width="100" class="c1">'+@ServerMemory+'</td>' +
              '<td width="170" class="c2">'+@ServerCollation+'</td>' +
              CASE WHEN @SingleUser = 'Multi' THEN '<td width="75" class="c1"><b>Multi</b></td>'  
                      WHEN @SingleUser = 'Single' THEN '<td width="75" bgcolor="#FFFF00"><b>Single</b></td>'
              ELSE '<td width="75" bgcolor="#FF0000"><b>UNKNOWN</b></td>'
              END +  
              CASE WHEN @SQLAgent = 'Up' THEN '<td width="75" bgcolor="#00FF00"><b>Up</b></td></tr>'  
                      WHEN @SQLAgent = 'Down' THEN '<td width="75" bgcolor="#FF0000"><b>DOWN</b></td></tr>'  
              ELSE '<td width="75" bgcolor="#FF0000"><b>UNKNOWN</b></td></tr>'  
              END

       SELECT @HTML = @HTML + '</table></div>'

       IF @ShowModifiedServerConfig = 1
       BEGIN
              SELECT @HTML = @HTML + 
                     '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">SQL Server Configuration - Modified Settings</th></tr></table></div><div>
                     <table width="1250">
                       <tr>
                           <th width="300">Configuration Name</th>
                           <th width="425">Configuration Description</th>
                           <th width="125">Default Value</th>
                           <th width="125">Current Value</th>
                           <th width="125">Dynamic Setting</th>
                            <th width="150">Advanced Setting</th>                                       
                     </tr>'
              SELECT @HTML = @HTML +
                     '<tr><td width="300" class="c1">' + COALESCE([ConfigName],'N/A') +'</td>' +
                     '<td width="425" class="c2">' + COALESCE([ConfigDesc],'N/A') +'</td>' +           
                     '<td width="125" class="c1">' + COALESCE(CAST([DefaultValue] AS NVARCHAR),'N/A') +'</td>' +
                     '<td width="125" class="c2">' + COALESCE(CAST([CurrentValue] AS NVARCHAR),'N/A') +'</td>' +           
                     '<td width="125" class="c1">' + COALESCE(CAST([Is_Dynamic] AS NVARCHAR),'N/A') +'</td>' +
                     '<td width="150" class="c2">' + COALESCE(CAST([Is_Advanced] AS NVARCHAR),'N/A') +'</td>' + '</tr>'
              FROM #SERVERCONFIGSETTINGS WHERE DefaultValue <> CurrentValue ORDER BY ConfigName

              SELECT @HTML = @HTML + '</table></div>'
       END

       SELECT @HTML = @HTML +
       '&nbsp;<table width="1250"><tr><td class="master" width="975" rowspan="3">
              <div><table width="975"> <tr><th class="header" width="975">Databases</th></tr></table></div><div>
              <table width="975">
                <tr>
                     <th width="205">Database</th>
                     <th width="140">Create Date</th>
                     <th width="140">Restore Date</th>
                     <th width="140">Last Backup Date</th>           
                     <th width="80">Size (GB)</th>
                     <th width="60">State</th>
                     <th width="75">Recovery</th>
                     <th width="75">Replicated</th>
                     <th width="60">Mirrored</th>
              </tr>'
       SELECT @HTML = @HTML +   
              '<tr><td width="205" class="c1">' + COALESCE([DBName],'N/A') +'</td>' +
              '<td width="140" class="c2">' + COALESCE(CAST(CreateDate AS NVARCHAR),'N/A') +'</td>' +
              '<td width="140" class="c1">' + COALESCE(CAST(RestoreDate AS NVARCHAR),'N/A') +'</td>' +
              CASE
                     WHEN COALESCE(LastBackupDate,'') = '' THEN '<td width="140" bgColor="#FF0000">' + 'N/A' +'</td>'
                     WHEN COALESCE(LastBackupDate,'') <= DATEADD(dd, -7, GETDATE()) THEN '<td width="140" bgColor="#FFFF00">' + CAST(LastBackupDate AS NVARCHAR) +'</td>'
                     WHEN COALESCE(LastBackupDate,'') <> '' AND COALESCE(LastBackupDate,'') > DATEADD(dd, -7, GETDATE()) THEN '<td width="140" bgColor="#00FF00">' + CAST(LastBackupDate AS NVARCHAR) +'</td>'                
              ELSE '<td width="140" bgColor="#FF0000">' + 'N/A' +'</td>'
              END + 
              '<td width="80" class="c1">' + COALESCE(CAST([Size(GB] AS NVARCHAR),'N/A') +'</td>' +    
              CASE [State]    
                     WHEN 'OFFLINE' THEN '<td width="60" bgColor="#FF0000"><b>OFFLINE</b></td>'
                     WHEN 'ONLINE' THEN '<td width="60" class="c2">ONLINE</td>'  
              ELSE '<td width="60" bgcolor="#FFFF00"><b>UNKNOWN</b></td>'
              END +
              '<td width="75" class="c1">' + COALESCE([Recovery],'N/A') +'</td>' +
              '<td width="75" class="c2">' + COALESCE([Replication],'N/A') +'</td>' +
              '<td width="60" class="c1">' + COALESCE(Mirroring,'N/A') +'</td></tr>'            
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
              '<tr><td width="50" class="c1">' + COALESCE(DriveLetter,'N/A') + ':' +'</td>' +    
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
                     '<tr><td width="175" class="c1">' + COALESCE(NodeName,'N/A') +'</td>' +    
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
              SELECT @HTML = @HTML + '<tr><td width="65" class="c1">' + COALESCE(CAST([TraceFlag] AS NVARCHAR),'N/A') + '</td>' +    
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

       IF @ShowDatabaseSettings = 1
       BEGIN
              SELECT @HTML = @HTML + 
                     '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Database Settings</th></tr></table></div><div>
                     <table width="1250">
                       <tr>
                           <th width="225">Database</th>
                           <th width="190">Owner</th>               
                           <th width="100">Compat. Level</th>              
                           <th width="100">User Access</th>
                           <th width="75">Read Only</th>
                           <th width="125">AutoCreate Stats</th>
                           <th width="125">AutoUpdate Stats</th>
                           <th width="100">Quoted Identifier</th>
                           <th width="60">FullText</th>
                           <th width="75">Trustworthy</th>
                           <th width="75">Encryption</th>
                     </tr>'
              SELECT @HTML = @HTML +
                     '<tr><td width="225" class="c1">' + COALESCE([DBName],'N/A') +'</td>' +
                     '<td width="190" class="c2">' + COALESCE([Owner],'N/A') +'</td>' +                
                     '<td width="100" class="c1">' + COALESCE(CAST([Compatibility_Level] AS NVARCHAR),'N/A') +'</td>' +       
                     '<td width="100" class="c2">' + COALESCE([User_Access_Desc],'N/A') +'</td>' +              
                     CASE
                           WHEN is_read_only = 0 THEN '<td width="75" class="c1">' + 'No' +'</td>'
                           WHEN is_read_only = 1 THEN '<td width="75" class="c1">' + 'Yes' +'</td>'                     
                           ELSE '<td width="75" class="c1">' + 'N/A' +'</td>'
                           END +
                     CASE
                           WHEN is_auto_create_stats_on = 0 THEN '<td width="125" class="c2">' + 'No' +'</td>'
                           WHEN is_auto_create_stats_on = 1 THEN '<td width="125" class="c2">' + 'Yes' +'</td>'                    
                           ELSE '<td width="125" class="c2">' + 'N/A' +'</td>'
                           END +
                     CASE
                           WHEN is_auto_update_stats_on = 0 THEN '<td width="125" class="c1">' + 'No' +'</td>'
                           WHEN is_auto_update_stats_on = 1 THEN '<td width="125" class="c1">' + 'Yes' +'</td>'                    
                           ELSE '<td width="125" class="c1">' + 'N/A' +'</td>'
                           END +
                     CASE
                           WHEN is_quoted_identifier_on = 0 THEN '<td width="100" class="c2">' + 'No' +'</td>'
                           WHEN is_quoted_identifier_on = 1 THEN '<td width="100" class="c2">' + 'Yes' +'</td>'                    
                           ELSE '<td width="100" class="c2">' + 'N/A' +'</td>'
                           END +
                     CASE
                           WHEN is_fulltext_enabled = 0 THEN '<td width="60" class="c1">' + 'No' +'</td>'
                           WHEN is_fulltext_enabled = 1 THEN '<td width="60" class="c1">' + 'Yes' +'</td>'                   
                           ELSE '<td width="60" class="c1">' + 'N/A' +'</td>'
                           END +
                     CASE
                           WHEN is_trustworthy_on = 0 THEN '<td width="75" class="c2">' + 'No' +'</td>'
                           WHEN is_trustworthy_on = 1 THEN '<td width="75" class="c2">' + 'Yes' +'</td>'                   
                           ELSE '<td width="75" class="c2">' + 'N/A' +'</td>'
                           END +
                     CASE
                           WHEN is_encrypted = 0 THEN '<td width="75" class="c1">' + 'No' +'</td>'
                           WHEN is_encrypted = 1 THEN '<td width="75" class="c1">' + 'Yes' +'</td>'                     
                           ELSE '<td width="75" class="c1">' + 'N/A' +'</td>'
                           END + '</tr>'
              FROM #DATABASESETTINGS
              ORDER BY DBName

              SELECT @HTML = @HTML + '</table></div>'
       END

       IF EXISTS (SELECT * FROM #ORPHANEDUSERS) AND @ShowOrphanedUsers = 1
       BEGIN
              SELECT 
                     @HTML = @HTML +
                     '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Orphaned Users</th></tr></table></div><div>
                     <table width="1250">
                     <tr>
                     <th width="300">Database</th>
                     <th width="250">Username</th>
                     <th width="100">UID</th>
                     <th width="250">Date Created</th>
                     <th width="250">Last Date Updated</th>                        
                     </tr>'
              SELECT
                     @HTML = @HTML +
                     '<tr>
                     <td width="300" class="c1">' + COALESCE(DBName,'N/A') +'</td>' +
                     '<td width="250" class="c2">' + COALESCE(OrphanedUser,'N/A') +'</td>' +
                     '<td width="100" class="c1">' + COALESCE(CAST([UID] AS NVARCHAR),'N/A') +'</td>' +                    
                     '<td width="250" class="c2">' + COALESCE(CAST(CreateDate AS NVARCHAR),'N/A') +'</td>' +
                     '<td width="250" class="c1">' + COALESCE(CAST(UpdateDate AS NVARCHAR),'N/A') +'</td>' +                 
                     '</tr>'
              FROM #ORPHANEDUSERS
              ORDER BY [DBName], [OrphanedUser]

              SELECT @HTML = @HTML + '</table></div>'
       END ELSE
       BEGIN
              IF @ShowEmptySections = 1
              BEGIN
                     SELECT 
                           @HTML = @HTML +
                           '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Orphaned Users</th></tr></table></div><div>
                           <table width="1250">   
                                  <tr> 
                                         <th width="1250">There are no orphaned users in any user databases</th>
                                  </tr>'

                     SELECT @HTML = @HTML + '</table></div>'
              END
       END

       SELECT @HTML = @HTML + 
              '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">File Info</th></tr></table></div><div>
              <table width="1250">
                <tr>
                     <th width="200">Database</th>
                     <th width="50">Drive</th>
                     <th width="250">FileName</th>
                     <th width="200">Logical Name</th>
                     <th width="100">Group</th>
                     <th width="75">VLF Count</th>
                     <th width="75">Size (MB)</th>
                     <th width="75">Growth</th>
                     <th width="75">Used (MB)</th>
                     <th width="75">Empty (MB)</th>
                     <th width="75">% Empty</th>
              </tr>'
       SELECT @HTML = @HTML +
              '<tr><td width="200" class="c1">' + COALESCE(REPLACE(REPLACE([DBName],'[',''),']',''),'N/A') +'</td>' +
              '<td width="50" class="c2">' + COALESCE(DriveLetter,'N/A') + ':' +'</td>' +
              '<td width="250" class="c1">' + COALESCE([FileName],'N/A') +'</td>' +
              '<td width="200" class="c2">' + COALESCE([LogicalFileName],'N/A') +'</td>' +      
              CASE
                     WHEN COALESCE([FileGroup],'') <> '' THEN '<td width="100" class="c1">' + COALESCE([FileGroup],'N/A') +'</td>'
                     ELSE '<td width="100" class="c1">' + 'N/A' +'</td>'
                     END +
              '<td width="75" class="c2">' + COALESCE(CAST(VLFCount AS NVARCHAR),'N/A') +'</td>' +
              CASE
                     WHEN (LargeLDF = 1 AND [FileName] LIKE '%ldf') THEN '<td width="75" bgColor="#FFFF00">' + COALESCE(CAST(FileMBSize AS NVARCHAR),'N/A') +'</td>'
                     ELSE '<td width="75" class="c1">' + COALESCE(CAST(FileMBSize AS NVARCHAR),'N/A') +'</td>'
                     END +
              '<td width="75" class="c2">' + COALESCE(FileGrowth,'N/A') +'</td>' +
              '<td width="75" class="c1">' + COALESCE(CAST(FileMBUsed AS NVARCHAR),'N/A') +'</td>' +
              '<td width="75" class="c2">' + COALESCE(CAST(FileMBEmpty AS NVARCHAR),'N/A') +'</td>' +
              '<td width="75" class="c1">' + COALESCE(CAST(FilePercentEmpty AS NVARCHAR),'N/A') + '</td>' + '</tr>'
       FROM #FILESTATS
       ORDER BY DBName,[FileName]

       SELECT @HTML = @HTML + '</table></div>'

       IF @ShowFullFileInfo = 1
       BEGIN
              SELECT @HTML = @HTML + 
                     '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">File Stats - Last 24 Hours</th></tr></table></div><div>
                     <table width="1250">
                       <tr>
                           <th width="225">FileName</th>
                           <th width="100"># Reads</th>
                           <th width="175">KBytes Read</th>
                           <th width="100"># Writes</th>
                           <th width="175">KBytes Written</th>
                           <th width="125">IO Read Wait (MS)</th>
                           <th width="125">IO Write Wait (MS)</th>
                           <th width="125">Cumulative IO (GB)</th>
                           <th width="100">IO %</th>                       
                     </tr>'
              SELECT @HTML = @HTML +
                     '<tr><td width="225" class="c1">' + COALESCE([FileName],'N/A') +'</td>' +
                     '<td width="100" class="c2">' + COALESCE(CAST(NumberReads AS NVARCHAR),'0') +'</td>' +
                     '<td width="175" class="c1">' + COALESCE(CONVERT(NVARCHAR(50), KBytesRead),'0') + ' (' + COALESCE(CONVERT(NVARCHAR(50), CAST(KBytesRead / 1024 AS NUMERIC(18,2))),'0') +
                             ' MB)' +'</td>' +
                     '<td width="100" class="c2">' + COALESCE(CAST(NumberWrites AS NVARCHAR),'0') +'</td>' +
                     '<td width="175" class="c1">' + COALESCE(CONVERT(NVARCHAR(50), KBytesWritten),'0') + ' (' + COALESCE(CONVERT(NVARCHAR(50), CAST(KBytesWritten / 1024 AS NUMERIC(18,2)) ),'0') +
                             ' MB)' +'</td>' +
                     '<td width="125" class="c2">' + COALESCE(CAST(IoStallReadMS AS NVARCHAR),'0') +'</td>' +
                     '<td width="125" class="c1">' + COALESCE(CAST(IoStallWriteMS AS NVARCHAR),'0') + '</td>' +
                     '<td width="125" class="c2">' + COALESCE(CAST(Cum_IO_GB AS NVARCHAR),'0') + '</td>' +
                     '<td width="100" class="c1">' + COALESCE(CAST(IO_Percent AS NVARCHAR),'0') + '</td>' + '</tr>'    
              FROM #FILESTATS
              ORDER BY [FileName]

              SELECT @HTML = @HTML + '</table></div>'
       END

       --IF EXISTS (SELECT * FROM #MIRRORING)
       --BEGIN
       --     SELECT 
       --            @HTML = @HTML +
       --            '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Mirroring</th></tr></table></div><div>
       --            <table width="1250">   
       --            <tr> 
       --            <th width="250">Database</th>      
       --            <th width="150">State</th>   
       --            <th width="150">Server Role</th>   
       --            <th width="150">Partner Instance</th>
       --            <th width="150">Safety Level</th>
       --            <th width="200">Automatic Failover</th>
       --            <th width="250">Witness Server</th>   
       --            </tr>' 
       --     SELECT
       --            @HTML = @HTML +   
       --            '<tr><td width="250" class="c1">' + COALESCE([DBName],'N/A') +'</td>' +
       --            '<td width="150" class="c2">' + COALESCE([State],'N/A') +'</td>' +  
       --            '<td width="150" class="c1">' + COALESCE([ServerRole],'N/A') +'</td>' +  
       --            '<td width="150" class="c2">' + COALESCE([PartnerInstance],'N/A') +'</td>' +  
       --            '<td width="150" class="c1">' + COALESCE([SafetyLevel],'N/A') +'</td>' +  
       --            '<td width="200" class="c2">' + COALESCE([AutomaticFailover],'N/A') +'</td>' +  
       --            '<td width="250" class="c1">' + COALESCE([WitnessServer],'N/A') +'</td>' +  
       --            '</tr>'
       --     FROM #MIRRORING
       --     ORDER BY [DBName]

       --     SELECT @HTML = @HTML + '</table></div>'
       --END ELSE
       --BEGIN
       --     IF @ShowEmptySections = 1
       --     BEGIN
       --            SELECT 
       --                   @HTML = @HTML +
       --                   '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Mirroring</th></tr></table></div><div>
       --                   <table width="1250">   
       --                         <tr> 
       --                                <th width="1250">Mirroring is not setup on this system</th>
       --                         </tr>'

       --            SELECT @HTML = @HTML + '</table></div>'
       --     END
       --END

       --IF EXISTS (SELECT * FROM #LOGSHIP)
       --BEGIN
       --     SELECT 
       --            @HTML = @HTML +
       --            '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Log Shipping</th></tr></table></div><div>
       --            <table width="1250">   
       --            <tr> 
       --            <th width="200">Primary Server</th>      
       --            <th width="150">Primary DB</th>   
       --            <th width="200">Monitoring Server</th>   
       --            <th width="150">Secondary Server</th>
       --            <th width="150">Secondary DB</th>
       --            <th width="200">Last Backup Date</th>
       --            <th width="250">Backup Share</th>   
       --            </tr>'
       --     SELECT
       --            @HTML = @HTML +   
       --            '<tr><td width="200" class="c1">' + COALESCE(Primary_Server,'N/A') +'</td>' +
       --            '<td width="150" class="c2">' + COALESCE(Primary_Database,'N/A') +'</td>' +  
       --            '<td width="200" class="c1">' + COALESCE(Monitor_Server,'N/A') +'</td>' +  
       --            '<td width="150" class="c2">' + COALESCE(Secondary_Server,'N/A') +'</td>' +  
       --            '<td width="150" class="c1">' + COALESCE(Secondary_Database,'N/A') +'</td>' +  
       --            '<td width="200" class="c2">' + COALESCE(CAST(Last_Backup_Date AS NVARCHAR),'N/A') +'</td>' +  
       --            '<td width="250" class="c1">' + COALESCE(Backup_Share,'N/A') +'</td>' +  
       --            '</tr>'
       --     FROM #LOGSHIP
       --     ORDER BY Primary_Database

       --     SELECT @HTML = @HTML + '</table></div>'
       --END ELSE
       --BEGIN
       --     IF @ShowEmptySections = 1
       --     BEGIN
       --            SELECT 
       --                   @HTML = @HTML +
       --                   '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Log Shipping</th></tr></table></div><div>
       --                   <table width="1250">   
       --                         <tr> 
       --                                <th width="1250">Log Shipping is not setup on this system</th>
       --                         </tr>'

       --            SELECT @HTML = @HTML + '</table></div>'
       --     END
       --END

       --IF EXISTS (SELECT * FROM #REPLINFO WHERE distributor IS NOT NULL)
       --BEGIN
       --     SELECT 
       --            @HTML = @HTML +
       --            '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Replication Distributor</th></tr></table></div><div>
       --            <table width="1250">   
       --                   <tr> 
       --                         <th width="200">Distributor</th>      
       --                         <th width="200">Distribution DB</th>   
       --                         <th width="500">Replcation Share</th>   
       --                         <th width="200">Replication Account</th>
       --                         <th width="150">Publisher Type</th>
       --                   </tr>'
       --     SELECT
       --            @HTML = @HTML +   
       --            '<tr><td width="200" class="c1">' + COALESCE(distributor,'N/A') +'</td>' +
       --            '<td width="200" class="c2">' + COALESCE([distribution database],'N/A') +'</td>' +  
       --            '<td width="500" class="c1">' + COALESCE(CAST(directory AS NVARCHAR),'N/A') +'</td>' +  
       --            '<td width="200" class="c2">' + COALESCE(CAST(account AS NVARCHAR),'N/A') +'</td>' +  
       --            '<td width="150" class="c1">' + COALESCE(CAST(publisher_type AS NVARCHAR),'N/A') +'</td></tr>'
       --     FROM #REPLINFO

       --     SELECT @HTML = @HTML + '</table></div>'
       --END ELSE
       --BEGIN
       --     IF @ShowEmptySections = 1
       --     BEGIN
       --            SELECT 
       --                   @HTML = @HTML +
       --                   '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Replication Distributor</th></tr></table></div><div>
       --                   <table width="1250">   
       --                         <tr> 
       --                                <th width="1250">Distributor is not setup on this system</th>
       --                         </tr>'

       --            SELECT @HTML = @HTML + '</table></div>'
       --     END
       --END

       --IF EXISTS (SELECT * FROM #PUBINFO)
       --BEGIN
       --     SELECT 
       --            @HTML = @HTML +
       --            '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Replication Publisher</th></tr></table></div><div>
       --            <table width="1250">   
       --            <tr> 
       --            <th width="200">Publisher DB</th>      
       --            <th width="200">Publication</th>   
       --            <th width="150">Publication Type</th>   
       --            <th width="75">Status</th>
       --            <th width="100">Warnings</th>
       --            <th width="125">Best Latency</th>
       --            <th width="125">Worst Latency</th>
       --            <th width="125">Average Latency</th>
       --            <th width="150">Last Dist Sync</th>                           
       --            </tr>'
       --     SELECT
       --            @HTML = @HTML +   
       --            '<tr> 
       --            <td width="200" class="c1">' + COALESCE(publisher_db,'N/A') +'</td>' +
       --            '<td width="200" class="c2">' + COALESCE(publication,'N/A') +'</td>' +  
       --            CASE
       --                   WHEN publication_type = 0 THEN '<td width="150" class="c1">' + 'Transactional Publication' +'</td>'
       --                   WHEN publication_type = 1 THEN '<td width="150" class="c1">' + 'Snapshot Publication' +'</td>'
       --                   WHEN publication_type = 2 THEN '<td width="150" class="c1">' + 'Merge Publication' +'</td>'
       --                   ELSE '<td width="150" class="c1">' + 'N/A' +'</td>'
       --            END +
       --            CASE
       --                   WHEN [status] = 1 THEN '<td width="75" class="c2">' + 'Started' +'</td>'
       --                   WHEN [status] = 2 THEN '<td width="75" class="c2">' + 'Succeeded' +'</td>'
       --                   WHEN [status] = 3 THEN '<td width="75" class="c2">' + 'In Progress' +'</td>'
       --                   WHEN [status] = 4 THEN '<td width="75" class="c2">' + 'Idle' +'</td>'
       --                   WHEN [status] = 5 THEN '<td width="75" class="c2">' + 'Retrying' +'</td>'
       --                   WHEN [status] = 6 THEN '<td width="75" class="c2">' + 'Failed' +'</td>'
       --                   ELSE '<td width="75" class="c2">' + 'N/A' +'</td>'
       --            END +
       --            CASE
       --                   WHEN Warning = 1 THEN '<td width="100" bgcolor="#FFFF00">' + 'Expiration' +'</td>'
       --                   WHEN Warning = 2 THEN '<td width="100" bgcolor="#FFFF00">' + 'Latency' +'</td>'
       --                   WHEN Warning = 4 THEN '<td width="100" bgcolor="#FFFF00">' + 'Merge Expiration' +'</td>'
       --                   WHEN Warning = 8 THEN '<td width="100" bgcolor="#FFFF00">' + 'Merge Fast Run Duration' +'</td>'
       --                   WHEN Warning = 16 THEN '<td width="100" bgcolor="#FFFF00">' + 'Merge Slow Run Duration' +'</td>'
       --                   WHEN Warning = 32 THEN '<td width="100" bgcolor="#FFFF00">' + 'Marge Fast Run Speed' +'</td>'
       --                   WHEN Warning = 64 THEN '<td width="100" bgcolor="#FFFF00">' + 'Merge Slow Run Speed' +'</td>'
       --                   ELSE '<td width="100" class="c1">' + 'N/A'                                                                                                
       --            END +
       --            CASE
       --                   WHEN publication_type = 0 THEN '<td width="125" class="c2">' + COALESCE(CAST(best_latency AS NVARCHAR),'N/A') +'</td>'
       --                   WHEN publication_type = 1 THEN '<td width="125" class="c2">' + COALESCE(CAST(best_runspeedperf AS NVARCHAR),'N/A') +'</td>'
       --            END +
       --            CASE
       --                   WHEN publication_type = 0 THEN '<td width="125" class="c1">' + COALESCE(CAST(worst_latency AS NVARCHAR),'N/A') +'</td>'
       --                   WHEN publication_type = 1 THEN '<td width="125" class="c1">' + COALESCE(CAST(worst_runspeedperf AS NVARCHAR),'N/A') +'</td>'
       --            END +
       --            CASE
       --                   WHEN publication_type = 0 THEN '<td width="125" class="c2">' + COALESCE(CAST(average_latency AS NVARCHAR),'N/A') +'</td>'
       --                   WHEN publication_type = 1 THEN '<td width="125" class="c2">' + COALESCE(CAST(average_runspeedperf AS NVARCHAR),'N/A') +'</td>'
       --            END +
       --            '<td width="150" class="c1">' + COALESCE(CAST(Last_DistSync AS NVARCHAR),'N/A') +'</td>' + 
       --            '</tr>'
       --     FROM #PUBINFO

       --     SELECT @HTML = @HTML + '</table></div>'
       --END ELSE
       --BEGIN
       --     IF @ShowEmptySections = 1
       --     BEGIN
       --            SELECT 
       --                   @HTML = @HTML +
       --                   '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Replication Publisher</th></tr></table></div><div>
       --                   <table width="1250">   
       --                         <tr> 
       --                                <th width="1250">Publisher is not setup on this system</th>
       --                         </tr>'

       --            SELECT @HTML = @HTML + '</table></div>'
       --     END
       --END

       --IF EXISTS (SELECT * FROM #REPLSUB)
       --BEGIN
       --     SELECT 
       --            @HTML = @HTML +
       --            '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Replication Subscriptions</th></tr></table></div><div>
       --            <table width="1250">   
       --            <tr> 
       --            <th width="200">Publisher</th>      
       --            <th width="200">Publisher DB</th>   
       --            <th width="150">Publication</th>   
       --            <th width="450">Distribution Job</th>
       --            <th width="150">Last Sync</th>
       --            <th width="100">Immediate Sync</th>
       --            </tr>'
       --     SELECT
       --            @HTML = @HTML +   
       --            '<tr><td width="200" class="c1">' + COALESCE(Publisher,'N/A') +'</td>' +
       --            '<td width="200" class="c2">' + COALESCE(Publisher_DB,'N/A') +'</td>' +  
       --            '<td width="150" class="c1">' + COALESCE(Publication,'N/A') +'</td>' +  
       --            '<td width="450" class="c2">' + COALESCE(Distribution_Agent,'N/A') +'</td>' +  
       --            '<td width="150" class="c1">' + COALESCE(CAST([time] AS NVARCHAR),'N/A') +'</td>' +  
       --            CASE [Immediate_sync]
       --                   WHEN 0 THEN '<td width="100" class="c2">' + 'No'  +'</td>'
       --                   WHEN 1 THEN '<td width="100" class="c2">' + 'Yes'  +'</td>'
       --                   ELSE 'N/A'
       --            END +
       --            '</tr>'
       --     FROM #REPLSUB

       --     SELECT @HTML = @HTML + '</table></div>'
       --END ELSE
       --BEGIN
       --     IF @ShowEmptySections = 1
       --     BEGIN
       --            SELECT 
       --                   @HTML = @HTML +
       --                   '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Replication Subscriptions</th></tr></table></div><div>
       --                   <table width="1250">   
       --                         <tr> 
       --                                <th width="1250">Subscriptions are not setup on this system</th>
       --                         </tr>'

       --            SELECT @HTML = @HTML + '</table></div>'
       --     END
       --END

       IF EXISTS (SELECT * FROM #PERFSTATS) AND @ShowPerfStats = 1
       BEGIN
              SELECT @HTML = @HTML + 
                     '&nbsp;<div><table width="1250"> <tr><th class="Perfthheader" width="1250">Connections - Last 24 Hours</th></tr></table></div><div>
                     <table width="1250">
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
                     '<div><table width="1250"> <tr><th class="Perfthheader" width="1250">Buffer Hit Cache Ratio - Last 24 Hours</th></tr></table></div><div>
                     <table width="1250">
                           <tr>'
              SELECT @HTML = @HTML + '<th class="Perfth"><img src="foo" style="background-color:white;" height="'+ CAST(COALESCE((BufferCacheHitRatio/2),0) AS NVARCHAR) +'" width="10" /></th>'
              FROM #PERFSTATS
              GROUP BY StatDate, BufferCacheHitRatio
              ORDER BY StatDate ASC

              SELECT @HTML = @HTML + '</tr><tr>'
              SELECT @HTML = @HTML + '<td class="Perftd">' + 

              CASE WHEN BufferCacheHitRatio < 98 THEN '<p class="Alert">'+ LEFT(CAST(BufferCacheHitRatio AS NVARCHAR),6) 
                     WHEN BufferCacheHitRatio < 99.5 THEN '<p class="Warning">'+ LEFT(CAST(BufferCacheHitRatio AS NVARCHAR),6) 
              ELSE '<p class="Text2">'+ COALESCE(LEFT(CAST(BufferCacheHitRatio AS NVARCHAR),6),'N/A')
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
                     '&nbsp;<div><table width="1250"> <tr><th class="Perfthheader" width="1250">SQL Server CPU Usage (Percent) - Last 24 Hours</th></tr></table></div><div>
                     <table width="1250">
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
                                  '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">SQL Agent Jobs</th></tr></table></div><div>
                                  <table width="1250"> 
                                  <tr>
                                  <th width="320">Job Name</th>
                                  <th width="200">Owner</th>
                                  <th width="160">Category</th>                          
                                  <th width="60">Enabled</th>
                                  <th width="150">Last Outcome</th>
                                  <th width="140">Last Date Run</th>
                                  <th width="110">AvgRunTime(mi)</th> 
                                  <th width="110">LastRunTime(mi)</th>                          
                                  </tr>'
                           SELECT @HTML = @HTML +   
                                  '<tr><td width="320" class="c1">' + COALESCE(LEFT(JobName,75),'N/A') +'</td>' +
                                  '<td width="200" class="c2">' + COALESCE([Owner],'N/A') +'</td>' +
                                  '<td width="160" class="c1">' + COALESCE(Category,'N/A') +'</td>' +
                                  CASE [Enabled]
                                         WHEN 0 THEN '<td width="60" bgcolor="#FFFF00">False</td>'
                                         WHEN 1 THEN '<td width="60" class="c2">True</td>'
                                  ELSE '<td width="60" class="c2"><b>Unknown</b></td>'
                                  END +
                                 CASE      
                                         WHEN LastRunOutcome = 'ERROR' AND RunTimeStatus = 'NormalRunning-History' THEN '<td width="150" bgColor="#FF0000"><b>FAILED</b></td>'
                                         WHEN LastRunOutcome = 'ERROR' AND RunTimeStatus = 'LongRunning-History' THEN '<td width="150"  bgColor="#FF0000"><b>ERROR - Long Running</b></td>'  
                                         WHEN LastRunOutcome = 'SUCCESS' AND RunTimeStatus = 'NormalRunning-History' THEN '<td width="150"  bgColor="#00FF00">Success</td>'  
                                         WHEN LastRunOutcome = 'Success' AND RunTimeStatus = 'LongRunning-History' THEN '<td width="150"  bgColor="#99FF00">Success - Long Running</td>'  
                                         WHEN LastRunOutcome = 'InProcess' THEN '<td width="150" bgColor="#00FFFF">InProcess</td>'  
                                         WHEN LastRunOutcome = 'InProcess' AND RunTimeStatus = 'LongRunning-NOW' THEN '<td width="150" bgColor="#00FFFF">InProcess</td>'  
                                         WHEN LastRunOutcome = 'CANCELLED' THEN '<td width="150" bgColor="#FFFF00"><b>CANCELLED</b></td>'  
                                         WHEN LastRunOutcome = 'NA' THEN '<td width="150" class="c1">NA</td>'  
                                  ELSE '<td width="150" class="c1">NA</td>' 
                                  END +
                                  '<td width="140" class="c2">' + COALESCE(CAST(StartTime AS NVARCHAR),'N/A') + '</td>' +             
                                  '<td width="110" class="c1">' + COALESCE(CONVERT(NVARCHAR(50), CAST(AvgRunTime / 60 AS NUMERIC(12,2))),'') + '</td>' +
                                  '<td width="110" class="c2">' + COALESCE(CONVERT(NVARCHAR(50), CAST(LastRunTime / 60 AS NUMERIC(12,2))),'') + '</td></tr>' 
                           FROM #JOBSTATUS
                           WHERE LastRunOutcome = 'ERROR' OR RunTimeStatus = 'LongRunning-History' OR RunTimeStatus = 'LongRunning-NOW'
                           ORDER BY JobName

                           SELECT @HTML = @HTML + '</table></div>'
                     END
              IF @ShowFullJobInfo = 1
                     BEGIN
                           SELECT @HTML = @HTML + 
                                  '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">SQL Agent Jobs</th></tr></table></div><div>
                                  <table width="1250"> 
                                  <tr>
                                  <th width="320">Job Name</th>
                                  <th width="200">Owner</th>
                                  <th width="160">Category</th>                          
                                  <th width="60">Enabled</th>
                                  <th width="150">Last Outcome</th>
                                  <th width="140">Last Date Run</th>       
                                  <th width="110">AvgRunTime(mi)</th>
                                  <th width="110">LastRunTime(mi)</th>
                                  </tr>'
                           SELECT @HTML = @HTML +   
                                  '<tr><td width="320" class="c1">' + COALESCE(LEFT(JobName,75),'N/A') +'</td>' +
                                  '<td width="200" class="c2">' + COALESCE([Owner],'N/A') +'</td>' +
                                  '<td width="160" class="c1">' + COALESCE(Category,'N/A') +'</td>' +
                                  CASE [Enabled]
                                         WHEN 0 THEN '<td width="60" bgcolor="#FFFF00">False</td>'
                                         WHEN 1 THEN '<td width="60" class="c2">True</td>'
                                  ELSE '<td width="60" class="c2"><b>Unknown</b></td>'
                                  END +
                                 CASE      
                                         WHEN LastRunOutcome = 'ERROR' AND RunTimeStatus = 'NormalRunning-History' THEN '<td width="150" bgColor="#FF0000"><b>FAILED</b></td>'
                                         WHEN LastRunOutcome = 'ERROR' AND RunTimeStatus = 'LongRunning-History' THEN '<td width="150"  bgColor="#FF0000"><b>ERROR - Long Running</b></td>'  
                                         WHEN LastRunOutcome = 'SUCCESS' AND RunTimeStatus = 'NormalRunning-History' THEN '<td width="150"  bgColor="#00FF00">Success</td>'  
                                         WHEN LastRunOutcome = 'Success' AND RunTimeStatus = 'LongRunning-History' THEN '<td width="150"  bgColor="#99FF00">Success - Long Running</td>'  
                                         WHEN LastRunOutcome = 'InProcess' THEN '<td width="150" bgColor="#00FFFF">InProcess</td>'  
                                         WHEN LastRunOutcome = 'InProcess' AND RunTimeStatus = 'LongRunning-NOW' THEN '<td width="150" bgColor="#00FFFF">InProcess</td>'  
                                         WHEN LastRunOutcome = 'CANCELLED' THEN '<td width="150" bgColor="#FFFF00"><b>CANCELLED</b></td>'  
                                         WHEN LastRunOutcome = 'NA' THEN '<td width="150" class="c1">NA</td>'  
                                  ELSE '<td width="150" class="c1">NA</td>' 
                                  END +
                                  '<td width="140" class="c2">' + COALESCE(CAST(StartTime AS NVARCHAR),'N/A') + '</td>' +
                                  '<td width="110" class="c1">' + COALESCE(CONVERT(NVARCHAR(50), CAST(AvgRunTime / 60 AS NUMERIC(12,2))),'') + '</td>' +
                                  '<td width="110" class="c2">' + COALESCE(CONVERT(NVARCHAR(50), CAST(LastRunTime / 60 AS NUMERIC(12,2))),'') + '</td></tr>' 
                           FROM #JOBSTATUS
                           ORDER BY JobName

                           SELECT @HTML = @HTML + '</table></div>'
                     END
       END
                     
       IF EXISTS (SELECT * FROM #LONGQUERIES)
       BEGIN
              SELECT @HTML = @HTML +   
                     '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Long Running Queries</th></tr></table></div><div>
                     <table width="1250">
                     <tr>
                     <th width="150">Date Stamp</th>   
                     <th width="200">Database</th>
                     <th width="75">Time (ss)</th> 
                     <th width="75">SPID</th>   
                     <th width="175">Login</th> 
                     <th width="475">Query Text</th>
                     </tr>'
              SELECT @HTML = @HTML +   
                     '<tr>
                     <td width="150" class="c1">' + COALESCE(CAST(DateStamp AS NVARCHAR),'N/A') +'</td>       
                     <td width="200" class="c2">' + COALESCE([DBName],'N/A') +'</td>
                     <td width="75" class="c1">' + COALESCE(CAST([ElapsedTime(ss)] AS NVARCHAR),'N/A') +'</td>
                     <td width="75" class="c2">' + COALESCE(CAST(Session_ID AS NVARCHAR),'N/A') +'</td>
                     <td width="175" class="c1">' + COALESCE(Login_Name,'N/A') +'</td>    
                     <td width="475" class="c2">' + COALESCE(LEFT(SQL_Text,125),'N/A') +'</td>                
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
                           '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Long Running Queries</th></tr></table></div><div>
                           <table width="1250">   
                                  <tr> 
                                         <th width="1250">There has been no recently recorded long running queries</th>
                                  </tr>'

                     SELECT @HTML = @HTML + '</table></div>'
              END
       END

       IF EXISTS (SELECT * FROM #BLOCKING)
       BEGIN
              SELECT @HTML = @HTML +
                     '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Blocking</th></tr></table></div><div>
                     <table width="1250">
                     <tr> 
                     <th width="150">Date Stamp</th> 
                     <th width="200">Database</th>     
                     <th width="60">Time (ss)</th> 
                     <th width="60">Victim SPID</th>
                     <th width="145">Victim Login</th>
                     <th width="215">Victim SQL Text</th> 
                     <th width="60">Blocking SPID</th> 
                     <th width="145">Blocking Login</th>
                     <th width="215">Blocking SQL Text</th> 
                     </tr>'
              SELECT @HTML = @HTML +   
                     '<tr>
                     <td width="150" class="c1">' + COALESCE(CAST(DateStamp AS NVARCHAR),'N/A') +'</td>
                     <td width="200" class="c2">' + COALESCE([DBName],'N/A') + '</td>
                     <td width="60" class="c1">' + COALESCE(CAST(Blocked_WaitTime_Seconds AS NVARCHAR),'N/A') +'</td>
                     <td width="60" class="c2">' + COALESCE(CAST(Blocked_SPID AS NVARCHAR),'N/A') +'</td>
                     <td width="145" class="c1">' + COALESCE(Blocked_Login,'NA') +'</td>        
                     <td width="215" class="c2">' + COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LEFT(Blocked_SQL_Text,100),'CREATE',''),'TRIGGER',''),'PROCEDURE',''),'FUNCTION',''),'PROC',''),'N/A') +'</td>
                     <td width="60" class="c1">' + COALESCE(CAST(Blocking_SPID AS NVARCHAR),'N/A') +'</td>
                     <td width="145" class="c2">' + COALESCE(Offending_Login,'NA') +'</td>
                     <td width="215" class="c1">' + COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LEFT(Offending_SQL_Text,100),'CREATE',''),'TRIGGER',''),'PROCEDURE',''),'FUNCTION',''),'PROC',''),'N/A') +'</td>       
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
                           '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Blocking</th></tr></table></div><div>
                           <table width="1250">   
                                  <tr> 
                                         <th width="1250">There has been no recently recorded blocking</th>
                                  </tr>'

                     SELECT @HTML = @HTML + '</table></div>'
              END
       END

       IF EXISTS (SELECT * FROM #DEADLOCKINFO)
       BEGIN
              SELECT @HTML = @HTML +
                     '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Deadlocks - Prior Day</th></tr></table></div><div>
                     <table width="1250">
                     <tr> 
                     <th width="150">Date Stamp</th> 
                     <th width="200">Database</th>     
                     <th width="75">Victim Hostname</th> 
                     <th width="100">Victim Login</th>
                     <th width="75">Victim SPID</th>
                     <th width="200">Victim Objects</th>      
                     <th width="75">Locking Hostname</th>
                     <th width="100">Locking Login</th> 
                     <th width="75">Locking SPID</th> 
                     <th width="200">Locking Objects</th>
                     </tr>'
              SELECT @HTML = @HTML +   
                     '<tr>
                     <td width="150" class="c1">' + COALESCE(CAST(DeadlockDate AS NVARCHAR),'N/A') +'</td>
                     <td width="200" class="c2">' + COALESCE([DBName],'N/A') + '</td>' +
                     CASE 
                           WHEN VictimLogin IS NOT NULL THEN '<td width="75" class="c1">' + COALESCE(VictimHostname,'NA') +'</td>'
                     ELSE '<td width="75" class="c1">NA</td>' 
                     END +
                     '<td width="100" class="c2">' + COALESCE(VictimLogin,'NA') +'</td>' +
                     CASE 
                           WHEN VictimLogin IS NOT NULL THEN '<td width="75" class="c1">' + COALESCE(VictimSPID,'NA') +'</td>'
                     ELSE '<td width="75" class="c1">NA</td>' 
                     END +  
                     '<td width="200" class="c2">' + COALESCE(VictimSQL,'N/A') +'</td>
                     <td width="75" class="c1">' + COALESCE(LockingHostname,'N/A') +'</td>
                     <td width="100" class="c2">' + COALESCE(LockingLogin,'N/A') +'</td>
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
                           '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Deadlocks - Previous Day</th></tr></table></div><div>
                           <table width="1250">   
                                  <tr> 
                                         <th width="1250">There has been no recently recorded Deadlocks OR TraceFlag 1222 is not Active</th>
                                  </tr>'

                     SELECT @HTML = @HTML + '</table></div>'
              END
       END

       IF EXISTS (SELECT * FROM #SCHEMACHANGES) AND @ShowSchemaChanges = 1
       BEGIN
              SELECT @HTML = @HTML +
                     '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Schema Changes</th></tr></table></div><div>
                     <table width="1250">
                       <tr>
                            <th width="150">Create Date</th>
                            <th width="200">Database</th>
                           <th width="200">SQL Event</th>                  
                           <th width="350">Object Name</th>
                           <th width="175">Login Name</th>
                           <th width="175">Computer Name</th>
                     </tr>'
              SELECT @HTML = @HTML +   
                     '<tr><td width="150" class="c1">' + COALESCE(CAST(CreateDate AS NVARCHAR),'N/A') +'</td>' +  
                     '<td width="200" class="c2">' + COALESCE([DBName],'N/A') +'</td>' +
                     '<td width="200" class="c1">' + COALESCE(SQLEvent,'N/A') +'</td>' +
                     '<td width="350" class="c2">' + COALESCE(ObjectName,'N/A') +'</td>' +  
                     '<td width="175" class="c1">' + COALESCE(LoginName,'N/A') +'</td>' +  
                     '<td width="175" class="c2">' + COALESCE(ComputerName,'N/A') +'</td></tr>'
              FROM #SCHEMACHANGES
              ORDER BY [DBName], CreateDate

              SELECT 
                     @HTML = @HTML + '</table></div>'
       END ELSE
       BEGIN
              IF EXISTS (SELECT * FROM [MsAdmin].dbo.DatabaseSettings WHERE SchemaTracking = 1) AND @ShowEmptySections = 1
              BEGIN
                     SELECT 
                           @HTML = @HTML +
                           '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Schema Changes</th></tr></table></div><div>
                           <table width="1250">   
                                   <tr> 
                                         <th width="1250">There has been no recently recorded schema changes</th>
                                  </tr>'

                     SELECT @HTML = @HTML + '</table></div>'
              END
              IF NOT EXISTS (SELECT * FROM [MsAdmin].dbo.DatabaseSettings WHERE SchemaTracking = 1) AND @ShowEmptySections = 1
              BEGIN
                     SELECT 
                           @HTML = @HTML +
                           '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Schema Changes</th></tr></table></div><div>
                           <table width="1250">   
                                  <tr> 
                                         <th width="1250">Schema Change Tracking is not enabled on any databases</th>
                                  </tr>'

                     SELECT @HTML = @HTML + '</table></div>'
              END    
       END

       IF EXISTS (SELECT * FROM #ERRORLOG) AND @ShowErrorLog = 1
       BEGIN
              SELECT 
                     @HTML = @HTML +
                     '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Error Log - Last 24 Hours (Does not include backup or deadlock info)</th></tr></table></div><div>
                     <table width="1250">
                     <tr>
                     <th width="150">Log Date</th>
                     <th width="150">Process Info</th>
                     <th width="950">Message</th>
                     </tr>'
              SELECT
                     @HTML = @HTML +
                     '<tr>
                     <td width="150" class="c1">' + COALESCE(CAST(LogDate AS NVARCHAR),'N/A') +'</td>' +
                     '<td width="150" class="c2">' + COALESCE(ProcessInfo,'N/A') +'</td>' +
                     '<td width="950" class="c1">' + COALESCE([Text],'N/A') +'</td>' +
                     '</tr>'
              FROM #ERRORLOG
              ORDER BY LogDate DESC

              SELECT @HTML = @HTML + '</table></div>'
       END ELSE
       BEGIN
              IF @ShowEmptySections = 1
              BEGIN
                     SELECT 
                           @HTML = @HTML +
                           '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Error Log - Last 24 Hours</th></tr></table></div><div>
                           <table width="1250">   
                                  <tr> 
                                         <th width="1250">There has been no recently recorded error log entries</th>
                                  </tr>'

                     SELECT @HTML = @HTML + '</table></div>'
              END
       END

       IF EXISTS (SELECT * FROM #BACKUPS) AND @ShowBackups = 1
       BEGIN
                     SELECT
                           @HTML = @HTML +
                           '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Backup Stats - Last 24 Hours</th></tr></table></div><div>
                           <table width="1250">
                           <tr>
                           <th width="200">Database</th>
                           <th width="90">Type</th>
                           <th width="350">File Name</th>
                           <th width="160">Backup Set Name</th>            
                           <th width="150">Start Date</th>
                           <th width="150">End Date</th>
                           <th width="75">Size (GB)</th>
                           <th width="75">Age (hh)</th>
                           </tr>'
                     SELECT
                           @HTML = @HTML +   
                           '<tr> 
                           <td width="200" class="c1">' + COALESCE([DBName],'N/A') +'</td>' +
                           '<td width="90" class="c2">' + COALESCE([Type],'N/A') +'</td>' +
                           '<td width="350" class="c1">' + COALESCE([FileName],'N/A') +'</td>' +
                           '<td width="160" class="c2">' + COALESCE(Backup_Set_Name,'N/A') +'</td>' +      
                           '<td width="150" class="c1">' + COALESCE(CAST(Backup_Start_Date AS NVARCHAR),'N/A') +'</td>' +  
                           '<td width="150" class="c2">' + COALESCE(CAST(Backup_Finish_Date AS NVARCHAR),'N/A') +'</td>' +  
                           '<td width="75" class="c1">' + COALESCE(CAST(Backup_Size AS NVARCHAR),'N/A') +'</td>' +  
                           '<td width="75" class="c2">' + COALESCE(CAST(Backup_Age AS NVARCHAR),'N/A') +'</td>' +       
                            '</tr>'
                     FROM #BACKUPS
                     WHERE @ShowLogBackups = 1 OR (@ShowLogBackups = 0 AND [Type] <> 'Log')
                     ORDER BY DBName ASC, Backup_Start_Date DESC

                     SELECT @HTML = @HTML + '</table></div>'
       END ELSE
       BEGIN
              IF @ShowEmptySections = 1 AND @ShowBackups = 1
              BEGIN
                     SELECT 
                           @HTML = @HTML +
                           '&nbsp;<div><table width="1250"> <tr><th class="header" width="1250">Backup Stats - Last 24 Hours</th></tr></table></div><div>
                           <table width="1250">   
                                  <tr> 
                                         <th width="1250">No backups have been created on this server in the last 24 hours</th>
                                  </tr>'

                     SELECT @HTML = @HTML + '</table></div>'
              END
       END

       IF @ShowMsAdminSettings = 1
       BEGIN
              SELECT @HTML = @HTML +
              '&nbsp;<table width="1250"><tr><td class="master" width="700" rowspan="3">
                     <div><table width="700"> <tr><th class="header" width="700">MsAdmin Alert Settings</th></tr></table></div><div>
                     <table width="700">
                     <tr>
                           <th width="150">Alert Name</th>
                           <th width="200">Variable Name</th>
                           <th width="50">Value</th>
                           <th width="250">Description</th>         
                           <th width="50">Enabled</th>
                           </tr>'
              SELECT
                           @HTML = @HTML +   
                           '<tr> 
                           <td width="150" class="c1">' + COALESCE([AlertName],'N/A') +'</td>' +
                           '<td width="200" class="c2">' + COALESCE([VariableName],'N/A') +'</td>' +
                           '<td width="50" class="c1">' + COALESCE([Value],'N/A') +'</td>' +
                           '<td width="250" class="c2">' + COALESCE([Description],'N/A') +'</td>' +       
                           '<td width="50" class="c1">' + COALESCE(CAST([Enabled] AS NVARCHAR),'N/A') +'</td>' +
                           '</tr>'
                     FROM [MsAdmin].dbo.AlertSettings
                     ORDER BY AlertName ASC, VariableName ASC

              SELECT @HTML = @HTML + '</table></div>'
              SELECT @HTML = @HTML + '</td><td class="master" width="525" valign="top">'
              SELECT @HTML = @HTML + 
                     '<div><table width="525"> <tr><th class="header" width="525">MsAdmin Database Settings</th></tr></table></div><div>
                     <table width="525">
                           <tr>
                           <th width="150">Database</th>
                           <th width="100">Schema Tracking</th>
                           <th width="100">Log File Alerts</th>
                           <th width="100">Long Query Alerts</th>
                           <th width="75">Reindex</th>
                           </tr>'
              SELECT
                           @HTML = @HTML +   
                           '<tr> 
                           <td width="150" class="c1">' + COALESCE(b.[DBName],'N/A') +'</td>' +
                           '<td width="100" class="c2">' + COALESCE(CAST(b.SchemaTracking AS NVARCHAR),'') +'</td>' +
                           '<td width="100" class="c1">' + COALESCE(CAST(b.LogFileAlerts AS NVARCHAR),'') +'</td>' +
                           '<td width="100" class="c2">' + COALESCE(CAST(b.LongQueryAlerts AS NVARCHAR),'') +'</td>' +   
                           '<td width="75" class="c1">' + COALESCE(CAST(b.Reindex AS NVARCHAR),'') +'</td>' +
                           '</tr>'
              FROM sys.databases a
              LEFT OUTER
              JOIN [MsAdmin].dbo.DatabaseSettings b
                     ON a.name COLLATE DATABASE_DEFAULT = b.DBName COLLATE DATABASE_DEFAULT
              WHERE b.DBName IS NOT NULL
              ORDER BY b.DBName ASC

              SELECT
                           @HTML = @HTML +  
                           '<tr> 
                           <td width="150" class="c1">' + COALESCE(a.name,'N/A') +'</td>' +
                           '<td width="375" bgcolor="#FFFF00" colspan="4">' + 'This database is not listed in the DatabaseSettings table' +'</td>' +
                           '</tr>'
              FROM sys.databases a
              LEFT OUTER
              JOIN [MsAdmin].dbo.DatabaseSettings b
                     ON a.name COLLATE DATABASE_DEFAULT = b.DBName COLLATE DATABASE_DEFAULT
              WHERE b.DBName IS NULL
              ORDER BY a.name ASC

              SELECT
                           @HTML = @HTML +  
                           '<tr> 
                           <td width="150" class="c1">' + COALESCE(b.DBName,'N/A') +'</td>' +
                           '<td width="375" bgcolor="#FFFF00" colspan="4">' + 'This database does NOT exist, but a record exists in DatabaseSettings' +'</td>' +
                           '</tr>'
              FROM [MsAdmin].dbo.DatabaseSettings b
              LEFT OUTER
              JOIN sys.databases a
                     ON a.name COLLATE DATABASE_DEFAULT = b.DBName COLLATE DATABASE_DEFAULT
              WHERE a.name IS NULL
              ORDER BY b.DBName ASC

              SELECT @HTML = @HTML + '</table></div>'
              SELECT @HTML = @HTML + '</td></tr></table>'
       END

       SELECT @HTML = @HTML + '&nbsp;<div><table width="1250"><tr><td class="master">Generated on ' + CAST(GETDATE() AS NVARCHAR) + ' with MsAdmin v2.5.2' + '</td></tr></table></div>'

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
              INSERT INTO [MsAdmin].dbo.HealthReport (GeneratedHTML)
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
       --DROP TABLE #REPLINFO
       --DROP TABLE #PUBINFO
       --DROP TABLE #REPLSUB
       --DROP TABLE #LOGSHIP
       --DROP TABLE #MIRRORING
       DROP TABLE #ERRORLOG
       DROP TABLE #BACKUPS
       DROP TABLE #PERFSTATS
       DROP TABLE #CPUSTATS
       DROP TABLE #DEADLOCKINFO
       DROP TABLE #TEMPDATES
       DROP TABLE #SERVERCONFIGSETTINGS
       DROP TABLE #ORPHANEDUSERS
       DROP TABLE #DATABASESETTINGS      
END

								




GO
