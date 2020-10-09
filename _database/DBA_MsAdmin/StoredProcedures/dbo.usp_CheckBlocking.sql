SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE   PROCEDURE [dbo].[usp_CheckBlocking] 
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
**	05/16/2013		Michael Rounds			1.2					Changed SELECT to use sys.databases instead of master..sysdatabases
**	07/23/2013		Michael Rounds			1.3					Tweaked to support Case-sensitive
***************************************************************************************************************/
BEGIN
	SET NOCOUNT ON
	 
	IF EXISTS (SELECT * FROM master..sysprocesses WHERE spid > 50 AND blocked != 0 AND ((CAST(waittime AS DECIMAL) /1000) > 0))
	BEGIN
		INSERT INTO [MsAdmin].dbo.BlockingHistory (Blocked_SPID, Blocking_SPID, Blocked_Login, Blocked_HostName, Blocked_WaitTime_Seconds, Blocked_LastWaitType, Blocked_Status, 
			Blocked_Program, Blocked_SQL_Text, Offending_SPID, Offending_Login, Offending_NTUser, Offending_HostName, Offending_WaitType, Offending_LastWaitType, Offending_Status, 
			Offending_Program, Offending_SQL_Text, [DBName])
		SELECT
		a.spid AS Blocked_SPID,
		a.blocked AS Blocking_SPID,
		a.loginame AS Blocked_Login,
		a.hostname AS Blocked_HostName,
		(CAST(a.waittime AS DECIMAL) /1000) AS Blocked_WaitTime_Seconds,
		a.lastwaittype AS Blocked_LastWaitType,
		a.[status] AS Blocked_Status,
		a.[program_name] AS Blocked_Program,
		CAST(st1.[text] AS NVARCHAR(MAX)) as Blocked_SQL_Text,
		b.spid AS Offending_SPID,
		b.loginame AS Offending_Login,
		b.nt_username AS Offending_NTUser,
		b.hostname AS Offending_HostName,
		b.waittime AS Offending_WaitType,
		b.lastwaittype AS Offending_LastWaitType,
		b.[status] AS Offending_Status,
		b.[program_name] AS Offending_Program,
		CAST(st2.text AS NVARCHAR(MAX)) as Offending_SQL_Text,
		(SELECT name from sys.databases WHERE [database_id] = a.[dbid]) AS [DBName]
		FROM master..sysprocesses as a CROSS APPLY sys.dm_exec_sql_text (a.sql_handle) as st1
		JOIN master..sysprocesses as b CROSS APPLY sys.dm_exec_sql_text (b.sql_handle) as st2
		ON a.blocked = b.spid
		WHERE a.spid > 50 AND a.blocked != 0 AND ((CAST(a.waittime AS DECIMAL) /1000) > 0)
	END
END

GO
