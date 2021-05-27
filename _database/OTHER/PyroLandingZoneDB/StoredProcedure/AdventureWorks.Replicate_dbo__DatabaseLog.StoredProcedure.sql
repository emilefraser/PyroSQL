SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_dbo__DatabaseLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_dbo__DatabaseLog] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_dbo__DatabaseLog]
 AS
INSERT INTO [AdventureWorks].[dbo__DatabaseLog] (

)
SELECT 
[DatabaseLogID],
[PostTime],
[DatabaseUser],
[Event],
[Schema],
[Object],
[TSQL],
[XmlEvent]
FROM [AdventureWorks].[dbo].[DatabaseLog];

GO
