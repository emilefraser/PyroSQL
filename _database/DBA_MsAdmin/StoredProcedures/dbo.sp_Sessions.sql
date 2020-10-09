SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE   PROC [dbo].[sp_Sessions]
AS
/**************************************************************************************************************
**  Purpose: 
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  05/28/2013		Michael Rounds			1.0					New Proc, complete rewrite and replacement for old sp_query. 
**																	Changes include displaying sessions with open transactions,new columns to output and SQL version specific logic
**	07/23/2013		Michael Rounds			1.1					Tweaked to support Case-sensitive
***************************************************************************************************************/
SET NOCOUNT ON

DECLARE @SQLVer NVARCHAR(20)

SELECT @SQLVer = LEFT(CONVERT(NVARCHAR(20),SERVERPROPERTY('productversion')),4)

IF CAST(@SQLVer AS NUMERIC(4,2)) < 11
BEGIN
		-- (SQL 2008R2 And Below)
	EXEC sp_executesql
	N'WITH SessionSQLText AS (
	SELECT
		r.session_id,
		r.total_elapsed_time,
		suser_name(r.user_id) as login_name,
		r.wait_time,
		r.last_wait_type,
		COALESCE(SUBSTRING(qt.[text],(r.statement_start_offset / 2 + 1),LTRIM(LEN(CONVERT(NVARCHAR(MAX), qt.[text]))) * 2 - (r.statement_start_offset) / 2 + 1),'''') AS Formatted_SQL_Text,
		COALESCE(qt.[text],'''') AS Raw_SQL_Text,
		COALESCE(r.blocking_session_id,''0'',NULL) AS blocking_session_id,	
		r.[status],
		COALESCE(r.percent_complete,''0'',NULL) AS percent_complete
	FROM sys.dm_exec_requests r (nolock)
	CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) as qt
	WHERE r.session_id <> @@SPID
	)
	SELECT DISTINCT
		s.session_id AS Session_ID,
		DB_NAME(sp.dbid) AS DBName,
		COALESCE((ssq.total_elapsed_time/1000.0),0) as RunTime,
		CASE WHEN COALESCE(REPLACE(s.login_name,'' '',''''),'''') = '''' THEN ssq.login_name ELSE s.login_name END AS Login_Name,
		COALESCE(ssq.Formatted_SQL_Text,mrsh.[text]) AS Formatted_SQL_Text,
		COALESCE(ssq.Raw_SQL_Text,mrsh.[text]) AS Raw_SQL_Text,
		s.cpu_time AS CPU_Time,
		s.logical_reads AS Logical_Reads,
		s.reads AS Reads,
		s.writes AS Writes,
		ssq.wait_time AS Wait_Time,
		ssq.last_wait_type AS Last_Wait_Type,
		CASE WHEN COALESCE(ssq.[status],'''') = '''' THEN s.[status] ELSE ssq.[status] END AS [Status],
		CASE WHEN ssq.blocking_session_id = ''0'' THEN NULL ELSE ssq.blocking_session_id END AS Blocking_Session_ID,		
		CASE WHEN st.session_id = s.session_id THEN (SELECT COUNT(*) FROM sys.dm_tran_session_transactions WHERE session_id = s.session_id) ELSE 0 END AS Open_Transaction_Count,
		CASE WHEN ssq.percent_complete = ''0'' THEN NULL ELSE ssq.percent_complete END AS Percent_Complete,
		s.[host_name] AS [Host_Name],
		ec.client_net_address AS Client_Net_Address,
		s.[program_name] AS [Program_Name],
		s.last_request_start_time as Start_Time,
		s.login_time AS Login_Time,
		GETDATE() AS DateStamp
	INTO #TEMP
	FROM sys.dm_exec_sessions s (nolock)
	JOIN master..sysprocesses sp
		ON s.session_id = sp.spid
	LEFT OUTER
	JOIN SessionSQLText ssq (nolock) 
		ON ssq.session_id = s.session_id
	LEFT OUTER 
	JOIN sys.dm_tran_session_transactions st (nolock)
		ON st.session_id = s.session_id
	LEFT OUTER
	JOIN sys.dm_tran_active_transactions at (nolock)
		ON st.transaction_id = at.transaction_id
	LEFT OUTER
	JOIN sys.dm_tran_database_transactions dt
		ON at.transaction_id = dt.transaction_id	
	LEFT OUTER
	JOIN sys.dm_exec_connections ec
		ON s.session_id = ec.session_id
	CROSS APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle) as mrsh;
	WITH SessionInfo AS 
	(
	SELECT Session_ID,DBName,RunTime,Login_Name,Formatted_SQL_Text,Raw_SQL_Text,CPU_Time,
		Logical_Reads,Reads,Writes,Wait_Time,Last_Wait_Type,[Status],Blocking_Session_ID,Open_Transaction_Count,Percent_Complete,[Host_Name],Client_Net_Address,
		[Program_Name],Start_Time,Login_Time,DateStamp,ROW_NUMBER() OVER (ORDER BY Session_ID) AS RowNumber
		FROM #TEMP
	)
	SELECT Session_ID,DBName,RunTime,Login_Name,Formatted_SQL_Text,Raw_SQL_Text,CPU_Time,
		Logical_Reads,Reads,Writes,Wait_Time,Last_Wait_Type,[Status],Blocking_Session_ID,Open_Transaction_Count,Percent_Complete,[Host_Name],Client_Net_Address,
		[Program_Name],Start_Time,Login_Time,DateStamp
	FROM SessionInfo WHERE RowNumber IN (SELECT MIN(RowNumber) FROM SessionInfo GROUP BY Session_ID)
	AND Session_ID > 50 
	AND Session_ID <> @@SPID
	AND RunTime > 0
	ORDER BY Session_ID;

	DROP TABLE #TEMP;'	
END
ELSE BEGIN
		-- (SQL 2012 And Above)
	EXEC sp_executesql
	N'WITH SessionSQLText AS (
	SELECT
		r.session_id,
		r.total_elapsed_time,
		suser_name(r.user_id) as login_name,
		r.wait_time,
		r.last_wait_type,		
		COALESCE(SUBSTRING(qt.[text],(r.statement_start_offset / 2 + 1),LTRIM(LEN(CONVERT(NVARCHAR(MAX), qt.[text]))) * 2 - (r.statement_start_offset) / 2 + 1),'''') AS Formatted_SQL_Text,
		COALESCE(qt.[text],'''') AS Raw_SQL_Text,
		COALESCE(r.blocking_session_id,''0'',NULL) AS blocking_session_id,	
		r.[status],
		COALESCE(r.percent_complete,''0'',NULL) AS percent_complete
	FROM sys.dm_exec_requests r (nolock)
	CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) as qt
	WHERE r.session_id <> @@SPID
	)
	SELECT DISTINCT
		s.session_id AS Session_ID,
		DB_NAME(s.database_id) AS DBName,
		COALESCE((ssq.total_elapsed_time/1000.0),0) as RunTime,
		CASE WHEN COALESCE(REPLACE(s.login_name,'' '',''''),'''') = '''' THEN ssq.login_name ELSE s.login_name END AS Login_Name,
		COALESCE(ssq.Formatted_SQL_Text,mrsh.[text]) AS Formatted_SQL_Text,
		COALESCE(ssq.Raw_SQL_Text,mrsh.[text]) AS Raw_SQL_Text,
		s.cpu_time AS CPU_Time,
		s.logical_reads AS Logical_Reads,
		s.reads AS Reads,
		s.writes AS Writes,
		ssq.wait_time AS Wait_Time,
		ssq.last_wait_type AS Last_Wait_Type,
		CASE WHEN COALESCE(ssq.[status],'''') = '''' THEN s.[status] ELSE ssq.[status] END AS [Status],
		CASE WHEN ssq.blocking_session_id = ''0'' THEN NULL ELSE ssq.blocking_session_id END AS Blocking_Session_ID,
		s.open_transaction_count AS Open_Transaction_Count,
		CASE WHEN ssq.percent_complete = ''0'' THEN NULL ELSE ssq.percent_complete END AS Percent_Complete,
		s.[host_name] AS [Host_Name],
		ec.client_net_address AS Client_Net_Address,
		s.[program_name] AS [Program_Name],
		s.last_request_start_time as Start_Time,
		s.login_time AS Login_Time,
		GETDATE() AS DateStamp		
	INTO #TEMP
	FROM sys.dm_exec_sessions s (nolock)
	LEFT OUTER
	JOIN SessionSQLText ssq (nolock) 
		ON ssq.session_id = s.session_id
	LEFT OUTER 
	JOIN sys.dm_tran_session_transactions st (nolock)
		ON st.session_id = s.session_id
	LEFT OUTER
	JOIN sys.dm_tran_active_transactions at (nolock)
		ON st.transaction_id = at.transaction_id
	LEFT OUTER
	JOIN sys.dm_tran_database_transactions dt
		ON at.transaction_id = dt.transaction_id	
	LEFT OUTER
	JOIN sys.dm_exec_connections ec
		ON s.session_id = ec.session_id
	CROSS APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle) as mrsh;
	WITH SessionInfo AS 
	(
	SELECT Session_ID,DBName,RunTime,Login_Name,Formatted_SQL_Text,Raw_SQL_Text,CPU_Time,
		Logical_Reads,Reads,Writes,Wait_Time,Last_Wait_Type,[Status],Blocking_Session_ID,Open_Transaction_Count,Percent_Complete,[Host_Name],Client_Net_Address,
		[Program_Name],Start_Time,Login_Time,DateStamp,ROW_NUMBER() OVER (ORDER BY Session_ID) AS RowNumber
		FROM #TEMP
	)
	SELECT Session_ID,DBName,RunTime,Login_Name,Formatted_SQL_Text,Raw_SQL_Text,CPU_Time,
		Logical_Reads,Reads,Writes,Wait_Time,Last_Wait_Type,[Status],Blocking_Session_ID,Open_Transaction_Count,Percent_Complete,[Host_Name],Client_Net_Address,
		[Program_Name],Start_Time,Login_Time,DateStamp
	FROM SessionInfo WHERE RowNumber IN (SELECT MIN(RowNumber) FROM SessionInfo GROUP BY Session_ID)
	AND Session_ID > 50 
	AND Session_ID <> @@SPID
	AND RunTime > 0
	ORDER BY Session_ID;
	DROP TABLE #TEMP;'
END

GO
