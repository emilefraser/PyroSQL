SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[DeleteReportSchedule]
@ScheduleID uniqueidentifier,
@ReportID uniqueidentifier,
@SubscriptionID uniqueidentifier = NULL,
@ReportAction int
AS

IF @SubscriptionID is NULL
BEGIN
delete from ReportSchedule where ScheduleID = @ScheduleID and ReportID = @ReportID and ReportAction = @ReportAction
END
ELSE
BEGIN
delete from ReportSchedule where ScheduleID = @ScheduleID and ReportID = @ReportID and ReportAction = @ReportAction and SubscriptionID = @SubscriptionID
END
GO
