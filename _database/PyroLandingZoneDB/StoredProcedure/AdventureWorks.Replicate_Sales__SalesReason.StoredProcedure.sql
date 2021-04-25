SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Sales__SalesReason]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Sales__SalesReason] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Sales__SalesReason]
 AS
INSERT INTO [AdventureWorks].[Sales__SalesReason] (
[SalesReasonID],
[Name],
[ReasonType],
[ModifiedDate]
)
SELECT 
[SalesReasonID],
[Name],
[ReasonType],
[ModifiedDate]
FROM [AdventureWorks].[Sales].[SalesReason];

GO
