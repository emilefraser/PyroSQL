SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE   PROC [dbo].[usp_CPUProcessAlert]
AS
/**************************************************************************************************************
**  Purpose: 
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  02/29/2012		Michael Rounds			1.0					New Proc to alert on CPU usage
**	08/31/2012		Michael Rounds			1.1					Changed VARCHAR to NVARCHAR
**	05/03/2013		Michael Rounds			1.2					Changed how variables are gathered in AlertSettings and AlertContacts
**					Volker.Bachmann								Added "[MsAdmin]" to the start of all email subject lines
**						from SSC
**	06/13/2013		Michael Rounds			1.3					Added AlertSettings Enabled column to determine if the alert is enabled.
***************************************************************************************************************/
BEGIN
	SET NOCOUNT ON

	DECLARE @QueryValue INT, @QueryValue2 INT, @EmailList NVARCHAR(255), @CellList NVARCHAR(255), @HTML NVARCHAR(MAX), @ServerName NVARCHAR(50), @EmailSubject NVARCHAR(100), @LastDateStamp DATETIME

	SELECT @LastDateStamp = MAX(DateStamp) FROM [MsAdmin].dbo.CPUStatsHistory

	SELECT @ServerName = CONVERT(NVARCHAR(50), SERVERPROPERTY('servername'))

	SELECT @QueryValue = CAST(Value AS INT) FROM [MsAdmin].dbo.AlertSettings WHERE VariableName = 'QueryValue' AND AlertName = 'CPUAlert' AND [Enabled] = 1

	SELECT @QueryValue2 = CAST(Value AS INT) FROM [MsAdmin].dbo.AlertSettings WHERE VariableName = 'QueryValue2' AND AlertName = 'CPUAlert' AND [Enabled] = 1
		
	SELECT @EmailList = EmailList,
		   @CellList = CellList	
	FROM [MsAdmin].dbo.AlertContacts WHERE AlertName = 'CPUAlert'

	DROP TABLE IF EXISTS #TEMP
 CREATE TABLE  #TEMP (
		[SQLProcessPercent] INT,
		[SystemIdleProcessPercent] INT,
		[OtherProcessPerecnt] INT,
		DateStamp DATETIME
		)

	INSERT INTO #TEMP
	EXEC [MsAdmin].dbo.usp_CPUStats

	IF EXISTS (SELECT * FROM #TEMP WHERE SQLProcessPercent > @QueryValue AND DateStamp > COALESCE(@LastDateStamp, GETDATE() -1))
	BEGIN
		SET	@HTML =
			'<html><head><style type="text/css">
			table { border: 0px; border-spacing: 0px; border-collapse: collapse;}
			th {color:#FFFFFF; font-size:12px; font-family:arial; background-color:#7394B0; font-weight:bold;border: 0;}
			th.header {color:#FFFFFF; font-size:13px; font-family:arial; background-color:#41627E; font-weight:bold;border: 0;}
			td {font-size:11px; font-family:arial;border-right: 0;border-bottom: 1px solid #C1DAD7;padding: 5px 5px 5px 8px;}
			</style></head><body>
			<table width="700"> <tr><th class="header" width="700">High CPU Alert</th></tr></table>	
			<table width="700">
			<tr>  
			<th width="150">SQL Percent</th>	
			<th width="150">System Idle Percent</th>  
			<th width="150">Other Process Percent</th>  
			<th width="200">Date Stamp</th>
			</tr>'
		SELECT @HTML =  @HTML +   
			'<tr>
			<td bgcolor="#E0E0E0" width="150">' + CAST(SQLProcessPercent AS NVARCHAR) +'</td>
			<td bgcolor="#F0F0F0" width="150">' + CAST(SystemIdleProcessPercent AS NVARCHAR) +'</td>
			<td bgcolor="#E0E0E0" width="150">' + CAST(OtherProcessPerecnt AS NVARCHAR) +'</td>
			<td bgcolor="#F0F0F0" width="200">' + CAST(DateStamp AS NVARCHAR) +'</td>	
			</tr>'
		FROM #TEMP WHERE SQLProcessPercent > @QueryValue AND DateStamp > COALESCE(@LastDateStamp, GETDATE() -1)

		SELECT @HTML =  @HTML + '</table></body></html>'

		SELECT @EmailSubject = '[MsAdmin]High CPU Alert on ' + @ServerName + '!'

		EXEC msdb..sp_send_dbmail
		@recipients= @EmailList,
		@subject = @EmailSubject,
		@body = @HTML,
		@body_format = 'HTML'

		IF @CellList IS NOT NULL
		BEGIN
			/*TEXT MESSAGE*/
			IF EXISTS (SELECT * FROM #TEMP WHERE SQLProcessPercent > COALESCE(@QueryValue2, @QueryValue))
			BEGIN
				SET	@HTML =
					'<html><head></head><body><table><tr><td>CPU,</td><td>Idle,</td><td>Other,</td><td>Date</td></tr>'
				SELECT @HTML =  @HTML +   
					'<tr><td>' + CAST(SQLProcessPercent AS NVARCHAR) +',</td><td>' + CAST(SystemIdleProcessPercent AS NVARCHAR) +',</td><td>' + CAST(OtherProcessPerecnt AS NVARCHAR) +',</td><td>' + CAST(DateStamp AS NVARCHAR) + '</td></tr>'
				FROM #TEMP WHERE SQLProcessPercent > COALESCE(@QueryValue2, @QueryValue)

				SELECT @HTML =  @HTML + '</table></body></html>'

				SELECT @EmailSubject = '[MsAdmin]HighCPUAlert-' + @ServerName

				EXEC msdb..sp_send_dbmail
				@recipients= @CellList,
				@subject = @EmailSubject,
				@body = @HTML,
				@body_format = 'HTML'

			END
		END
	END

	INSERT INTO [MsAdmin].dbo.CPUStatsHistory ([SQLProcessPercent],[SystemIdleProcessPercent],[OtherProcessPerecnt],DateStamp)
	SELECT [SQLProcessPercent],[SystemIdleProcessPercent],[OtherProcessPerecnt],DateStamp
	FROM #TEMP
	WHERE CONVERT(DATETIME, DateStamp, 120) > CONVERT(DATETIME,COALESCE(@LastDateStamp, GETDATE() -1), 120)
	ORDER BY DATESTAMP ASC

	DROP TABLE #TEMP
END

GO
