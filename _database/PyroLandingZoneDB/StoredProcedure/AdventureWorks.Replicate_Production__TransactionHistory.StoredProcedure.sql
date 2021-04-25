SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__TransactionHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__TransactionHistory] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__TransactionHistory]
 AS
INSERT INTO [AdventureWorks].[Production__TransactionHistory] (
[TransactionID],
[ProductID],
[ReferenceOrderID],
[ReferenceOrderLineID],
[TransactionDate],
[TransactionType],
[Quantity],
[ActualCost],
[ModifiedDate]
)
SELECT 
[TransactionID],
[ProductID],
[ReferenceOrderID],
[ReferenceOrderLineID],
[TransactionDate],
[TransactionType],
[Quantity],
[ActualCost],
[ModifiedDate]
FROM [AdventureWorks].[Production].[TransactionHistory];

GO
