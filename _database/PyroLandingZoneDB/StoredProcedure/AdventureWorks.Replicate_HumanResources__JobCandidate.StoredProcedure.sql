SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_HumanResources__JobCandidate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_HumanResources__JobCandidate] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_HumanResources__JobCandidate]
 AS
INSERT INTO [AdventureWorks].[HumanResources__JobCandidate] (
[JobCandidateID],
[BusinessEntityID],
[Resume],
[ModifiedDate]
)
SELECT 
[JobCandidateID],
[BusinessEntityID],
[Resume],
[ModifiedDate]
FROM [AdventureWorks].[HumanResources].[JobCandidate];

GO
