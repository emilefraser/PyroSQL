SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[JobRunOrder](
	[JobRunOrderID] [int] IDENTITY(1,1) NOT NULL,
	[JobBatchID] [int] NULL,
	[JobGroupID] [int] NULL,
	[JobID] [int] NOT NULL,
	[JobRunOrder] [int] NOT NULL,
	[CreatedDT]  AS (CONVERT([datetime2](7),getdate())),
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
