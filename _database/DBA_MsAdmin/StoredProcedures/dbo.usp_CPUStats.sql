SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE   PROC [dbo].[usp_CPUStats]
AS
/**************************************************************************************************************
**  Purpose: 
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  02/28/2012		Michael Rounds			1.0					New Proc to gather CPU stats
**	08/31/2012		Michael Rounds			1.1					Changed VARCHAR to NVARCHAR
***************************************************************************************************************/
BEGIN
	SET NOCOUNT ON

	DECLARE @ts_now BIGINT, @ts_now2 BIGINT, @SQLVer NVARCHAR(20), @sql NVARCHAR(MAX) 

	DROP TABLE IF EXISTS #TEMP
 CREATE TABLE  #TEMP (
		[SQLProcessPercent] INT,
		[SystemIdleProcessPercent] INT,
		[OtherProcessPerecnt] INT,
		DateStamp DATETIME
		)

	SELECT @SQLVer = LEFT(CONVERT(NVARCHAR(20),SERVERPROPERTY('productversion')),4)

	IF CAST(@SQLVer AS NUMERIC(4,2)) < 10
	BEGIN
		EXEC sp_executesql
			N'SELECT @ts_now = cpu_ticks / CONVERT(float, cpu_ticks_in_ms) FROM sys.dm_os_sys_info',
			N'@ts_now BIGINT OUTPUT',
			@ts_now = @ts_now2 OUTPUT

			INSERT INTO #TEMP ([SQLProcessPercent],[SystemIdleProcessPercent],[OtherProcessPerecnt],DateStamp)
			SELECT SQLProcessUtilization AS [SQLProcessPercent],
						   SystemIdle AS [SystemIdleProcessPercent],
						   100 - SystemIdle - SQLProcessUtilization AS [OtherProcessPerecnt],
						   DATEADD(ms, -1 * (@ts_now2 - [timestamp]), GETDATE()) AS [DateStamp]
			FROM (
				  SELECT record.value('(./Record/@id)[1]', 'int') AS record_id,
						record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')
						AS [SystemIdle],
						record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]',
						'int')
						AS [SQLProcessUtilization], [timestamp]
				  FROM (
						SELECT [timestamp], CONVERT(xml, record) AS [record]
						FROM sys.dm_os_ring_buffers
						WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
						AND record LIKE '%<SystemHealth>%') AS x
				  ) AS y
			ORDER BY record_id DESC
	END
	ELSE BEGIN
	-- Get CPU Utilization History (SQL 2008 Only)
		SELECT @ts_now = cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info
		INSERT INTO #TEMP ([SQLProcessPercent],[SystemIdleProcessPercent],[OtherProcessPerecnt],DateStamp)
		SELECT SQLProcessUtilization AS [SQLProcessPercent],
					   SystemIdle AS [SystemIdleProcessPercent],
					   100 - SystemIdle - SQLProcessUtilization AS [OtherProcessPerecnt],
					   DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [DateStamp]
		FROM (
			  SELECT record.value('(./Record/@id)[1]', 'int') AS record_id,
					record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')
					AS [SystemIdle],
					record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]',
					'int')
					AS [SQLProcessUtilization], [timestamp]
			  FROM (
					SELECT [timestamp], convert(xml, record) AS [record]
					FROM sys.dm_os_ring_buffers
					WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
					AND record LIKE '%<SystemHealth>%') AS x
			  ) AS y
		ORDER BY record_id DESC
	END

	SELECT * FROM #TEMP

	DROP TABLE #TEMP
END

GO
