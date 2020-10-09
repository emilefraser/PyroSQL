SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[LoadConfig](
	[LoadConfigID] [int] IDENTITY(1,1) NOT NULL,
	[SourceDataEntityID] [int] NOT NULL,
	[TargetDataEntityID] [int] NOT NULL,
	[LoadTypeID] [int] NULL,
	[IsSetForReloadOnNextRun] [bit] NULL,
	[OffsetDays] [int] NULL,
	[NewDataFilterType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrimaryKeyField] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TransactionNoField] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDTField] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdatedDTField] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL
) ON [PRIMARY]

GO