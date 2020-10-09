SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[LoadControl](
	[LoadControlID] [int] NOT NULL,
	[LoadConfigID] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[QueuedForProcessingDT] [datetime2](7) NULL,
	[ProcessingStartDT] [datetime2](7) NULL,
	[ProcessingFinishedDT] [datetime2](7) NULL,
	[LastProcessingPrimaryKey] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastProcessingTransactionNo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastProcessingCreateDT] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastProcessingUpdateDT] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NewRecordDDL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdatedRecordDDL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateTempTableDDL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TempTableName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateStatementDDL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GetLastProcessingKeyValueDDL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DeleteStatementDDL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsLastRunFailed] [bit] NULL,
	[ProcessingState] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NextScheduledRunTime] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
