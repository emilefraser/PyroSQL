SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[adf].[GetReleaseConfig]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [adf].[GetReleaseConfig]
AS
SELECT *
FROM  (
SELECT [ReleaseID]
      ,[ReleaseType]
      ,[AzureAccount]
      ,[AzureContainer]
      ,[ReleaseBlobPath]
      ,[ReleaseDate]
      ,[ReleaseName]
      ,[IsActive]
	  ,ROW_NUMBER() OVER (ORDER BY ReleaseID) AS rn
  FROM [adf].[ReleaseConfig]
  WHERE IsActive = 1
) AS sq
WHERE sq.rn = 1
' 
GO
