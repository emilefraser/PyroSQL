SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE dbo.sp_use_DateFunctions
AS
BEGIN

	select GETDATE() -- 2014-01-17 07:45:59.730
	select DATEADD(year, 1, getdate()) --2015-01-17 07:45:59.730
	select DATEADD(month, 1, getdate())-- 2014-02-17 07:45:59.730
	select DATEADD(day, 1, getdate()) -- 2014-01-18 07:45:59.730

	select DATEDIFF(year,  '20130101', '20131024') -- 0
	select DATEDIFF(month,  '20130101', '20131024') -- 9
	select DATEDIFF(day,  '20130101', '20131024') -- 296

	select DATEPART(year, getdate()) -- 2014
	select DATEPART(month, getdate()) -- 1
	select DATEPART(day, getdate()) -- 17

	select YEAR(GETDATE()) -- 2014
	select MONTH(GETDATE()) -- 1
	select DAY(getdate()) -- 17

	select DATENAME(month, getdate()) -- January
	select DATENAME(DAY, GETDATE()) -- 17

	select ISDATE('20130101') - 1
	select ISDATE('20139999') - 0

END;
GO