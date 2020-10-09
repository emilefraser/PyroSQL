SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




CREATE PROC [dbo].[usp_PerfStats] (@InsertFlag BIT = 0)
AS

/**************************************************************************************************************
**  Purpose: 
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  02/21/2012		Michael Rounds			1.0					Comments creation
**	08/31/2012		Michael Rounds			1.1					Changed to use temp tables, Changed VARCHAR to NVARCHAR
***************************************************************************************************************/

BEGIN
SET NOCOUNT ON
 
DECLARE @BatchRequestsPerSecond BIGINT, 
		@CompilationsPerSecond BIGINT, 
		@ReCompilationsPerSecond BIGINT, 
		@LockWaitsPerSecond BIGINT, 
		@PageSplitsPerSecond BIGINT, 
		@CheckpointPagesPerSecond BIGINT, 
		@stat_date DATETIME,
		@PerfStatsID INT

CREATE TABLE #RatioStatsX (
	[object_name] NVARCHAR(128),
    [counter_name] NVARCHAR(128),
    [instance_name] NVARCHAR(128),
    [cntr_value] BIGINT,
    [cntr_type] INT
    )

CREATE TABLE #RatioStatsY (
    [object_name] NVARCHAR(128),
    [counter_name] NVARCHAR(128),
    [instance_name] NVARCHAR(128),
    [cntr_value] BIGINT,
    [cntr_type] INT
    )

SET @stat_date = GETDATE();
 
INSERT INTO #RatioStatsX ([object_name],[counter_name],[instance_name],[cntr_value],[cntr_type])
SELECT [object_name],[counter_name],[instance_name],[cntr_value],[cntr_type] 
FROM sys.dm_os_performance_counters;
 
SELECT TOP 1 @BatchRequestsPerSecond = cntr_value
FROM #RatioStatsX
WHERE counter_name = 'Batch Requests/sec'
AND object_name LIKE '%SQL Statistics%';

SELECT TOP 1 @CompilationsPerSecond = cntr_value
FROM #RatioStatsX
WHERE counter_name = 'SQL Compilations/sec'
AND object_name LIKE '%SQL Statistics%';

SELECT TOP 1 @ReCompilationsPerSecond = cntr_value
FROM #RatioStatsX
WHERE counter_name = 'SQL Re-Compilations/sec'
AND object_name LIKE '%SQL Statistics%';

SELECT TOP 1 @LockWaitsPerSecond = cntr_value
FROM #RatioStatsX
WHERE counter_name = 'Lock Waits/sec'
AND instance_name = '_Total'
AND object_name LIKE '%Locks%';

SELECT TOP 1 @PageSplitsPerSecond = cntr_value
FROM #RatioStatsX
WHERE counter_name = 'Page Splits/sec'
AND object_name LIKE '%Access Methods%'; 

SELECT TOP 1 @CheckpointPagesPerSecond = cntr_value
FROM #RatioStatsX
WHERE counter_name = 'Checkpoint Pages/sec'
AND object_name LIKE '%Buffer Manager%';                                         
 
WAITFOR DELAY '00:00:01'

INSERT INTO #RatioStatsY ([object_name],[counter_name],[instance_name],[cntr_value],[cntr_type])
SELECT [object_name],[counter_name],[instance_name],[cntr_value],[cntr_type]
FROM sys.dm_os_performance_counters

SELECT (a.cntr_value * 1.0 / b.cntr_value) * 100.0 [BufferCacheHitRatio],
	c.cntr_value  AS [PageLifeExpectency],
	d.[BatchRequestsPerSecond],
	e.[CompilationsPerSecond],
	f.[ReCompilationsPerSecond],
	g.cntr_value AS [UserConnections],
	h.LockWaitsPerSecond,
	i.PageSplitsPerSecond,
	j.cntr_value AS [ProcessesBlocked],
	k.CheckpointPagesPerSecond,
	GETDATE() AS StatDate                           
