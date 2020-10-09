SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetAReportsReportAction]
@ReportID uniqueidentifier,
@ReportAction int
AS
select
        RS.[ReportAction],
        RS.[ScheduleID],
        RS.[ReportID],
        RS.[SubscriptionID],
        C.[Path],
        C.[Type]
from
    [ReportSchedule] RS Inner join [Catalog] C on RS.[ReportID] = C.[ItemID]
where
    C.ItemID = @ReportID and RS.[ReportAction] = @ReportAction
GO
