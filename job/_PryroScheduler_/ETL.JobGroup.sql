SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[JobGroup](
	[JobGroupID] [int] IDENTITY(1,1) NOT NULL,
	[JobGroupName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[JobID] [int] NOT NULL,
	[CreatedDT]  AS (CONVERT([datetime2](7),getdate())),
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
