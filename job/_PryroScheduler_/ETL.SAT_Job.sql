SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[SAT_Job](
	[JobID] [int] IDENTITY(1,1) NOT NULL,
	[JobID_SQL] [uniqueidentifier] NULL,
	[JobName_SQL] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Enabled] [bit] NULL,
	[DateCreated_SQL] [datetime] NULL,
	[DateModified_SQL] [datetime] NULL,
	[JobChecksum] [bigint] NOT NULL,
	[LoadDT] [datetime2](7) NOT NULL
) ON [PRIMARY]

GO
