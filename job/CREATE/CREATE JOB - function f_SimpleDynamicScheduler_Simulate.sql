-- =============================================
-- Author:		Miljan Radovic
-- Create date: 2016-04-26
-- Description:	This function is used to test schedule run times
-- =============================================
CREATE FUNCTION [dbo].[f_SimpleDynamicScheduler_Simulate]
(
	@pScheduleId int,
	@pPeriodStart datetime,
	@pPeriodEnd datetime,
	@pIncrementInterval char(1),
	@pIncrementValue smallint,
	@pLastRun datetime = null
)
RETURNS @run TABLE 
(
	ScheduleRunTime datetime
)
AS
BEGIN
	declare @Result varchar(200)

	while @pPeriodStart <= dateadd(day, 1, @pPeriodEnd)
	begin

		SELECT @Result = [dbo].[f_SimpleDynamicScheduler_CheckRun](@pScheduleId, @pLastRun, @pPeriodStart)
		if @Result = 'RUN'
		begin
			set @pLastRun = @pPeriodStart
			insert into @run(ScheduleRunTime) values(@pLastRun)
		end

		if @pIncrementInterval = 'H'
			set @pPeriodStart = dateadd(hour, @pIncrementValue, @pPeriodStart)

		if @pIncrementInterval = 'M'
			set @pPeriodStart = dateadd(minute, @pIncrementValue, @pPeriodStart)

		if @pIncrementInterval = 'S'
			set @pPeriodStart = dateadd(second, @pIncrementValue, @pPeriodStart)
	end
	RETURN 
END
