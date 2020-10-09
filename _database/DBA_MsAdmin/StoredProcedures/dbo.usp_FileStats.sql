SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE   PROC [dbo].[usp_FileStats] (@InsertFlag BIT = 0)
AS
/**************************************************************************************************************
**  Purpose: 
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  02/21/2012		Michael Rounds			1.0					Comments creation
**  06/10/2012		Michael Rounds			1.1					Updated to use new FileStatsHistory table
**	08/31/2012		Michael Rounds			1.2					Changed VARCHAR to NVARCHAR
**	11/05/2012		Michael Rounds			2.0					Rewrote to use sysaltfiles instead of looping through sysfiles, gathering more data now too
**  12/17/2012		Michael Rounds			2.1					Apparently sysaltfiles is not good to use, went back to sysfiles, but still using new data gathering method
**	12/27/2012		Michael Rounds			2.1.2				Fixed a bug in gathering data on db's with different coallation
**	01/07/2012		Michael Rounds			2.1.3				Fixed Divide by zero bug
**	04/07/2013		Michael Rounds			2.1.4				Extended the lengths of KBytesRead and KBytesWritte in temp table FILESTATS - NUMERIC(12,2) to (20,2)
**	04/12/2013		Michael Rounds			2.1.5				Added SQL Server 2012 compatibility
**	04/15/2013		Michael Rounds			2.1.6				Expanded Cum_IO_GB
**	04/16/2013		Michael Rounds			2.1.7				Expanded LogSize, TotalExtents and UsedExtents
**	04/17/2013		Michael Rounds			2.1.8				Changed NVARCHAR(30) to BIGINT for Read/Write columns in #FILESTATS and FileMBSize,FileMBUsed,FileMBEmpty
**	04/22/2013		T_Peters from SSC		2.1.9				Added CAST to BIGINT on growth which fixes a bug that caused an arithmetic error
**	05/16/2013		Michael Rounds			2.2					Changed SELECT to use sys.databases instead of master..sysdatabases
**	06/13/2013		Michael Rounds			2.2.1				Added SET NOCOUNT ON
**	06/24/2013		Michael Rounds								Fixed bug preventing report from running when a Single user DB was had an active connection
**	07/23/2013		Michael Rounds			2.3					Tweaked to support Case-sensitive
***************************************************************************************************************/
BEGIN
	SET NOCOUNT ON

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

	DROP TABLE IF EXISTS #LOGSPACE
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

	DECLARE @SQL NVARCHAR(MAX), @DBName NVARCHAR(128), @SQLVer NVARCHAR(20)

	SELECT @SQLVer = LEFT(CONVERT(NVARCHAR(20),SERVERPROPERTY('productversion')),4)

	SET @SQL = 'DBCC SQLPERF (LOGSPACE) WITH NO_INFOMSGS' 

	INSERT INTO #LOGSPACE ([DBName],LogSize,LogPercentUsed,LogStatus)
	EXEC(@SQL)

	CREATE INDEX IDX_tLogSpace_Database ON #LOGSPACE ([DBName])

	INSERT INTO #TMP_DB 
	SELECT LTRIM(RTRIM(name)) AS [DBName]
	FROM sys.databases
	WHERE is_subscribed = 0
	AND [state] = 0
	AND (user_access = 0 OR user_access = 1 AND database_id NOT IN (SELECT r.database_id 
																		FROM sys.dm_exec_sessions s
																		JOIN sys.dm_exec_requests r
																			ON s.session_id = r.session_id))

	CREATE INDEX IDX_TMPDB_Database ON #TMP_DB ([DBName])

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
		SELECT	DBName = ''' + '[' + @DBName + ']' + ''',
				DB_ID() AS [DBID],
				SF.fileid AS [FileID],
				LEFT(SF.[filename], 1) AS DriveLetter,		
				LTRIM(RTRIM(REVERSE(SUBSTRING(REVERSE(SF.[filename]),0,CHARINDEX(''\'',REVERSE(SF.[filename]),0))))) AS [FileName],
				SF.name AS LogicalFileName,
				COALESCE(FILEGROUP_NAME(SF.groupid),'''') AS [FileGroup],
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
			ON DSP.[filename] COLLATE DATABASE_DEFAULT = SF.[filename] COLLATE DATABASE_DEFAULT
		LEFT OUTER 
		JOIN #LOGSPACE LSP
			ON LSP.[DBName] = SDB.name
		GROUP BY SDB.name,SF.FileID,SF.[filename],SF.name,SF.groupid,SF.size,SF.maxsize,SF.[status],growth,DSP.UsedExtents,LSP.LogSize,LSP.LogPercentUsed'

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
				CAST(SUM(num_of_bytes_read + num_of_bytes_written) / 1048576 AS DECIMAL(20,2)) / 1024 AS CumIOGB,
				CAST(CAST(SUM(num_of_bytes_read + num_of_bytes_written) / 1048576 AS DECIMAL(12,2)) / 1024 / 
					SUM(CAST(SUM(num_of_bytes_read + num_of_bytes_written) / 1048576 AS DECIMAL(12,2)) / 1024) OVER() * 100 AS DECIMAL(5, 2)) AS IOPercent
			FROM sys.dm_io_virtual_file_stats(NULL,NULL)
			GROUP BY database_id, [file_id],num_of_reads, num_of_bytes_read, num_of_writes, num_of_bytes_written, io_stall_read_ms, io_stall_write_ms) AS b
	ON f.[DBID] = b.[database_id] AND f.fileid = b.[file_id]

	UPDATE b
	SET b.LargeLDF = 
		CASE WHEN b.FileMBSize > a.FileMBSize THEN 1
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

	DROP TABLE #VLFINFO

	SELECT * FROM #FILESTATS

	IF @InsertFlag = 1
	BEGIN
		DECLARE @FileStatsID INT
		--DECLARE @FileStatsDateStamp DATETIME

		--SET @FileStatsDateStamp = SELECT GETDATE()

		SELECT @FileStatsID = COALESCE(MAX(FileStatsID),0) + 1 FROM [MsAdmin].dbo.FileStatsHistory
		INSERT INTO dbo.FileStatsHistory (FileStatsID, FileStatsDateStamp, [DBName], [DBID], [FileID], [FileName], LogicalFileName, VLFCount, DriveLetter, FileMBSize, FileMaxSize, FileGrowth, FileMBUsed, 
			FileMBEmpty, FilePercentEmpty, LargeLDF, [FileGroup], NumberReads, KBytesRead, NumberWrites, KBytesWritten, IoStallReadMS, IoStallWriteMS, Cum_IO_GB, IO_Percent)
		SELECT @FileStatsID AS FileStatsID,FileStatsDateStamp = GETDATE(), [DBName], [DBID], [FileID], [FileName], LogicalFileName, VLFCount, DriveLetter, FileMBSize, FileMaxSize, FileGrowth, FileMBUsed, 
			FileMBEmpty, FilePercentEmpty, LargeLDF, [FileGroup], NumberReads, KBytesRead, NumberWrites, KBytesWritten, IoStallReadMS, IoStallWriteMS, Cum_IO_GB, IO_Percent
		FROM #FILESTATS
	END
	DROP TABLE #FILESTATS
END

GO
