SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[JobDependency](
	[JobRunDependencyID] [int] IDENTITY(1,1) NOT NULL,
	[JobID] [int] NOT NULL,
	[JobDependendOn] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsWarningDependency] [bit] NOT NULL,
	[IsBlockingDependency] [bit] NOT NULL,
	[CreatedDT]  AS (CONVERT([datetime2](7),getdate())),
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
