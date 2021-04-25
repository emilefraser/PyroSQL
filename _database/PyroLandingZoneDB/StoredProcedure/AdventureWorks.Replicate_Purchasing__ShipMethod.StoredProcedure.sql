SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Purchasing__ShipMethod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Purchasing__ShipMethod] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Purchasing__ShipMethod]
 AS
INSERT INTO [AdventureWorks].[Purchasing__ShipMethod] (
[ShipMethodID],
[Name],
[ShipBase],
[ShipRate],
[rowguid],
[ModifiedDate]
)
SELECT 
[ShipMethodID],
[Name],
[ShipBase],
[ShipRate],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Purchasing].[ShipMethod];

GO
