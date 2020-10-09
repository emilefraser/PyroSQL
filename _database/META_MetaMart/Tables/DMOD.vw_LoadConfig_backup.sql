SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[vw_LoadConfig_backup](
	[LoadConfigID] [int] NOT NULL,
	[LoadTypeID] [int] NOT NULL,
	[LoadTypeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadTypeName] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DatabasePurposeID] [int] NULL,
	[DatabasePurposeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DatabasePurposeName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataEntityTypeID] [int] NULL,
	[DataEntityTypeCode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataEntityTypeName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataEntityNamingPrefix] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataEntityNamingSuffix] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[isExternalTable] [bit] NULL,
	[loadtype_IsActive] [bit] NOT NULL,
	[SourceDataEntityID] [int] NOT NULL,
	[TargetDataEntityID] [int] NULL,
	[IsSetForReloadOnNextRun] [bit] NOT NULL,
	[OffsetDays] [int] NULL,
	[config_IsActive] [bit] NOT NULL,
	[CreatedDT_FieldID] [int] NULL,
	[UpdatedDT_FieldID] [int] NULL,
	[Source_DatabaseID] [int] NOT NULL,
	[Source_DB] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Source_DEName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Source_SchemaID] [int] NULL,
	[Source_SchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Target_DatabaseID] [int] NULL,
	[Target_DB] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Target_DEName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Target_SchemaID] [int] NULL,
	[Target_SchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
