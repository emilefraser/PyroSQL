SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__WorkOrder]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__WorkOrder] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__WorkOrder]
 AS
INSERT INTO [AdventureWorks].[Production__WorkOrder] (
[WorkOrderID],
[ProductID],
[OrderQty],
[StockedQty],
[ScrappedQty],
[StartDate],
[EndDate],
[DueDate],
[ScrapReasonID],
[ModifiedDate]
)
SELECT 
[WorkOrderID],
[ProductID],
[OrderQty],
[StockedQty],
[ScrappedQty],
[StartDate],
[EndDate],
[DueDate],
[ScrapReasonID],
[ModifiedDate]
FROM [AdventureWorks].[Production].[WorkOrder];

GO
