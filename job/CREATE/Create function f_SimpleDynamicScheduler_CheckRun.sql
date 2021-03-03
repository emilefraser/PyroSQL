-- =============================================
-- Author:		Miljan Radovic
-- Create date: 2015-04-22
-- Description:	Function which determines if caller should run or not based on custom scheduler
-- =============================================
-- 2016-05-23: Added ValidDays parameter which controls what days are valid for any schedule.
--             For example, with this new functionality we can control if schedule can be run on weekend or not by setting valid only days from Monday to Friday. 
-- =============================================
CREATE FUNCTION [dbo].[f_SimpleDynamicScheduler_CheckRun]
(
	@pScheduleId int,
	@pLastRun datetime,
	@pCurrentDate datetime = null
)
RETURNS VARCHAR(200) -- 'RUN' means RUN, 'HOLD' means don't run, anything else is an error
AS
BEGIN

	declare @date date
	declare @datetime datetime
	declare @time time(0)
	declare @counter int

	declare @t_days table
	(
		[the_day] tinyint not null
	)

	declare @t_valid_days table
	(
		[the_day_name] varchar(20) not null,
		[diff] tinyint not null
	)

	declare @t_times table
	(
		[the_time] [time](0)
	)

	declare @Enabled bit
	declare @Type char(1)
	declare @Frequency char(1)
	declare @StartDate date
	declare @EndDate date
	declare @TimeStart time(0)
	declare @RecurseEvery tinyint
	declare @DailyFrequency char(1)
	declare @OccursEveryValue tinyint
	declare @OccursEveryTimeUnit char(1)
	declare @TimeEnd time(0)
	declare @DaysOfWeek varchar(20)
	declare @MonthlyOccurrence char(1)
	declare @ExactDateOfMonth tinyint
	declare @ExactWeekdayOfMonth char(2)
	declare @ExactWeekdayOfMonthEvery tinyint
	declare @ValidDays varchar(20)

	select
		@Type = [Type],
		@Frequency = Frequency,
		@StartDate = StartDate,
		@EndDate = EndDate,
		@TimeStart = TimeStart,
		@Enabled = [Enabled],
		@RecurseEvery = RecurseEvery,
		@DailyFrequency = DailyFrequency,
		@OccursEveryValue = OccursEveryValue,
		@OccursEveryTimeUnit = OccursEveryTimeUnit,
		@TimeEnd = TimeEnd,
		@DaysOfWeek = DaysOfWeek,
		@MonthlyOccurrence = MonthlyOccurrence,
		@ExactDateOfMonth = ExactDateOfMonth,
		@ExactWeekdayOfMonth = ExactWeekdayOfMonth,
		@ExactWeekdayOfMonthEvery = ExactWeekdayOfMonthEvery,
		@ValidDays = ValidDays
	from [dbo].[SimpleDynamicScheduler]
	where Id = @pScheduleId


	-- ============================================================
	-- SCHEDULE VALIDITY CHECKS
	-- ============================================================

	-- Enabled
	if @Enabled is null
		return 'Enabled must have value!'

	-- Type
	if @Type is null
		return 'Type must have value!'

	if @Type not in ('O', 'R')
		return 'Wrong Type value! Valid entries are ''O'' = One Time and ''R'' = Recurring.'

	-- StartDate
	if @StartDate is null
		return 'StartDate must have value!'

	-- TimeStart
	if @TimeStart is null
		return 'TimeStart must have value!'

	-- EndDate
	if @EndDate is not null and @EndDate < @StartDate
		return 'If defined, EndDate must be greater than StartDate!'

	-- Frequency
	if @Type = 'R' and @Frequency is null
		RETURN 'Frequency must have value for recurring schedules (Type = R)!'

	if @Type = 'R' and @Frequency not in ('D', 'W', 'M')
		RETURN 'Wrong Frequency value! Valid entries are ''D'' = Daily, ''W'' = Weekly and ''M'' = Monthly.'

	-- RecurseEvery
	if @Type = 'R' and @RecurseEvery is null
		RETURN 'RecurseEvery must have value for recurring schedules (Type = R)!'

	-- DailyFrequency
	if @Type = 'R' and @DailyFrequency is null
		RETURN 'DailyFrequency must have value for recurring schedules (Type = R)!'

	if @Type = 'R' and @DailyFrequency not in ('O', 'E')
		RETURN 'Wrong DailyFrequency value! Valid entries are ''O'' = Once and ''E'' = Every.'

	-- OccursEveryValue
	if @Type = 'R' and @DailyFrequency = 'E' and @OccursEveryValue is null
		RETURN 'OccursEveryValue must have value for recurring schedules (Type = R) with multiple daily schedules (DailyFrequency = E)!'

	-- OccursEveryTimeUnit
	if @Type = 'R' and @DailyFrequency = 'E' and @OccursEveryTimeUnit is null
		RETURN 'OccursEveryTimeUnit must have value for recurring schedules (Type = R) with multiple daily schedules (DailyFrequency = E)!'
	if @Type = 'R' and @DailyFrequency = 'E' and @OccursEveryTimeUnit not in ('H', 'M', 'S')
		RETURN 'Wrong OccursEveryTimeUnit value! Valid entries are ''H'' = Hour, ''M'' = minute and ''S'' = Second.'

	-- TimeEnd
	if @Type = 'R' and @DailyFrequency = 'E' and @TimeEnd is null
		RETURN 'TimeEnd must have value for recurring schedules (Type = R) with multiple daily schedules (DailyFrequency = E)!'
	if @Type = 'R' and @DailyFrequency = 'E' and @TimeEnd is not null and @TimeEnd <= @TimeStart
		RETURN 'TimeEnd must be greater than TimeStart!'

	-- DaysOfWeek
	if @Type = 'R' and @Frequency = 'W' and @DaysOfWeek is null
		RETURN 'DaysOfWeek must have value for recurring schedules (Type = R) of weekly frequency (Frequency = W)!'

	-- MonthlyOccurrence
	if @Type = 'R' and @Frequency = 'M' and @MonthlyOccurrence is null
		RETURN 'MonthlyOccurrence must have value for recurring schedules (Type = R) of monthly frequency (Frequency = M)!'
	if @Type = 'R' and @Frequency = 'M' and @MonthlyOccurrence not in ('D', 'W')
		RETURN 'Wrong MonthlyOccurrence value! Valid entries are ''D'' = On the exact date and ''W'' = On the exact weekday.'

	-- ExactDateOfMonth
	if @Type = 'R' and @Frequency = 'M' and @MonthlyOccurrence = 'D' and @ExactDateOfMonth is null
		RETURN 'ExactDateOfMonth must have value for recurring schedules (Type = R) of monthly frequency (Frequency = M) on the exact date (MonthlyOccurrence = D)!'
	if @Type = 'R' and @Frequency = 'M' and @MonthlyOccurrence = 'D' and @ExactDateOfMonth not between 1 and 31
		RETURN 'Wrong ExactDateOfMonth value! Valid entries are numerics between 1 and 31.'

	-- ExactWeekdayOfMonth
	if @Type = 'R' and @Frequency = 'M' and @MonthlyOccurrence = 'W' and @ExactWeekdayOfMonth is null
		RETURN 'ExactWeekdayOfMonth must have value for recurring schedules (Type = R) of monthly frequency (Frequency = M) on the exact weekday (MonthlyOccurrence = W)!'
	if @Type = 'R' and @Frequency = 'M' and @MonthlyOccurrence = 'W' and @ExactWeekdayOfMonth not in ('Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su')
		RETURN 'Wrong ExactWeekdayOfMonth value! Valid entries are ''Mo'' = Monday, ''Tu'', ''We'', ''Th'', ''Fr'', ''Sa'', ''Su'' = Sunday.'

	-- ExactWeekdayOfMonthEvery
	if @Type = 'R' and @Frequency = 'M' and @MonthlyOccurrence = 'W' and @ExactWeekdayOfMonthEvery is null
		RETURN 'ExactWeekdayOfMonthEvery must have value for recurring schedules (Type = R) of monthly frequency (Frequency = M) on the exact weekday (MonthlyOccurrence = W)!'


	set @pLastRun = isnull(@pLastRun, '19000101')
	set @EndDate = ISNULL(@EndDate, '99991231')


	if @Enabled = 0
		return 'STOP'

	if convert(date, @pCurrentDate) < @StartDate or convert(date, @pCurrentDate) > @EndDate
		return 'STOP'


	-- ============================================================
	-- ONE TIME SCHEDULER
	-- ============================================================

	if @Type = 'O' 
	begin
		set @datetime = cast(@StartDate as datetime) + cast(@TimeStart as datetime)
	end


	-- ============================================================
	-- RECURRING SCHEDULERS
	-- ============================================================

	if @Type = 'R'
	begin

		-- PREPARE TEMPORARY TABLES

		-- Times
		insert into @t_times(the_time) values (@TimeStart)

		if @DailyFrequency = 'E'
		begin
			set @time = @TimeStart

			while @time <= @TimeEnd
			begin
				if @OccursEveryTimeUnit = 'H'
					set @time = dateadd(hour, @OccursEveryValue, @time)
				else if @OccursEveryTimeUnit = 'M'
					set @time = dateadd(minute, @OccursEveryValue, @time)
				else if @OccursEveryTimeUnit = 'S'
					set @time = dateadd(second, @OccursEveryValue, @time)

				if @time <= @TimeEnd
					insert into @t_times(the_time) values (@time)
			end
		end

		if @Frequency = 'W'
		begin
			-- Get days of week
			if CHARINDEX('Mo', @DaysOfWeek) > 0
				insert into @t_days(the_day) values (0)
			if CHARINDEX('Tu', @DaysOfWeek) > 0
				insert into @t_days(the_day) values (1)
			if CHARINDEX('We', @DaysOfWeek) > 0
				insert into @t_days(the_day) values (2)
			if CHARINDEX('Th', @DaysOfWeek) > 0
				insert into @t_days(the_day) values (3)
			if CHARINDEX('Fr', @DaysOfWeek) > 0
				insert into @t_days(the_day) values (4)
			if CHARINDEX('Sa', @DaysOfWeek) > 0
				insert into @t_days(the_day) values (5)
			if CHARINDEX('Su', @DaysOfWeek) > 0
				insert into @t_days(the_day) values (6)
		end


		-- Get days of week
		;with cte as
		(
			select 0 as the_day, case when @ValidDays is null or CHARINDEX('Mo', @ValidDays) > 0 then 1 else 0 end as is_valid
			union all
			select 1, case when @ValidDays is null or CHARINDEX('Tu', @ValidDays) > 0 then 1 else 0 end
			union all
			select 2, case when @ValidDays is null or CHARINDEX('We', @ValidDays) > 0 then 1 else 0 end
			union all
			select 3, case when @ValidDays is null or CHARINDEX('Th', @ValidDays) > 0 then 1 else 0 end
			union all
			select 4, case when @ValidDays is null or CHARINDEX('Fr', @ValidDays) > 0 then 1 else 0 end
			union all
			select 5, case when @ValidDays is null or CHARINDEX('Sa', @ValidDays) > 0 then 1 else 0 end
			union all
			select 6, case when @ValidDays is null or CHARINDEX('Su', @ValidDays) > 0 then 1 else 0 end
		)
		insert into @t_valid_days(the_day_name, diff)
		select datename(dw, vd1.the_day)
			, case
				when vd1.is_valid = 1 then 0
				when min(vd2.the_day) is not null then min(vd2.the_day) - vd1.the_day else min(vd3.the_day) + 7 - vd1.the_day
			end 
			as diff
		from cte vd1
		left join cte vd2 on vd2.the_day > vd1.the_day and vd2.is_valid = 1
		left join cte vd3 on vd3.the_day < vd1.the_day and vd3.is_valid = 1
		group by vd1.the_day, vd1.is_valid
		order by vd1.the_day




		-- End temporary table preparation


		-- ============================================================
		-- DAILY RECURRING SCHEDULER
		-- ============================================================
		if @Frequency = 'D'
		begin
			set @date = @StartDate

			while dateadd(day, @RecurseEvery, @date) <= convert(date, @pCurrentDate)
				set @date = dateadd(day, @RecurseEvery, @date)

			;with cte as
			(
				select convert(datetime, @date) + convert(datetime, the_time) as the_datetime
				from @t_times
			)
			select @datetime = max(the_datetime)
			from cte
			where the_datetime <= @pCurrentDate
		end

		-- ============================================================
		-- WEEKLY RECURRING SCHEDULER
		-- ============================================================
		if @Frequency = 'W'
		begin
			set @date = @StartDate
		
			-- Go to the beginning of the week - Monday
			while datepart(dw, @date) <> 1 -- Monday
				set @date = dateadd(day, -1, @date)

			-- Find last week before @pCurrentDate
			while dateadd(week, @RecurseEvery, @date) <= convert(date, @pCurrentDate)
				set @date = dateadd(week, @RecurseEvery, @date)

			-- Get biggest datetime less than CurrentDate
			;with cte as
			(
				select convert(datetime, dateadd(day, d.the_day, @date)) + convert(datetime, t.the_time) as the_datetime
				from @t_days d
				cross join @t_times t
			)
			select @datetime = max(the_datetime)
			from cte
			where the_datetime <= @pCurrentDate
		end

		-- ============================================================
		-- MONTHLY RECURRING SCHEDULER
		-- ============================================================
		if @Frequency = 'M'
		begin
			set @date = @StartDate
		
			-- Go to the beginning of the month
			set @date = DATEADD(month, DATEDIFF(month, 0, @date), 0)

			-- Find last month before @pCurrentDate
			while dateadd(month, @RecurseEvery, @date) <= convert(date, @pCurrentDate)
				set @date = dateadd(month, @RecurseEvery, @date)

			-- ============================================================
			-- MONTHLY RECURRING SCHEDULER ON EXACT DAY / DATE
			-- ============================================================
			if @MonthlyOccurrence = 'D'
			begin
				-- Go to exact day of the month
				set @date = dateadd(day, @ExactDateOfMonth - 1, @date)
			end

			-- ============================================================
			-- MONTHLY RECURRING SCHEDULER ON EXACT WEEKDAY
			-- ============================================================
			else if @MonthlyOccurrence = 'W'
			begin
				-- Go to exact weekday of the month
				set @counter = 0
				while @counter < @ExactWeekdayOfMonthEvery
				begin
					if @ExactWeekdayOfMonth = left(datename(dw, @date), 2)
						set @counter = @counter + 1
					if @counter < @ExactWeekdayOfMonthEvery
						set @date = dateadd(day, 1, @date)
				end
			end
		
			-- Get biggest datetime less than CurrentDate
			;with cte as
			(
				select convert(datetime, @date) + convert(datetime, the_time) as the_datetime
				from @t_times
			)
			select @datetime = max(the_datetime)
			from cte
			where the_datetime <= @pCurrentDate
			
		end
	end

	-- ============================================================
	-- MOVE TO NEXT VALID DAY IF NECESSARY
	-- ============================================================

	select @datetime = dateadd(day, [diff], @datetime)
	from @t_valid_days
	where the_day_name = datename(dw, @datetime)

	-- ============================================================
	-- MAIN CHECK FOR ALL TYPES OF SCHEDULERS
	-- ============================================================

	if @datetime > @pLastRun and @datetime <= @pCurrentDate and convert(date, @datetime) >= @StartDate and convert(date, @datetime) <= @EndDate
		return 'RUN'

	RETURN 'HOLD'
END