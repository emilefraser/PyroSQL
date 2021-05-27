SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[usp_CheckFilesWork]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[usp_CheckFilesWork] AS' 
END
GO

ALTER PROC [dba].[usp_CheckFilesWork]
(
	@CheckTempDB BIT = 0,
	@WarnGrowingLogFiles BIT = 0
)
AS

/**************************************************************************************************************
**  Purpose: 
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**	04/25/2013		Matthew Monroe			1.0					Re-factored code out of usp_CheckFiles
**	04/26/2013		Michael Rounds			1.1					Removed "t2" from DELETE to #TEMP3, causing the error 
**																	"The multi-part identifier "t2.FilePercentEmpty" could not be bound"
**	05/03/2013		Michael Rounds			1.2					Removed Parameter MinimumFileSizeMB. Value is now collected from AlertSettings table
**																Changed SELECT from #TEMP to FileStatsHistory since it doesn't exist anymore
**					Volker.Bachmann								Added "[dbWarden]" to the start of all email subject lines
**						from SSC
***************************************************************************************************************/

BEGIN

	SET NOCOUNT ON

	DECLARE @QueryValue INT, 
			@QueryValue2 INT, 
			@HTML NVARCHAR(MAX), 
			@EmailList NVARCHAR(255), 
			@CellList NVARCHAR(255), 
			@ServerName NVARCHAR(128), 
			@EmailSubject NVARCHAR(100), 
			@ReportTitle NVARCHAR(128),
			@MinFileSizeMB INT
	
	SELECT @ServerName = CONVERT(NVARCHAR(128), SERVERPROPERTY('servername'))  
	
	/*Grab AlertSettings for the specified DB category*/
	SELECT @QueryValue = CAST(Value AS INT) FROM dba.AlertSettings WHERE VariableName = 'QueryValue' 
			AND (@CheckTempDB = 0 AND AlertName = 'LogFiles' OR @CheckTempDB = 1 AND AlertName = 'TempDB')
	SELECT @QueryValue2 = CAST(Value AS INT) FROM dba.AlertSettings WHERE VariableName = 'QueryValue2' 
			AND (@CheckTempDB = 0 AND AlertName = 'LogFiles' OR @CheckTempDB = 1 AND AlertName = 'TempDB')
	SELECT @MinFileSizeMB = CAST(Value AS INT) FROM dba.AlertSettings WHERE VariableName = 'MinFileSizeMB' 
			AND (@CheckTempDB = 0 AND AlertName = 'LogFiles' OR @CheckTempDB = 1 AND AlertName = 'TempDB')
	SELECT @EmailList = EmailList,
			@CellList = CellList	
	FROM dba.AlertContacts WHERE @CheckTempDB = 0 AND AlertName = 'LogFiles' OR @CheckTempDB = 1 AND AlertName = 'TempDB'

	/*Populate TEMPLogFiles table with Already Grown Log Files or Already Grown TEMPDB files*/
	CREATE TABLE #TEMPLogFiles (
		[DBName] NVARCHAR(128),
		[Filename] NVARCHAR(255),
		PreviousFileSize BIGINT,
		PrevPercentEmpty NUMERIC(12,2),
		CurrentFileSize BIGINT,
		CurrPercentEmpty NUMERIC(12,2)	
		)

	-- Find log files that have grown
	-- and are at least @MinimumFileSizeMB in size
	INSERT INTO #TEMPLogFiles
	SELECT t.[DBName],t.[Filename],t.FileMBSize AS PreviousFileSize,t.FilePercentEmpty AS PrevPercentEmpty,t2.FileMBSize AS CurrentFileSize,t2.FilePercentEmpty AS CurrPercentEmpty
	FROM dba.FileStatsHistory t
	JOIN dba.FileStatsHistory t2
		ON t.[DBName] = t2.[DBName] 
		AND t.[Filename] = t2.[FileName] 
		AND t.FileStatsID = (SELECT MIN(FileStatsID) FROM dba.FileStatsHistory) 
		AND t2.FileStatsID = (SELECT MAX(FileStatsID) FROM dba.FileStatsHistory)
	WHERE t2.FileMBSize > @MinFileSizeMB
	      AND (@CheckTempDB = 0 AND t2.[Filename] LIKE '%ldf' OR 
	           @CheckTempDB = 1 AND t2.[Filename] LIKE '%mdf')
	      AND t.FileMBSize < t2.FileMBSize
	      AND ( @CheckTempDB = 0 AND t2.[DBName] NOT IN ('model','tempdb','[model]','[tempdb]')
	                             AND t2.[DBName] NOT IN (SELECT [DBName] FROM dba.DatabaseSettings WHERE LogFileAlerts = 0) 
	            OR
	            @CheckTempDB = 1 AND t2.[DBName] IN ('tempdb', '[tempdb]')
	           )
	
	/*Start of Files Already Grown*/
	IF EXISTS (SELECT * FROM #TEMPLogFiles)
	BEGIN
		IF @CheckTempDB = 0		
			SET @ReportTitle = 'Recent Log File Auto-Growth'
		ELSE
			SET @ReportTitle = 'Recent TempDB Auto-Growth'

		SET	@HTML =
			'<html><head><style type="text/css">
			table { border: 0px; border-spacing: 0px; border-collapse: collapse;}
			th {color:#FFFFFF; font-size:12px; font-family:arial; background-color:#7394B0; font-weight:bold;border: 0;}
			th.header {color:#FFFFFF; font-size:13px; font-family:arial; background-color:#41627E; font-weight:bold;border: 0;}
			td {font-size:11px; font-family:arial;border-right: 0;border-bottom: 1px solid #C1DAD7;padding: 5px 5px 5px 8px;}
			</style></head><body>
			<table width="725"> <tr><th class="header" width="725">' + @ReportTitle + '</th></tr></table>
			<table width="725" >
			<tr>  
			<th width="250">Database</th>
			<th width="250">PreviousFileSize</th>
			<th width="250">PrevPercentEmpty</th>
			<th width="250">CurrentFileSize</th>
			<th width="250">CurrPercentEmpty</th>
			</tr>'
		SELECT @HTML =  @HTML +   
			'<tr>
			<td bgcolor="#E0E0E0" width="250">' + [DBName] +'</td>
			<td bgcolor="#F0F0F0" width="250">' + CAST(PreviousFileSize AS NVARCHAR) + '</td>	
			<td bgcolor="#E0E0E0" width="250">' + CAST(PrevPercentEmpty AS NVARCHAR) + '</td>	
			<td bgcolor="#F0F0F0" width="250">' + CAST(CurrentFileSize AS NVARCHAR) + '</td>	
			<td bgcolor="#E0E0E0" width="250">' + CAST(CurrPercentEmpty AS NVARCHAR) + '</td>			
			</tr>'
		FROM #TEMPLogFiles

		SELECT @HTML =  @HTML + '</table></body></html>'

		IF @CheckTempDB = 0		
			SELECT @EmailSubject = '[dbWarden]Log files have Auto-Grown on ' + @ServerName + '!'
		ELSE
			SELECT @EmailSubject = '[dbWarden]TempDB has Auto-Grown on ' + @ServerName + '!'

		IF COALESCE(@EmailList, '') <> ''
		BEGIN
			EXEC msdb..sp_send_dbmail
			@recipients= @EmailList,
			@subject = @EmailSubject,
			@body = @HTML,
			@body_format = 'HTML'
		END
		
		IF COALESCE(@CellList, '') <> ''
		BEGIN
			/*TEXT MESSAGE*/
			SET	@HTML =
				'<html><head></head><body><table><tr><td>Database,</td><td>PrevFileSize,</td><td>CurrFileSize</td></tr>'
			SELECT @HTML =  @HTML +   
				'<tr><td>' + COALESCE([DBName], '') +',</td><td>' + COALESCE(CAST(PreviousFileSize AS NVARCHAR), '') +',</td><td>' + COALESCE(CAST(CurrentFileSize AS NVARCHAR), '') +'</td></tr>'
			FROM #TEMPLogFiles
			SELECT @HTML =  @HTML + '</table></body></html>'

			IF @CheckTempDB = 0		
				SELECT @EmailSubject = '[dbWarden]LDFAutoGrowth-' + @ServerName
			Else
				SELECT @EmailSubject = '[dbWarden]TempDBAutoGrowth-' + @ServerName

			EXEC msdb..sp_send_dbmail
			@recipients= @CellList,
			@subject = @EmailSubject,
			@body = @HTML,
			@body_format = 'HTML'

		END
	END
	/*Stop of Files Already Grown*/	
	
	/* Populate TEMP3 table with log files that are likely to grow (since the amount of free space is below a threshold) */
	CREATE TABLE #TEMP3 (
		[DBName] NVARCHAR(128),
		[FileName] [nvarchar](255),
		FileMBSize INT,
		FileMBUsed INT,
		FileMBEmpty INT,
		FilePercentEmpty NUMERIC(12,2)		
		)
	
	-- Find log files that are less than @QueryValue percent empty	
	-- and are at least @MinimumFileSizeMB in size
	INSERT INTO #TEMP3
	SELECT t.[DBName],t.[Filename],t2.FileMBSize,t2.FileMBUsed,t2.FileMBEmpty,t2.FilePercentEmpty
	FROM dba.FileStatsHistory t
	JOIN dba.FileStatsHistory t2
		ON t.[DBName] = t2.[DBName] 
		AND t.[Filename] = t2.[FileName] 
		AND t.FileStatsID = (SELECT MIN(FileStatsID) FROM dba.FileStatsHistory) 
		AND t2.FileStatsID = (SELECT MAX(FileStatsID) FROM dba.FileStatsHistory)
	WHERE t2.FilePercentEmpty < @QueryValue
	      AND t2.FileMBSize > @MinFileSizeMB
	      AND (@CheckTempDB = 0 AND t2.[Filename] LIKE '%ldf' OR 
	           @CheckTempDB = 1 AND t2.[Filename] LIKE '%mdf')
	      AND t.FileMBSize <> t2.FileMBSize
	      AND ( @CheckTempDB = 0 AND t2.[DBName] NOT IN ('model','tempdb','[model]','[tempdb]')
	                             AND t2.[DBName] NOT IN (SELECT [DBName] FROM dba.DatabaseSettings WHERE LogFileAlerts = 0) 
	            OR
	            @CheckTempDB = 1 AND t2.[DBName] IN ('tempdb', '[tempdb]')
	           )
	
	-- Delete any entries from #TEMP3 that are in #TEMPLogFiles (and thus were already reported)
	DELETE a
	FROM #TEMP3 a
	JOIN #TEMPLogFiles b
		ON a.[DBName] = b.[DBName]
		AND a.[Filename] = b.[Filename]
	
	/*Start of Growing Log Files or Growing TempDB*/
	IF EXISTS (SELECT * FROM #TEMP3) AND @WarnGrowingLogFiles <> 0
	BEGIN
		IF @CheckTempDB = 0		
			SET @ReportTitle = 'Growing Log Files'
		ELSE
			SET @ReportTitle = 'TempDB Growth'
		
		SET	@HTML =
			'<html><head><style type="text/css">
			table { border: 0px; border-spacing: 0px; border-collapse: collapse;}
			th {color:#FFFFFF; font-size:12px; font-family:arial; background-color:#7394B0; font-weight:bold;border: 0;}
			th.header {color:#FFFFFF; font-size:13px; font-family:arial; background-color:#41627E; font-weight:bold;border: 0;}
			td {font-size:11px; font-family:arial;border-right: 0;border-bottom: 1px solid #C1DAD7;padding: 5px 5px 5px 8px;}
			</style></head><body>
			<table width="725"> <tr><th class="header" width="725">' + @ReportTitle + '</th></tr></table>
			<table width="725" >
			<tr>  
			<th width="250">Database</th>
			<th width="250">FileMBSize</th>
			<th width="250">FileMBUsed</th> 
			<th width="250">FileMBEmpty</th>
			<th width="250">FilePercentEmpty</th>
			</tr>'
		SELECT @HTML =  @HTML +   
			'<tr>
			<td bgcolor="#E0E0E0" width="250">' + [DBName] +'</td>
			<td bgcolor="#F0F0F0" width="250">' + CAST(FileMBSize AS NVARCHAR) + '</td>	
			<td bgcolor="#E0E0E0" width="250">' + CAST(FileMBUsed AS NVARCHAR) + '</td>	
			<td bgcolor="#F0F0F0" width="250">' + CAST(FileMBEmpty AS NVARCHAR) + '</td>	
			<td bgcolor="#E0E0E0" width="250">' + CAST(FilePercentEmpty AS NVARCHAR) + '</td>			
			</tr>'
		FROM #TEMP3

		SELECT @HTML =  @HTML + '</table></body></html>'

		IF @CheckTempDB = 0		
			SELECT @EmailSubject = '[dbWarden]Log files are about to Auto-Grow on ' + @ServerName + '!'
		ELSE
			SELECT @EmailSubject = '[dbWarden]TempDB is growing on ' + @ServerName + '!'

		IF COALESCE(@EmailList, '') <> ''
		BEGIN
			EXEC msdb..sp_send_dbmail
			@recipients= @EmailList,
			@subject = @EmailSubject,
			@body = @HTML,
			@body_format = 'HTML'
		END
		
		IF COALESCE(@CellList, '') <> ''
		BEGIN

			IF @QueryValue2 IS NOT NULL
			BEGIN
				-- Remove extra entries from #TEMP3 by filtering on @QueryValue2
				DELETE FROM #TEMP3
				WHERE FilePercentEmpty > @QueryValue2
			END

			/*TEXT MESSAGE*/
			IF EXISTS (SELECT * FROM #TEMP3)
			BEGIN
				IF @CheckTempDB = 0
				BEGIN
					SET	@HTML =
						'<html><head></head><body><table><tr><td>Database,</td><td>FileSize,</td><td>Percent</td></tr>'
					SELECT @HTML =  @HTML +   
						'<tr><td>' + COALESCE([DBName], '') +',</td><td>' + COALESCE(CAST(FileMBSize AS NVARCHAR), '') +',</td><td>' + COALESCE(CAST(FilePercentEmpty AS NVARCHAR), '') +'</td></tr>'
					FROM #TEMP3
					SELECT @HTML =  @HTML + '</table></body></html>'

					SELECT @EmailSubject = '[dbWarden]LDFGrowing-' + @ServerName

				END
				ELSE BEGIN
					SET	@HTML =
						'<html><head></head><body><table><tr><td>FileSize,</td><td>FileEmpty,</td><td>Percent</td></tr>'
					SELECT @HTML =  @HTML +   
						'<tr><td>' + COALESCE(CAST(FileMBSize AS NVARCHAR), '') +',</td><td>' + COALESCE(CAST(FileMBEmpty AS NVARCHAR), '') +',</td><td>' + COALESCE(CAST(FilePercentEmpty AS NVARCHAR), '') +'</td></tr>'
					FROM #TEMP3

					SELECT @HTML =  @HTML + '</table></body></html>'

					SELECT @EmailSubject = '[dbWarden]TempDBGrowing-' + @ServerName
				END
				
				EXEC msdb..sp_send_dbmail
				@recipients= @CellList,
				@subject = @EmailSubject,
				@body = @HTML,
				@body_format = 'HTML'

			END
		END
	END
	/*Stop of Files Growing*/

	DROP TABLE #TEMPLogFiles
	DROP TABLE #TEMP3		
END
GO
