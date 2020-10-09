SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[ExecutionLogLastEntry](
	[ExecutionLogLastEntryID] [int] IDENTITY(1,1) NOT NULL,
	[LoadConfigID] [int] NULL,
	[DatabaseName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataEntityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastProcessEntry] [datetime2](7) NULL,
	[LastDataEntry] [datetime2](7) NULL
) ON [PRIMARY]

GO
