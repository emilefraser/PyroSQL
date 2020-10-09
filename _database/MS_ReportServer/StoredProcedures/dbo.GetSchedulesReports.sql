SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetSchedulesReports]
@ID uniqueidentifier
AS

select
    C.Path
from
    ReportSchedule RS inner join Catalog C on (C.ItemID = RS.ReportID)
where
    ScheduleID = @ID
GO
