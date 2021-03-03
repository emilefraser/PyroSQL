SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[Job](
	[JobID] [int] IDENTITY(1,1) NOT NULL,
	[JobName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[JobID_SQL] [uniqueidentifier] NULL,
	[JobName_SQL] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT]  AS (CONVERT([datetime2](7),getdate())),
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
