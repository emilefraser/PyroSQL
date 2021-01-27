
--USE master;
--GO
--IF OBJECT_ID('dbo.sp_dates') IS NOT NULL
--  DROP PROCEDURE dbo.sp_dates;
--GO
----#################################################################################################
---- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
----#################################################################################################
----#################################################################################################
----developer utility function added by Lowell, used in SQL Server Management Studio 
----Purpose: fast reference of various date formats 
----#################################################################################################
--CREATE PROCEDURE [dbo].[sp_dates](@date AS DATETIME = NULL)  
--AS  
--BEGIN  
DECLARE @date AS DATETIME = GETDATE()
  IF @date IS NULL  
    SET @date = GETDATE()  
  SELECT CONVERT(VARCHAR,@date,101) AS FormattedDate,'101' AS Code,'SELECT CONVERT(VARCHAR,@date,101)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,102) AS FormattedDate,'102' AS Code,'SELECT CONVERT(VARCHAR,@date,102)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,103) AS FormattedDate,'103' AS Code,'SELECT CONVERT(VARCHAR,@date,103)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,104) AS FormattedDate,'104' AS Code,'SELECT CONVERT(VARCHAR,@date,104)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,105) AS FormattedDate,'105' AS Code,'SELECT CONVERT(VARCHAR,@date,105)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,106) AS FormattedDate,'106' AS Code,'SELECT CONVERT(VARCHAR,@date,106)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,107) AS FormattedDate,'107' AS Code,'SELECT CONVERT(VARCHAR,@date,107)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,108) AS FormattedDate,'108' AS Code,'SELECT CONVERT(VARCHAR,@date,108)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,109) AS FormattedDate,'109' AS Code,'SELECT CONVERT(VARCHAR,@date,109)' AS SQL UNION  
  SELECT datename(dw,@date) + ', ' + CONVERT(VARCHAR,@date,109) AS FormattedDate,'109+' AS Code,'SELECT datename(dw,@date) + '' '' + CONVERT(VARCHAR,@date,109)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,110) AS FormattedDate,'110' AS Code,'SELECT CONVERT(VARCHAR,@date,110)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,111) AS FormattedDate,'111' AS Code,'SELECT CONVERT(VARCHAR,@date,111)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,112) AS FormattedDate,'112' AS Code,'SELECT CONVERT(VARCHAR,@date,112)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,113) AS FormattedDate,'113' AS Code,'SELECT CONVERT(VARCHAR,@date,113)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,114) AS FormattedDate,'114' AS Code,'SELECT CONVERT(VARCHAR,@date,114)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,120) AS FormattedDate,'120' AS Code,'SELECT CONVERT(VARCHAR,@date,120)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,121) AS FormattedDate,'121' AS Code,'SELECT CONVERT(VARCHAR,@date,121)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,126) AS FormattedDate,'126' AS Code,'SELECT CONVERT(VARCHAR,@date,126)' AS SQL UNION  
  SELECT CONVERT(NVARCHAR,@date,130) AS FormattedDate,'130' AS Code,'SELECT CONVERT(NVARCHAR,@date,130)' AS SQL UNION  
  SELECT CONVERT(NVARCHAR,@date,131) AS FormattedDate,'131' AS Code,'SELECT CONVERT(NVARCHAR,@date,131)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,112) + '-' + CONVERT(VARCHAR,@date,114) AS FormattedDate,'---' AS Code,'SELECT CONVERT(VARCHAR,@date,112) + ''-'' + CONVERT(VARCHAR,@date,114)' AS SQL UNION  
  SELECT CONVERT(VARCHAR,@date,112) + '-' + REPLACE(CONVERT(VARCHAR,@date,114),':','') AS FormattedDate,'---' AS Code,'SELECT CONVERT(VARCHAR,@date,112) + ''-'' + REPLACE(CONVERT(VARCHAR,@date,114),'':'','''')' AS SQL   UNION
  SELECT LEFT(CONVERT(VARCHAR,@date,108),5) AS FormattedDate,'---' AS Code,'SELECT LEFT(CONVERT(VARCHAR,@date,108),5)' AS SQL UNION
  SELECT '__Midnight for the Current Day:',' - ','select DATEADD(dd, DATEDIFF(dd,0,getdate()), 0)' UNION ALL
SELECT '_First Business day (Monday) of this month',' - ','select DATEADD(wk,DATEDIFF(wk,0,dateadd(dd,6 - datepart(day,getdate()),getdate())), 0)' UNION ALL
SELECT '_Last day of the prior month',' - ','select dateadd(ms,-3,DATEADD(mm, DATEDIFF(mm,0,getdate() ), 0))' UNION ALL
SELECT '_Third friday of this month:',' - ','select DATEADD(dd,18,DATEADD(wk,DATEDIFF(wk,0,dateadd(dd,6 - datepart(day,getdate()),getdate())), 0))' UNION ALL
SELECT '_Third friday of this month:',' - ','select DATEADD(wk,2,DATEADD(dd,4,DATEADD(wk,DATEDIFF(wk,0,dateadd(dd,6 - datepart(day,getdate()),getdate())), 0)) )' UNION ALL
SELECT '_last business day(Friday) of the prior month...',' - ','datename(dw,dateadd(dd,-3,DATEADD(wk,DATEDIFF(wk,0,dateadd(dd,7-datepart(day,getdate()),getdate())), 0)))' UNION ALL
SELECT '_Monday of the Current Week',' - ','select DATEADD(wk, DATEDIFF(wk,0,getdate()), 0)' UNION ALL
SELECT '_Friday of the Current Week',' - ','select dateadd(dd,4,DATEADD(wk, DATEDIFF(wk,0,getdate()), 0))' UNION ALL
SELECT '_First Day of this Month',' - ','select DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)' UNION ALL
SELECT '_First Day of the Year',' - ','select DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)' UNION ALL
SELECT '_First Day of the Quarter',' - ','select DATEADD(qq, DATEDIFF(qq,0,getdate()), 0)' UNION ALL
SELECT '_Last Day of Prior Year',' - ','select dateadd(ms,-3,DATEADD(yy, DATEDIFF(yy,0,getdate() ), 0))' UNION ALL
SELECT '_Last Day of Current Month',' - ','select dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,getdate() ) + 1, 0))' UNION ALL
SELECT '_Last Day of Current Year',' - ','select dateadd(ms,-3,DATEADD(yy, DATEDIFF(yy,0,getdate() ) + 1, 0)) ' 
  ORDER BY CODE,FormattedDate  
--END 
--GO
----#################################################################################################
----Mark as a system object
--EXECUTE sp_ms_marksystemobject 'sp_dates'
--GRANT EXECUTE ON dbo.sp_dates TO PUBLIC;
----#################################################################################################
--GO
