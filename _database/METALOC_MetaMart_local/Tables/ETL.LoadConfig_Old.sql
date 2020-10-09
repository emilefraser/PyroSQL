SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[LoadConfig_Old](
	[LoadConfigID] [int] IDENTITY(1,1) NOT NULL,
	[SourceServerName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SourceDatabaseInstanceName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SourceDatabaseName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SourceSchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SourceDataEntityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetServerName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetDatabaseInstanceName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetDatabaseName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetSchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetDataEntityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FieldList] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoadType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsSetForReloadOnNextRun] [bit] NULL,
	[OffsetDays] [int] NULL,
	[NewDataFilterType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrimaryKeyField] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TransactionNoField] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDTField] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdatedDTField] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
