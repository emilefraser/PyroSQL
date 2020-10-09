SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE   PROCEDURE [dbo].[SP_MemoryUsage]
as
begin

DECLARE @timebegin  time
DECLARE @timeend time

SET @timebegin = '07:00:00'
SET @timeend = '17:00:00'

--[AVG_BufferPageLifeExpectancy]

SELECT  cast(DATEADD(DAY,0, datediff(day,0, [DateStamp]))as date) AS [Date]
		,AVG(cast([BufferPageLifeExpectancy] as int)) [AVG_BufferPageLifeExpectancy]
		,MIN(cast([BufferPageLifeExpectancy] as int)) [MIN_BufferPageLifeExpectancy]
		,MAX(cast([BufferPageLifeExpectancy] as int)) [MAX_BufferPageLifeExpectancy]
  FROM [dbo].[MemoryUsageHistory]
WHERE [DateStamp] >= DATEADD(MONTH, DATEDIFF(MONTH, 31, CURRENT_TIMESTAMP), 0)
			AND [DateStamp] < DATEADD(MONTH, DATEDIFF(MONTH, 0, CURRENT_TIMESTAMP), 0) AND cast([DateStamp] as time) between @timebegin and @timeend
group by cast(DATEADD(DAY,0, datediff(day,0, [DateStamp]))as date) 
order by cast(DATEADD(DAY,0, datediff(day,0, [DateStamp]))as date) 

--Detail where BufferPageLifeExpectancy is between 4 and 1000 pages and 07:00 / 17:00
--DECLARE @timebegin  time
--DECLARE @timeend time

--SET @timebegin = '07:00:00'
--SET @timeend = '17:00:00'

SELECT [BufferPageLifeExpectancy],* FROM [MemoryUsageHistory]
where ([BufferPageLifeExpectancy] > 4 and [BufferPageLifeExpectancy] < 1000)
  AND cast([DateStamp] as time) between @timebegin and @timeend
  AND [DateStamp] >= DATEADD(MONTH, DATEDIFF(MONTH, 31, CURRENT_TIMESTAMP), 0)
			AND [DateStamp] < DATEADD(MONTH, DATEDIFF(MONTH, 0, CURRENT_TIMESTAMP), 0) AND cast([DateStamp] as time) between @timebegin and @timeend
order by [DateStamp]

--AVG_BufferCacheHitRatio
--DECLARE @timebegin  time
--DECLARE @timeend time

--SET @timebegin = '07:00:00'
--SET @timeend = '17:00:00'

SELECT  cast(DATEADD(DAY,0, datediff(day,0, [DateStamp]))as date) AS [Date]
		,AVG(cast([BufferCacheHitRatio] as float)) [AVG_BufferCacheHitRatio]
		,MIN(cast([BufferCacheHitRatio] as float)) [MIN_BufferCacheHitRatio]
  FROM [dbo].[MemoryUsageHistory]
WHERE [DateStamp] >= DATEADD(MONTH, DATEDIFF(MONTH, 31, CURRENT_TIMESTAMP), 0)
			AND [DateStamp] < DATEADD(MONTH, DATEDIFF(MONTH, 0, CURRENT_TIMESTAMP), 0) AND cast([DateStamp] as time) between @timebegin and @timeend
group by cast(DATEADD(DAY,0, datediff(day,0, [DateStamp]))as date) 
order by cast(DATEADD(DAY,0, datediff(day,0, [DateStamp]))as date) 


--Detail where BufferCacheHitRatio is between 0 and 98 pages and 07:00 / 17:00
--DECLARE @timebegin  time
--DECLARE @timeend time

--SET @timebegin = '07:00:00'
--SET @timeend = '17:00:00'

SELECT [DateStamp], [BufferCacheHitRatio] 
FROM [dbo].[MemoryUsageHistory]
where (CAST([BufferCacheHitRatio] AS FLOAT) > 0 and CAST([BufferCacheHitRatio] AS FLOAT) < 98)
  AND cast([DateStamp] as time) between @timebegin and @timeend
  AND [DateStamp] >= DATEADD(MONTH, DATEDIFF(MONTH, 31, CURRENT_TIMESTAMP), 0)
			AND [DateStamp] < DATEADD(MONTH, DATEDIFF(MONTH, 0, CURRENT_TIMESTAMP), 0) AND cast([DateStamp] as time) between @timebegin and @timeend
order by [DateStamp]


end

GO
