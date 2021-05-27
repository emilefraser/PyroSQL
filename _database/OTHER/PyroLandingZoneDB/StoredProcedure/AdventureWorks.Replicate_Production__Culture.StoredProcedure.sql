SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__Culture]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__Culture] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__Culture]
 AS
INSERT INTO [AdventureWorks].[Production__Culture] (
[CultureID],
[Name],
[ModifiedDate]
)
SELECT 
[CultureID],
[Name],
[ModifiedDate]
FROM [AdventureWorks].[Production].[Culture];

GO
