SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_HumanResources__Shift]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_HumanResources__Shift] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_HumanResources__Shift]
 AS
INSERT INTO [AdventureWorks].[HumanResources__Shift] (
[ShiftID],
[Name],
[StartTime],
[EndTime],
[ModifiedDate]
)
SELECT 
[ShiftID],
[Name],
[StartTime],
[EndTime],
[ModifiedDate]
FROM [AdventureWorks].[HumanResources].[Shift];

GO
