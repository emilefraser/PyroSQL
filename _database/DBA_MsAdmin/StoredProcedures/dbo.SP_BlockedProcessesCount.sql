SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE   PROCEDURE [dbo].[SP_BlockedProcessesCount]
as
begin

DECLARE @timebegin  time
DECLARE @timeend time

SET @timebegin = '07:00:00'
SET @timeend = '17:00:00'

--COMBINED TOTAL--
SELECT cast(DATEADD(DAY,0, datediff(day,0, [DateStamp]))as date) AS [Date]
     ,COUNT(*) AS [Number_Of]
  FROM [dbo].[BlockingHistory]
  WHERE [DateStamp] >= DATEADD(MONTH, DATEDIFF(MONTH, 31, CURRENT_TIMESTAMP), 0)
			AND [DateStamp] < DATEADD(MONTH, DATEDIFF(MONTH, 0, CURRENT_TIMESTAMP), 0)
			AND Offending_SQL_Text NOT LIKE '%_dta_stat_1561902223_2%'
			AND cast([DateStamp] as time) between @timebegin and @timeend
  GROUP BY 
			DATEADD(DAY,0, datediff(day,0, [DateStamp]))
  ORDER BY DATEADD(DAY,0, datediff(day,0, [DateStamp]))

--UNIQUE OFFENDING PROCESSES--
SELECT COUNT(*) AS [Number_Of]
	 ,DBName
	 ,Offending_SQL_Text
  FROM [dbo].[BlockingHistory]
  WHERE [DateStamp] >= DATEADD(MONTH, DATEDIFF(MONTH, 31, CURRENT_TIMESTAMP), 0)
			AND [DateStamp] < DATEADD(MONTH, DATEDIFF(MONTH, 0, CURRENT_TIMESTAMP), 0)
			AND Offending_SQL_Text NOT LIKE '%_dta_stat_1561902223_2%'
			AND cast([DateStamp] as time) between @timebegin and @timeend
  GROUP BY 
			Offending_SQL_Text
			,DBName
  ORDER BY DBName, Offending_SQL_Text

end

GO