INTO #TEMP
FROM (SELECT * FROM #RatioStatsY
               WHERE counter_name = 'Buffer cache hit ratio'
               AND object_name LIKE '%Buffer Manager%') a  
     CROSS JOIN  
      (SELECT * FROM #RatioStatsY
                WHERE counter_name = 'Buffer cache hit ratio base'
                AND object_name LIKE '%Buffer Manager%') b    
     CROSS JOIN
      (SELECT * FROM #RatioStatsY
                WHERE counter_name = 'Page life expectancy '
                AND object_name LIKE '%Buffer Manager%') c
     CROSS JOIN
     (SELECT (cntr_value - @BatchRequestsPerSecond) /
                     (CASE WHEN DATEDIFF(ss,@stat_date, GETDATE()) = 0
                           THEN  1
                           ELSE DATEDIFF(ss,@stat_date, GETDATE()) END) AS [BatchRequestsPerSecond]
                FROM #RatioStatsY
                WHERE counter_name = 'Batch Requests/sec'
                AND object_name LIKE '%SQL Statistics%') d   
     CROSS JOIN
     (SELECT (cntr_value - @CompilationsPerSecond) /
                     (CASE WHEN DATEDIFF(ss,@stat_date, GETDATE()) = 0
                           THEN  1
                           ELSE DATEDIFF(ss,@stat_date, GETDATE()) END) AS [CompilationsPerSecond]
                FROM #RatioStatsY
                WHERE counter_name = 'SQL Compilations/sec'
                AND object_name LIKE '%SQL Statistics%') e 
     CROSS JOIN
     (SELECT (cntr_value - @ReCompilationsPerSecond) /
                     (CASE WHEN DATEDIFF(ss,@stat_date, GETDATE()) = 0
                           THEN  1
                           ELSE DATEDIFF(ss,@stat_date, GETDATE()) END) AS [ReCompilationsPerSecond]
                FROM #RatioStatsY
                WHERE counter_name = 'SQL Re-Compilations/sec'
                AND object_name LIKE '%SQL Statistics%') f
     CROSS JOIN
     (SELECT * FROM #RatioStatsY
               WHERE counter_name = 'User Connections'
               AND object_name LIKE '%General Statistics%') g
     CROSS JOIN
     (SELECT (cntr_value - @LockWaitsPerSecond) /
                     (CASE WHEN DATEDIFF(ss,@stat_date, GETDATE()) = 0
                           THEN  1
                           ELSE DATEDIFF(ss,@stat_date, GETDATE()) END) AS [LockWaitsPerSecond]
                FROM #RatioStatsY
                WHERE counter_name = 'Lock Waits/sec'
                AND instance_name = '_Total'
                AND object_name LIKE '%Locks%') h
     CROSS JOIN
     (SELECT (cntr_value - @PageSplitsPerSecond) /
                     (CASE WHEN DATEDIFF(ss,@stat_date, GETDATE()) = 0
                           THEN  1
                           ELSE DATEDIFF(ss,@stat_date, GETDATE()) END) AS [PageSplitsPerSecond]
                FROM #RatioStatsY
                WHERE counter_name = 'Page Splits/sec'
                AND object_name LIKE '%Access Methods%') i
     CROSS JOIN
     (SELECT * FROM #RatioStatsY
               WHERE counter_name = 'Processes blocked'
               AND object_name LIKE '%General Statistics%') j
     CROSS JOIN
     (SELECT (cntr_value - @CheckpointPagesPerSecond) /
                     (CASE WHEN DATEDIFF(ss,@stat_date, GETDATE()) = 0
                           THEN  1
                           ELSE DATEDIFF(ss,@stat_date, GETDATE()) END) AS [CheckpointPagesPerSecond]
                FROM #RatioStatsY
                WHERE counter_name = 'Checkpoint Pages/sec'
                AND object_name LIKE '%Buffer Manager%') k
                
DROP TABLE #RatioStatsX
DROP TABLE #RatioStatsY
SELECT * FROM #TEMP

IF @InsertFlag = 1
BEGIN
INSERT INTO [DBA_Monitoring].dbo.PerfStatsHistory (BufferCacheHitRatio, PageLifeExpectency, BatchRequestsPerSecond, CompilationsPerSecond, ReCompilationsPerSecond, UserConnections, LockWaitsPerSecond, PageSplitsPerSecond, ProcessesBlocked, CheckpointPagesPerSecond, StatDate)
SELECT BufferCacheHitRatio, PageLifeExpectency, BatchRequestsPerSecond, CompilationsPerSecond, ReCompilationsPerSecond, UserConnections, LockWaitsPerSecond, PageSplitsPerSecond, ProcessesBlocked, CheckpointPagesPerSecond, StatDate
FROM #TEMP
END
DROP TABLE #TEMP
END

GO
