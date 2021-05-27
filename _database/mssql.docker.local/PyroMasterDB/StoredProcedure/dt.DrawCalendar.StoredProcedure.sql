SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt].[DrawCalendar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dt].[DrawCalendar] AS' 
END
GO


ALTER   PROCEDURE [dt].[DrawCalendar]
--draw a calendar as a result set. you can specify the month if you wwant
@Date datetime=null--any date within the month that you want to calendarise.
/*
For Novermber 2013 it gives...

Mon  Tue  Wed  Thu  Fri  Sat  Sun
---- ---- ---- ---- ---- ---- ----
                    1    2    3 
4    5    6    7    8    9    10
11   12   13   14   15   16   17
18   19   20   21   22   23   24
25   26   27   28   29   30


eg. spCalendar '1 Jan 2006'
Execute spCalendar '1 sep 2013'
Execute spCalendar '1 nov 2013'
Execute spCalendar '28 feb 2008'
Execute spCalendar '1 mar 1949'
Execute spCalendar '10 jul 2020'

*/
as
Set nocount on
--nail down the start of the week
Declare @MonthLength int --number of days in the month
Declare @MonthStartDW int --the day of the week that the month starts on
--if no date is specified, then use the current date
Select @Date='01 '+substring(convert(char(11),coalesce(@date,GetDate()),113),4,8)
--get the number of days in the month and the day of the week that the month starts on
Select @MonthLength=datediff(day,convert(char(11),@Date,113),convert(char(11),DateAdd(month,1,@Date),113)),
@MonthStartDW=((Datepart(dw,@date)+@@DateFirst-3) % 7)+1

Select
[Mon]=max(case when day=1 and monthdate between 1 and @MonthLength then convert(char(2),monthdate) else '' end),
[Tue]=max(case when day=2 and monthdate between 1 and @MonthLength then convert(char(2),monthdate) else '' end),
[Wed]=max(case when day=3 and monthdate between 1 and @MonthLength then convert(char(2),monthdate) else '' end),
[Thu]=max(case when day=4 and monthdate between 1 and @MonthLength then convert(char(2),monthdate) else '' end),
[Fri]=max(case when day=5 and monthdate between 1 and @MonthLength then convert(char(2),monthdate) else '' end),
[Sat]=max(case when day=6 and monthdate between 1 and @MonthLength then convert(char(2),monthdate) else '' end),
[Sun]=max(case when day=7 and monthdate between 1 and @MonthLength then convert(char(2),monthdate) else '' end)
from
(--roll out the day number and week number so you can then do a pivot table of the results
Select [day]=DayNo.Number, [week]=Weekno.number,
[monthDate]=(DayNo.Number + ((Weekno.number-1)*7))-@MonthStartDW
from (VALUES (1),(2),(3),(4),(5),(6),(7)) AS DayNo(number)
 cross join 
 (VALUES (1),(2),(3),(4),(5),(6)) AS Weekno(number)

)f
group by [week]--so that each week is on a different row
having max(case when day=1 and monthdate between 1 and @MonthLength then monthdate else 0 end)>0
or (week=1 and sum(MonthDate)>-21)
--take out any weeks on the end without a valid day in them!
GO
