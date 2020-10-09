SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].[vw_SortOrders] AS
SELECT [SortOrderGroupName],[SortOrderGroupCode],[CreatedDT],[UpdatedDT],[isActive]
FROM MASTER.SortOrderGrouping
--Where [isActive] IS NULL

GO
