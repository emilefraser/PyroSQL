SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__Location]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__Location] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__Location]
 AS
INSERT INTO [AdventureWorks].[Production__Location] (
[LocationID],
[Name],
[CostRate],
[Availability],
[ModifiedDate]
)
SELECT 
[LocationID],
[Name],
[CostRate],
[Availability],
[ModifiedDate]
FROM [AdventureWorks].[Production].[Location];

GO
