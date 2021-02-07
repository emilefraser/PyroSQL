create table dbo.DimDate 
(
    DateKey                 int not null,
    FullDate                date not null,
    DayNumberOfWeek         tinyint not null,
    DayNameOfWeek           nvarchar(10) not null,
    WeekDayType             nvarchar(7) not null,
    DayNumberOfMonth        tinyint not null,
    DayNumberOfYear         smallint not null,
    WeekNumberOfYear        tinyint not null,
    MonthNameOfYear         nvarchar(10) not null,
    MonthNumberOfYear       tinyint not null,
    QuarterNumberCalendar   tinyint not null,
    QuarterNameCalendar     nchar(2) not null,
    SemesterNumberCalendar  tinyint not null,
    SemesterNameCalendar    nvarchar(15) not null,
    YearCalendar            smallint not null,
    MonthNumberFiscal       tinyint not null,
    QuarterNumberFiscal     tinyint not null,
    QuarterNameFiscal       nchar(2) not null,
    SemesterNumberFiscal    tinyint not null,
    SemesterNameFiscal      nvarchar(15) not null,
    YearFiscal              smallint not null
 
    constraint PK_DimDate primary key clustered  
    (
        DateKey asc
    )
) 
go

declare @DateCalendarStart  datetime,
        @DateCalendarEnd    datetime,
        @FiscalCounter      datetime,
        @FiscalMonthOffset  int;
 
set @DateCalendarStart = '2005-01-01';
set @DateCalendarEnd = '2015-12-31';
 
-- Set this to the number of months to add or extract to the current date to get the beginning 
-- of the Fiscal Year. Example: If the Fiscal Year begins July 1, assign the value of 6 
-- to the @FiscalMonthOffset variable. Negative values are also allowed, thus if your 
-- 2012 Fiscal Year begins in July of 2011, assign a value of -6.
set @FiscalMonthOffset = 6;
 
with DateDimension  
as
(
    select  @DateCalendarStart as DateCalendarValue,
            dateadd(m, @FiscalMonthOffset, @DateCalendarStart) as FiscalCounter
                 
    union all
     
    select  DateCalendarValue + 1,
            dateadd(m, @FiscalMonthOffset, (DateCalendarValue + 1)) as FiscalCounter
    from    DateDimension 
    where   DateCalendarValue + 1 < = @DateCalendarEnd
)
 
insert into dbo.DimDate (DateKey, FullDate, DayNumberOfWeek, DayNameOfWeek, WeekDayType, 
                        DayNumberOfMonth, DayNumberOfYear, WeekNumberOfYear, MonthNameOfYear, 
                        MonthNumberOfYear, QuarterNumberCalendar, QuarterNameCalendar, SemesterNumberCalendar, 
                        SemesterNameCalendar, YearCalendar, MonthNumberFiscal, QuarterNumberFiscal, 
                        QuarterNameFiscal, SemesterNumberFiscal, SemesterNameFiscal, YearFiscal)
 
select  cast(convert(varchar(25), DateCalendarValue, 112) as int) as 'DateKey',
        cast(DateCalendarValue as date) as 'FullDate',
        datepart(weekday, DateCalendarValue) as 'DayNumberOfWeek',
        datename(weekday, DateCalendarValue) as 'DayNameOfWeek',
        case datename(dw, DateCalendarValue)
            when 'Saturday' then 'Weekend'
            when 'Sunday' then 'Weekend'
        else 'Weekday'
        end as 'WeekDayType',
        datepart(day, DateCalendarValue) as'DayNumberOfMonth',
        datepart(dayofyear, DateCalendarValue) as 'DayNumberOfYear',
        datepart(week, DateCalendarValue) as 'WeekNumberOfYear',
        datename(month, DateCalendarValue) as 'MonthNameOfYear',
        datepart(month, DateCalendarValue) as 'MonthNumberOfYear',
        datepart(quarter, DateCalendarValue) as 'QuarterNumberCalendar',
        'Q' + cast(datepart(quarter, DateCalendarValue) as nvarchar) as 'QuarterNameCalendar',
        case
            when datepart(month, DateCalendarValue) <= 6 then 1
            when datepart(month, DateCalendarValue) > 6 then 2
        end as 'SemesterNumberCalendar',
        case
            when datepart(month, DateCalendarValue) < = 6 then 'First Semester'
            when datepart(month, DateCalendarValue) > 6 then 'Second Semester' 
        end as 'SemesterNameCalendar',
        datepart(year, DateCalendarValue) as 'YearCalendar',
        datepart(month, FiscalCounter) as 'MonthNumberFiscal',
        datepart(quarter, FiscalCounter) as 'QuarterNumberFiscal',
        'Q' + cast(datepart(quarter, FiscalCounter) as nvarchar) as 'QuarterNameFiscal',  
        case
            when datepart(month, FiscalCounter) < = 6 then 1
            when datepart(month, FiscalCounter) > 6 then 2 
        end as 'SemesterNumberFiscal',  
        case
            when datepart(month, FiscalCounter) < = 6 then 'First Semester'
            when  datepart(month, FiscalCounter) > 6 then 'Second Semester'
        end as 'SemesterNameFiscal',            
        datepart(year, FiscalCounter) as 'YearFiscal'
from    DateDimension
order by
        DateCalendarValue
	option (maxrecursion 0);