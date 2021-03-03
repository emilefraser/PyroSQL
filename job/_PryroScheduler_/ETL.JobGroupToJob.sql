SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[JobGroupToJob](
	[JobGroupToJobID] [int] IDENTITY(1,1) NOT NULL,
	[JobGroupID] [int] NOT NULL,
	[JobID] [int] NOT NULL,
	[LoadDT]  AS (CONVERT([datetime2](7),getdate()))
) ON [PRIMARY]

GO
