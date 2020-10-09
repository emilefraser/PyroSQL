SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[LoadConfig](
	[LoadConfigID] [int] IDENTITY(1,1) NOT NULL,
	[SourceServerName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceDatabaseInstanceName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceDatabaseName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceSchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceDataEntityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetServerName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetDatabaseInstanceName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetDatabaseName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetSchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetDataEntityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FieldList] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IndexFieldList] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsClustered] [bit] NULL,
	[LoadType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsSetForReloadOnNextRun] [bit] NULL,
	[OffsetDays] [int] NULL,
	[NewDataFilterType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrimaryKeyField] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TransactionNoField] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDTField] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDTFieldDataType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdatedDTField] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdatedDTFieldDataType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
