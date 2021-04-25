SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[HumanResources__JobCandidate]') AND type in (N'U'))
BEGIN
CREATE TABLE [AdventureWorks].[HumanResources__JobCandidate](
	[JobCandidateID] [int] NOT NULL,
	[BusinessEntityID] [int] NULL,
	[Resume] [xml] NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
