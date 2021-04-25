SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_dbo__AWBuildVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_dbo__AWBuildVersion] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_dbo__AWBuildVersion]
 AS
INSERT INTO [AdventureWorks].[dbo__AWBuildVersion] (
[SystemInformationID],
[Database Version],
[VersionDate],
[ModifiedDate]
)
SELECT 
[SystemInformationID],
[Database Version],
[VersionDate],
[ModifiedDate]
FROM [AdventureWorks].[dbo].[AWBuildVersion];

GO
