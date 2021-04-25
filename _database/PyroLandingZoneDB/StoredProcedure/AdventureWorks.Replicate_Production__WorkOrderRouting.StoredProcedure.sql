SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__WorkOrderRouting]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__WorkOrderRouting] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__WorkOrderRouting]
 AS
INSERT INTO [AdventureWorks].[Production__WorkOrderRouting] (
[WorkOrderID],
[ProductID],
[OperationSequence],
[LocationID],
[ScheduledStartDate],
[ScheduledEndDate],
[ActualStartDate],
[ActualEndDate],
[ActualResourceHrs],
[PlannedCost],
[ActualCost],
[ModifiedDate]
)
SELECT 
[WorkOrderID],
[ProductID],
[OperationSequence],
[LocationID],
[ScheduledStartDate],
[ScheduledEndDate],
[ActualStartDate],
[ActualEndDate],
[ActualResourceHrs],
[PlannedCost],
[ActualCost],
[ModifiedDate]
FROM [AdventureWorks].[Production].[WorkOrderRouting];

GO
