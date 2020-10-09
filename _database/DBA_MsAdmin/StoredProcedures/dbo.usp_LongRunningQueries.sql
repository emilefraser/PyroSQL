SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON





CREATE PROC [dbo].[usp_LongRunningQueries]
AS
/**************************************************************************************************************
**  Purpose: 
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  02/21/2012		Michael Rounds			1.0					Comments creation
**	08/31/2012		Michael Rounds			1.1					Changed VARCHAR to NVARCHAR
**	04/22/2013		Michael Rounds			1.2					Simplified to use DMV's to gather session information
**	04/23/2013		Michael Rounds			1.2.1				Adjusted INSERT based on schema changes to QueryHistory, Added Formatted_SQL_Text.
**	05/02/2013		Michael Rounds			1.2.2				Switched login_time to start_time for determining individual long running queries
**																Changed TEMP table to use Formatted_SQL_Text instead of SQL_Text
**																Changed how variables are gathered in AlertSettings and AlertContacts
**	05/03/2013		Volker.Bachmann								Added "[DBA_Monitoring]" to the start of all email subject lines
**						from SSC
**	05/10/2013		Michael Rounds			1.2.3				Changed INSERT into QueryHistory to use EXEC sp_Query
**	05/28/2013		Michael	Rounds			1.3					Changed proc to INSERT into TEMP table and query from TEMP table before INSERT into QueryHistory, improves performance
**																	and resolves a very infrequent bug with the Long Running Queries Job
**	06/11/2013		Michael Rounds			1.3.1				Added COALESCE() to login_name in the event a login_name is NULL
**	06/13/2013		Michael Rounds			1.3.2				Added SET NOCOUNT ON
**																Added AlertSettings Enabled column to determine if the alert is enabled.
**	06/18/2013		Michael Rounds			1.3.3				Fixed HTML output to show RunTime as ElapsedTime(ss)
**	06/28/2013		Michael Rounds			1.3.4				Another attempt at fixing the infrequency "invalid param on LEFT or SUBSTRING" error
**	07/23/2013		Michael Rounds			1.4					Tweaked to support Case-sensitive
***************************************************************************************************************/
BEGIN
SET NOCOUNT ON

	DECLARE @QueryValue INT, @QueryValue2 INT, @EmailList NVARCHAR(255), @CellList NVARCHAR(255), @ServerName NVARCHAR(50), @EmailSubject NVARCHAR(100), @HTML NVARCHAR(MAX)

	SELECT @ServerName = CONVERT(NVARCHAR(50), SERVERPROPERTY('servername'))
	SELECT @QueryValue = CAST(Value AS INT) FROM [DBA_Monitoring].dbo.AlertSettings WHERE VariableName = 'QueryValue' AND AlertName = 'LongRunningQueries' AND [Enabled] = 1
	SELECT @QueryValue2 = COALESCE(CAST(Value AS INT),@QueryValue) FROM [DBA_Monitoring].dbo.AlertSettings WHERE VariableName = 'QueryValue2' AND AlertName = 'LongRunningQueries' AND [Enabled] = 1
	SELECT @EmailList = EmailList,
			@CellList = CellList	
	FROM [DBA_Monitoring].dbo.AlertContacts WHERE AlertName = 'LongRunningQueries'

	CREATE TABLE #QUERYHISTORY (
		[Session_ID] SMALLINT NOT NULL,
		[DBName] NVARCHAR(128) NULL,		
		[RunTime] NUMERIC(20,4) NULL,	
		[Login_Name] NVARCHAR(128) NULL,
		[Formatted_SQL_Text] NVARCHAR(MAX) NULL,
		[SQL_Text] NVARCHAR(MAX) NULL,
		[CPU_Time] BIGINT NULL,	
		[Logical_Reads] BIGINT NULL,
		[Reads] BIGINT NULL,		
		[Writes] BIGINT NULL,
		Wait_Time INT,
		Last_Wait_Type NVARCHAR(60),
		[Status] NVARCHAR(50),
		Blocking_Session_ID SMALLINT,
		Open_Transaction_Count INT,
		Percent_Complete NUMERIC(12,2),
		[Host_Name] NVARCHAR(128) NULL,		
		Client_net_address NVARCHAR(50),
		[Program_Name] NVARCHAR(128) NULL,
		[Start_Time] DATETIME NOT NULL,
		[Login_Time] DATETIME NULL,
		[DateStamp] DATETIME NULL
			CONSTRAINT [DF_QueryHistoryTemp_DateStamp] DEFAULT (GETDATE())
		)

	INSERT INTO #QUERYHISTORY (session_id,DBName,RunTime,login_name,Formatted_SQL_Text,SQL_Text,cpu_time,Logical_Reads,Reads,Writes,wait_time,last_wait_type,[status],blocking_session_id,
								open_transaction_count,percent_complete,[Host_Name],Client_Net_Address,[Program_Name],start_time,login_time,DateStamp)
	EXEC dbo.sp_Sessions;
		
	IF EXISTS (SELECT * FROM #QUERYHISTORY)
	BEGIN
		INSERT INTO dbo.QueryHistory (Session_ID,DBName,RunTime,Login_Name,Formatted_SQL_Text,SQL_Text,CPU_Time,Logical_Reads,Reads,Writes,Wait_Time,Last_Wait_Type,[Status],Blocking_Session_ID,
								Open_Transaction_Count,Percent_Complete,[Host_Name],Client_Net_Address,[Program_Name],Start_Time,Login_Time,DateStamp)
		SELECT Session_ID,DBName,RunTime,COALESCE(Login_Name,'') AS login_name,Formatted_SQL_Text,SQL_Text,CPU_Time,Logical_Reads,Reads,Writes,Wait_Time,Last_Wait_Type,[Status],Blocking_Session_ID,
								Open_Transaction_Count,Percent_Complete,[Host_Name],Client_Net_Address,[Program_Name],Start_Time,Login_Time,DateStamp
		FROM #QUERYHISTORY
	END
	DROP TABLE #QUERYHISTORY
END

GO
