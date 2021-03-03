SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ETL].[JobDependency](
	[JobRunDependencyID] [int] IDENTITY(1,1) NOT NULL,
	[JobID] [int] NOT NULL,
	[JobDependendOn] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsWarningDependency] [bit] NOT NULL,
	[IsBlockingDependency] [bit] NOT NULL,
	[CreatedDT]  AS (CONVERT([datetime2](7),getdate())),
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_JobDependency] PRIMARY KEY CLUSTERED 
(
	[JobRunDependencyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ETL].[JobDependency] ADD  DEFAULT ((0)) FOR [IsWarningDependency]
GO
ALTER TABLE [ETL].[JobDependency] ADD  DEFAULT ((0)) FOR [IsBlockingDependency]
GO
ALTER TABLE [ETL].[JobDependency] ADD  DEFAULT ((1)) FOR [IsActive]
GO
