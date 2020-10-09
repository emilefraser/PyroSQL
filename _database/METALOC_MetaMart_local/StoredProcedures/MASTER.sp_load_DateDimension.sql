SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

--SELECT * FROM [MASTER].[DateDimension] where [IsCurrentWeek] = 1



-- =============================================
-- Author:		Toinette Barnard
-- Create date: 2018-09-18
-- Description:	Create and Populate a Time Dimension Table
-- =============================================
--Sample Execution: TRUNCATE table [MASTER].DateDimension [MASTER].[sp_load_DateDimension] '2006-10-01', '2020-12-05'

CREATE PROCEDURE [MASTER].[sp_load_DateDimension]
	-- Add the parameters for the stored procedure here
	--@beginDate date,
	--@endDate date
AS
--Testing
DECLARE
	@BeginDate date ,
	@EndDate date 

--SET @BeginDate = '2006-10-01'
--SET @EndDate = '2020-12-05'

SET @BeginDate = '2014/01/01' --DATEADD(YEAR,+2,CAST(GETDATE() AS DATE))
SET @EndDate = DATEADD(YEAR,+20,CAST(GETDATE() AS DATE))

-- TRUNCATE table [MASTER].DateDimension

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--CREATE TABLE
	IF NOT EXISTS (SELECT [name] from sys.tables where [name] = N'DateDimension')
	BEGIN
	--DROP TABLE [MASTER].[DateDimension]
		Create Table [MASTER].[DateDimension]
			(
				[CalendarDate] Date Primary key
				, [IsWeekend] bit
				, [Year] SmallInt
				, [QuarterNo] TinyInt
				, [MonthNumber] varchar(2)
				, [DayofYear] SmallInt
				, [Day] TinyInt
				, [Week] TinyInt
				, [DayofWeekNo] TinyInt
				, [DayofWeek] varchar(9)
				, [DayofWeekAbbreviation] varchar(3)
				, [Month] varchar(20)
				, [MonthAbbreviation] varchar(5)
				, [FinancialYear] int
				, [FinancialPeriodNo] varchar(2)
				, [YearFinancialPeriod] varchar(7)
				, [FinancialPeriod] varchar(3)
				, [FinancialQuarterNo] tinyint
				, [FinancialYearQuarter] varchar(7)
				, [FinancialQuarter] varchar(2)
				, [MonthBeginDate] Date
				, [MonthEndDate] Date
				, [WeekBeginDate] Date
				, [WeekEndDate] Date
				, [PreviousYear] int
				, [PreviousYearDate] Date
				, [IsToday] bit
				, [IsCurrentWeek] bit
				, [IsCurrentMonth] bit
				, [IsPublicHoliday] bit
				, [IsSchoolHoliday] bit
				, [IsInLast7Days] bit
				, [IsInLast30Days] bit 
				
			)
	
	END

	--If the table exists, then add new time frame to DateDimension
	--POPULATE TABLE

	IF (select MAX([CalendarDate]) from [MASTER].DateDimension) > @beginDate
		BEGIN
			SELECT  @beginDate = DATEADD(DAY,+1,MAX([CalendarDate])) FROM [MASTER].DateDimension

			While @beginDate <= @endDate 
			Begin
				Insert Into [MASTER].[DateDimension] 
					([CalendarDate], [IsWeekend], [Year], [QuarterNo]
					, [MonthNumber]
					, [DayofYear], [Day], [Week], [DayofWeekNo], [DayofWeek]
					, [DayofWeekAbbreviation], [Month]
					, [MonthAbbreviation], [FinancialYear], [FinancialPeriodNo]
					, [YearFinancialPeriod], [FinancialPeriod]
					, [FinancialQuarterNo], [FinancialYearQuarter], [FinancialQuarter]
					, [MonthBeginDate], [MonthEndDate], [WeekBeginDate], [WeekEndDate]
					, [IsToday], [IsCurrentWeek], [IsCurrentMonth]
					, [IsPublicHoliday], [IsSchoolHoliday]
					, [IsInLast7Days]
					, [IsInLast30Days])
				Select
					@beginDate As [CalendarDate]     
					,(Case When DATEPART(Weekday, @beginDate) In (7, 1) Then 1 Else 0 End) As [IsWeekend] 
					,DATEPART(Year, @beginDate) As [Year] 
					,DATEPART(QUARTER, @beginDate) As [QuarterNo] 
					,DATEPART(MONTH, @beginDate) As [MonthNumber] 
					,DATEPART(DayOfYear, @beginDate) As [DayofYear] 
					,DATEPART(Day, @beginDate) As [Day]         
					,DATEPART(Week, @beginDate) As [Week]
					,DATEPART(WEEKDAY, @beginDate) As [DayofWeekNo] 
					,DATENAME(dw,@beginDate) As [DayOfWeek]
					,LEFT((DATENAME(dw,@beginDate)),3) As [DayOfWeekAbbreviation]
					,DATENAME(Month,@beginDate) as [Month]
					,LEFT((DATENAME(Month,@beginDate)),3) as [MonthAbbreviation]
					,NULL as [FinancialYear]
					,NULL as [FinancialPeriodNo]
					,NULL as [YearFinancialPeriod]
					,NULL as [FinancialPeriod]
					,NULL as [FinancialQuarterNo]
					,NULL as [FinancialYearQuarter]
					,NULL as [FinancialQuarter]
					,DATEADD(MONTH,-1,(DATEADD(DAY,1,EOMONTH(@beginDate)))) AS [MonthBeginDate]
					,EOMONTH(@beginDate) AS [MonthEndDate]
					,DATEADD(Week,(DATEDIFF(week,6,'1/1/'+CONVERT(varchar(4),DATEPART(Year, @beginDate)))+(DATEPART(Week, @beginDate)-1)),6) AS [WeekBeginDate]
					,DATEADD(Week,(DATEDIFF(week,5,'1/1/'+CONVERT(varchar(4),DATEPART(Year, @beginDate)))+(DATEPART(Week, @beginDate)-1)),5) AS [WeekEndDate]
					,NULL AS [IsToday]
					,NULL as [IsCurrentWeek]
					,NULL as [IsCurrentMonth]
					,0 as [IsPublicHoliday]
					,0 as [IsSchoolHoliday]
					,NULL AS [IsInLast7Days]
					,NULL AS [IsInLast30Days]

				select @beginDate = DATEADD(DAY,+1, @beginDate)
			end
		END
	ELSE
		BEGIN
			While @beginDate <= @endDate 
			Begin
				Insert Into [MASTER].[DateDimension] 
					([CalendarDate], [IsWeekend], [Year], [QuarterNo]
					, [MonthNumber]
					, [DayofYear], [Day], [Week], [DayofWeekNo], [DayofWeek]
					, [DayofWeekAbbreviation], [Month]
					, [MonthAbbreviation], [FinancialYear], [FinancialPeriodNo]
					, [YearFinancialPeriod], [FinancialPeriod]
					, [FinancialQuarterNo], [FinancialYearQuarter], [FinancialQuarter]
					, [MonthBeginDate], [MonthEndDate], [WeekBeginDate], [WeekEndDate]
					, [IsToday], [IsCurrentWeek], [IsCurrentMonth]
					, [IsPublicHoliday], [IsSchoolHoliday], [IsInLast7Days], [IsInLast30Days])
				Select
					@beginDate As [CalendarDate]     
					,(Case When DATEPART(Weekday, @beginDate) In (7, 1) Then 1 Else 0 End) As [IsWeekend] 
					,DATEPART(Year, @beginDate) As [Year] 
					,DATEPART(QUARTER, @beginDate) As [QuarterNo] 
					,DATEPART(MONTH, @beginDate) As [MonthNumber] 
					,DATEPART(DayOfYear, @beginDate) As [DayofYear] 
					,DATEPART(Day, @beginDate) As [Day]         
					,DATEPART(Week, @beginDate) As [Week]
					,DATEPART(WEEKDAY, @beginDate) As [DayofWeekNo] 
					,DATENAME(dw,@beginDate) As [DayOfWeek]
					,LEFT((DATENAME(dw,@beginDate)),3) As [DayOfWeekAbbreviation] 
					,DATENAME(Month,@beginDate) as [Month]
					,LEFT((DATENAME(Month,@beginDate)),3) as [MonthAbbreviation]
					,NULL as [FinancialYear]
					,NULL as [FinancialPeriodNo]
					,NULL as [YearFinancialPeriod]
					,NULL as [FinancialPeriod]
					,NULL as [FinancialQuarterNo]
					,NULL as [FinancialYearQuarter]
					,NULL as [FinancialQuarter]
					,DATEADD(MONTH,-1,(DATEADD(DAY,1,EOMONTH(@beginDate)))) AS [MonthBeginDate]
					,EOMONTH(@beginDate) AS [MonthEndDate]
					,DATEADD(Week,(DATEDIFF(week,6,'1/1/'+CONVERT(varchar(4),DATEPART(Year, @beginDate)))+(DATEPART(Week, @beginDate)-1)),6) AS [WeekBeginDate]
					,DATEADD(Week,(DATEDIFF(week,5,'1/1/'+CONVERT(varchar(4),DATEPART(Year, @beginDate)))+(DATEPART(Week, @beginDate)-1)),5) AS [WeekEndDate]
					,NULL AS [IsToday]
					,NULL as [IsCurrentWeek]
					,NULL as [IsCurrentMonth]
					,0 as [IsPublicHoliday]
					,0 as [IsSchoolHoliday]
					,NULL AS [IsInLast7Days]
					,NULL AS [IsInLast30Days]

				select @beginDate = DATEADD(DAY,+1, @beginDate)

			end
		END

	--Update Fiscal Information in the DateDimension table

	--**Temp code until data from X3 ERP is pulled into the ODS

	-- Insert into a temp table to join to
	-- drop table #FiscalPeriods
	select 1 as [FinancialPeriodNo], 10 as [MonthNumber], 'October' as [FinancialPeriodDescription] into #FiscalPeriods union all
	select 2 as [FinancialPeriodNo], 11 as [MonthNumber], 'November' as [FinancialPeriodDescription] union all
	select 3 as [FinancialPeriodNo], 12 as [MonthNumber], 'December' as [FinancialPeriodDescription] union all
	select 4 as [FinancialPeriodNo], 1 as [MonthNumber], 'January' as [FinancialPeriodDescription] union all
	select 5 as [FinancialPeriodNo], 2 as [MonthNumber], 'February' as [FinancialPeriodDescription] union all
	select 6 as [FinancialPeriodNo], 3 as [MonthNumber], 'March' as [FinancialPeriodDescription] union all
	select 7 as [FinancialPeriodNo], 4 as [MonthNumber], 'April' as [FinancialPeriodDescription] union all
	select 8 as [FinancialPeriodNo], 5 as [MonthNumber], 'May' as [FinancialPeriodDescription] union all
	select 9 as [FinancialPeriodNo], 6 as [MonthNumber], 'June' as [FinancialPeriodDescription] union all
	select 10 as [FinancialPeriodNo], 7 as [MonthNumber], 'July' as [FinancialPeriodDescription] union all
	select 11 as [FinancialPeriodNo], 8 as [MonthNumber], 'August' as [FinancialPeriodDescription] union all
	select 12 as [FinancialPeriodNo], 9 as [MonthNumber], 'September' as [FinancialPeriodDescription] 

	--Update DateDimension table with period information

	update	datedim
	set		[FinancialPeriodNo] = RIGHT('0' + CONVERT(varchar(2),fp.FinancialPeriodNo), 2)
								  --CASE WHEN LEN(fp.[FinancialPeriodNo]) = 1
								  --THEN CONVERT(varchar(2),('0' + CONVERT(varchar(2),fp.[FinancialPeriodNo])))
								  --THEN CONVERT(varchar(2), REPLICATE(0,1)) + CONVERT(varchar(2), fp.[FinancialPeriodNo])
								  --THEN RIGHT('0' + CONVERT(varchar(2),fp.FinancialPeriodNo), 2)
								  --ELSE fp.[FinancialPeriodNo]
								  --END
			, [FinancialYear] = CASE WHEN datedim.[MonthNumber] between 10 and 12
							THEN [Year] + 1
							ELSE [Year] 
						   END
	from	[MASTER].DateDimension datedim
		inner join #FiscalPeriods fp on datedim.[MonthNumber] = fp.[MonthNumber] 
	--where	FiscalYearNumber IS NULL
	--	OR FiscalYear IS NULL
	--	OR datedim.[Financial Period] IS NULL

	update datedim
	set [YearFinancialPeriod] = CONCAT(datedim.[FinancialYear],'-',RIGHT('0' + CONVERT(varchar(2),fp.FinancialPeriodNo), 2))
		, [FinancialPeriod] = CONCAT('P',RIGHT('0' + CONVERT(varchar(2),fp.FinancialPeriodNo), 2))
	FROM [MASTER].DateDimension datedim
		inner join #FiscalPeriods fp on datedim.[MonthNumber] = fp.[MonthNumber] 

	update datedim
	set [FinancialQuarterNo] = CASE WHEN fp.[FinancialPeriodNo] BETWEEN 0 AND 3
							   THEN 1
							   WHEN fp.[FinancialPeriodNo] BETWEEN 4 AND 6
							   THEN 2
							   WHEN fp.[FinancialPeriodNo] BETWEEN 7 AND 9
							   THEN 3
							   WHEN fp.[FinancialPeriodNo] BETWEEN 10 AND 12
							   THEN 4
							   ELSE 0
							   END
	FROM [MASTER].DateDimension datedim
			inner join #FiscalPeriods fp on datedim.[MonthNumber] = fp.[MonthNumber] 


	update datedim
	set [FinancialYearQuarter] = CONCAT([FinancialYear],'-','Q',[FinancialQuarterNo])
		,[FinancialQuarter] = CONCAT('Q',[FinancialQuarterNo])
	FROM [MASTER].DateDimension datedim
	

	update datedim
	set [PreviousYearDate] =
			 CASE 
            WHEN ([Year] % 4 = 0
                AND (DATENAME(MONTH, CalendarDate) <> 'January'
                    AND DATENAME(MONTH, CalendarDate) <> 'February'))
            THEN DATEADD(day,-364, CalendarDate)
            WHEN ([Year] % 4 = 1
                AND (DATENAME(MONTH, CalendarDate) = 'January'
                OR DATENAME(MONTH, CalendarDate) = 'February'))
            THEN DATEADD(day,-364, CalendarDate)

            ELSE DATEADD(week,-52, CalendarDate)
        END,
		[PreviousYear] = YEAR(CalendarDate) - 1
	FROM [MASTER].DateDimension datedim


	--Update Time Dimension with Dynamic Elements

	update [MASTER].DateDimension
	set [IsToday] = CASE WHEN CalendarDate = CAST(GETDATE() AS DATE)  
					THEN 1 
					ELSE 0 
					END

	update [MASTER].DateDimension
	set [IsCurrentWeek] = CASE WHEN [Week] = DATEPART(WEEK,GETDATE())  AND [Year] = DATEPART(YEAR,GETDATE())
					THEN 1 
					ELSE 0 
					END

	update [MASTER].DateDimension
	set [IsCurrentMonth] = CASE WHEN [Month] = DATEPART(MONTH,GETDATE())  AND [Year] = DATEPART(YEAR,GETDATE())  
					THEN 1 
					ELSE 0 
					END

	update [MASTER].DateDimension
	set [IsInLast7Days] = CASE WHEN CalendarDate BETWEEN (CAST(DATEADD(DAY,-7,GETDATE()) AS DATE)) AND (CAST(DATEADD(DAY,-1,GETDATE()) AS DATE) )
					THEN 1 
					ELSE 0 
					END

	update [MASTER].DateDimension
	set [IsInLast30Days] = CASE WHEN CalendarDate BETWEEN (CAST(DATEADD(DAY,-30,GETDATE()) AS DATE)) AND (CAST(DATEADD(DAY,-1,GETDATE()) AS DATE) )
					THEN 1 
					ELSE 0 
					END

	
	
	--Update Time Dimension with public holidays
	update datedim
	set [IsPublicHoliday] = 1
	from [MASTER].DateDimension datedim
		inner join [MASTER].PublicHolidays PH
		ON datedim.[CalendarDate] = PH.HolidayDate

--TODO Update School Holidays
	update datedim
	set [IsSchoolHoliday] = 0
	from [MASTER].DateDimension datedim
GO
