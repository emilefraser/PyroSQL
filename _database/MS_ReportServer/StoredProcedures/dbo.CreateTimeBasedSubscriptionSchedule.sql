SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[CreateTimeBasedSubscriptionSchedule]
@SubscriptionID as uniqueidentifier,
@ScheduleID uniqueidentifier,
@Schedule_Name nvarchar (260),
@ItemPath nvarchar (425),
@Action int,
@StartDate datetime,
@Flags int,
@NextRunTime datetime = NULL,
@LastRunTime datetime = NULL,
@EndDate datetime = NULL,
@RecurrenceType int = NULL,
@MinutesInterval int = NULL,
@DaysInterval int = NULL,
@WeeksInterval int = NULL,
@DaysOfWeek int = NULL,
@DaysOfMonth int = NULL,
@Month int = NULL,
@MonthlyWeek int = NULL,
@State int = NULL,
@LastRunStatus nvarchar (260) = NULL,
@ScheduledRunTimeout int = NULL,
@UserSid varbinary (85) = NULL,
@UserName nvarchar(260),
@AuthType int,
@EventType nvarchar (260),
@EventData nvarchar (260),
@Path nvarchar (425) = NULL
AS

EXEC CreateTask @ScheduleID, @Schedule_Name, @StartDate, @Flags, @NextRunTime, @LastRunTime,
        @EndDate, @RecurrenceType, @MinutesInterval, @DaysInterval, @WeeksInterval, @DaysOfWeek,
        @DaysOfMonth, @Month, @MonthlyWeek, @State, @LastRunStatus,
        @ScheduledRunTimeout, @UserSid, @UserName, @AuthType, @EventType, @EventData, 1 /*scoped type*/, @Path

if @@ERROR = 0
begin
    -- add a row to the reportSchedule table
    declare @ItemID uniqueidentifier
    select @ItemID = [ItemID] from [Catalog] with (HOLDLOCK) where [Catalog].[Path] = @ItemPath and ([Catalog].[Type] = 2 or [Catalog].[Type] = 4 or [Catalog].[Type] = 8 or [Catalog].[Type] = 13)
    EXEC AddReportSchedule @ScheduleID, @ItemID, @SubscriptionID, @Action
end
GO
