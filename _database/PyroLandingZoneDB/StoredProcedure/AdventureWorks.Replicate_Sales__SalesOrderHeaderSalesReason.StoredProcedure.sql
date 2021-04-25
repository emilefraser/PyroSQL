SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__SalesOrderHeaderSalesReason]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__SalesOrderHeaderSalesReason] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__SalesOrderHeaderSalesReason]
 AS
INSERT INTO [AdventureWorks].[Sales__SalesOrderHeaderSalesReason] (
[SalesOrderID],
[SalesReasonID],
[ModifiedDate]
)
SELECT 
[SalesOrderID],
[SalesReasonID],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[SalesOrderHeaderSalesReason];

GO
