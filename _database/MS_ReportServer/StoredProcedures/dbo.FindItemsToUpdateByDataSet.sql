SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[FindItemsToUpdateByDataSet]
@DataSetID uniqueidentifier
AS

select
        6, /* KpiDataUpdate enum. ToDo: Retrieve this from DB instead*/
        RS.[ScheduleID],
        DS.[ItemID],
        RS.[SubscriptionID],
        C.[Path],
        C.[Type]
from
    [DataSets] DS Inner join [Catalog] C on C.[ItemID] = DS.[ItemID]
    Inner join [ReportSchedule] RS on RS.[ReportID] = DS.[LinkID]
where
    DS.[LinkID] = @DataSetID
GO
