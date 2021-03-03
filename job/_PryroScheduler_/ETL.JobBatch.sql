SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[JobBatch](
	[JobBatchID] [int] IDENTITY(1,1) NOT NULL,
	[JobBatchName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[JobBatchDescription] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[JobID_Master] [int] NULL,
	[CreatedDT]  AS (CONVERT([datetime2](7),getdate())),
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
