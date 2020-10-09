SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[LoadGroupControlDetail](
	[LoadGroupControlDetailID] [int] IDENTITY(1,1) NOT NULL,
	[LoadGroupControlID] [int] NULL,
	[LoadPriority] [int] NULL,
	[ParentLoadControlID] [int] NULL,
	[SourceDataEntityID] [int] NULL,
	[TargetDataEntityID] [int] NULL,
	[NewRecordDDL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdatedRecordsDDL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateStatementDDL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DeleteStatementDDL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsStoredProc] [bit] NULL,
	[StoredProcedureDDL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateTempTableDDL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TempTableName] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GetLastProcessingKeyValueDDL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastProcessingValue] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ProcessingStartDT] [datetime2](7) NULL,
	[ProcessingFinishedDT] [datetime2](7) NULL,
	[IsLastRunFailed] [bit] NULL,
	[ProcessingState] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NextScheduledRunDT] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
