SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE   PROC [dbo].[usp_LongRunningJobs]
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
**	01/16/2013		Michael Rounds			1.2					Added "AND JobName <> 'MsAdmin_LongRunningJobsAlert'" to INSERT into TEMP table
**	05/03/2013		Michael Rounds			1.3					Changed how variables are gathered in AlertSettings and AlertContacts
**					Volker.Bachmann								Added "[MsAdmin]" to the start of all email subject lines
**						from SSC
**	06/13/2013		Michael Rounds			1.4					Added SET NOCOUNT ON
**																Added AlertSettings Enabled column to determine if the alert is enabled.
**	07/23/2013		Michael Rounds			1.5					Tweaked to support Case-sensitive
***************************************************************************************************************/
BEGIN
	SET NOCOUNT ON

	EXEC [MsAdmin].dbo.usp_JobStats @InsertFlag=1

	DECLARE @JobStatsID INT, @QueryValue INT, @QueryValue2 INT, @EmailList NVARCHAR(255), @CellList NVARCHAR(255), @HTML NVARCHAR(MAX), @ServerName NVARCHAR(50), @EmailSubject NVARCHAR(100)

	SELECT @ServerName = CONVERT(NVARCHAR(50), SERVERPROPERTY('servername'))

	SET @JobStatsID = (SELECT MAX(JobStatsID) FROM [MsAdmin].dbo.JobStatsHistory)

	SELECT @QueryValue = CAST(Value AS INT) FROM [MsAdmin].dbo.AlertSettings WHERE VariableName = 'QueryValue' AND AlertName = 'LongRunningJobs' AND [Enabled] = 1

	SELECT @QueryValue2 = CAST(Value AS INT) FROM [MsAdmin].dbo.AlertSettings WHERE VariableName = 'QueryValue2' AND AlertName = 'LongRunningJobs' AND [Enabled] = 1
		
	SELECT @EmailList = EmailList,
			@CellList = CellList	
	FROM [MsAdmin].dbo.AlertContacts WHERE AlertName = 'LongRunningJobs'

	DROP TABLE IF EXISTS #TEMP
 CREATE TABLE  #TEMP (
		JobStatsHistoryID INT,
		JobStatsID INT,
		JobStatsDateStamp DATETIME,
		JobName NVARCHAR(255),
		[Enabled] INT,
		StartTime DATETIME,
		StopTime DATETIME,
		AvgRunTime NUMERIC(12,2),
		LastRunTime NUMERIC(12,2),
		RunTimeStatus NVARCHAR(30),
		LastRunOutcome NVARCHAR(20)
		)

	INSERT INTO #TEMP (JobStatsHistoryId, JobStatsID, JobStatsDateStamp, JobName, [Enabled], StartTime, StopTime, AvgRunTime, LastRunTime, RunTimeStatus, LastRunOutcome)
	SELECT  JobStatsID, JobStatsHistoryId , JobStatsDateStamp = GETDATE(), JobName, [Enabled], StartTime, StopTime, AvgRunTime, LastRunTime, RunTimeStatus, LastRunOutcome
	FROM [MsAdmin].dbo.JobStatsHistory
	WHERE RunTimeStatus = 'LongRunning-NOW'
	AND JobName <> 'MsAdmin_LongRunningJobsAlert'
	AND LastRunTime > @QueryValue AND JobStatsID = @JobStatsID
		
	DROP TABLE #TEMP
END

GO
