create FUNCTION [DSQLT].[Dates]
(@from Datetime='01.01.2000', @to Datetime='31.12.2078')
RETURNS @Result TABLE (
	[Date] [datetime] NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[Day] [int] NULL,
	[DayOfYear] [int] NULL,
	[Weekday] [int] NULL
) 
AS
BEGIN
--declare @from Datetime
--declare @to Datetime
--set @from='01.01.2000'
--set @to ='31.12.2000'
declare @todays int
set @todays=datediff(day,@from,@to)
;WITH Numbers as
(SELECT Number from DSQLT.aMillionNumbers(0,@todays)
)
, Dates as
(SELECT DATEADD(day,Number,@from) as [Date] from Numbers
)
INSERT @Result
SELECT [Date], year([Date]) as [Year], month([Date]) as [Month], day([Date]) as [Day]
,Datepart(dayofyear,[Date]) as [DayOfYear]
,Datepart(weekday,[Date]) as [Weekday]
from Dates
RETURN
END

