SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[LoadConfig]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[LoadConfig](
	[LoadConfigID] [int] IDENTITY(1,1) NOT NULL,
	[LoadTypeCode] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceSystemName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceEntityType] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceIntegrationRuntime] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceServerName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceDatabaseInstanceName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceDatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceSchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceEntityName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceQuotedIdentifierID] [int] NULL,
	[TargetSystemName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetEntityType] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetIntegrationRuntime] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetServerName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetDatabaseInstanceName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetDatabaseName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetSchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetEntityName]  AS ([adf].[GetSapEntityNameAndDescription]([SourceEntityName],'E')),
	[TargetQuotedIdentifierID] [int] NULL,
	[PrimaryKeyColumnListId] [int] NULL,
	[IsCdcCreatedExternal] [bit] NULL,
	[CdcCreatedDateColumn] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CdcCreatedDateValue_Last] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CdcCreatedTimeColumn] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CdcCreatedTimeValue_Last] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsCdcUpdatedExternal] [bit] NULL,
	[CdcUpdatedDateColumn] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CdcUpdatedDateValue_Last] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CdcUpdatedTimeColumn] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CdcUpdatedTimeValue_Last] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExCdcJoinType] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExCdcSystemName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExCdcEntityType] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExCdcServerName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExCdcDatabaseInstanceName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExCdcDatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExCdcSchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExCdcEntityName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExCdcQuotedIdentifierID] [int] NULL,
	[IsDropAndRecreateTarget] [bit] NULL,
	[IsTruncateAndReloadTarget] [bit] NULL,
	[LoadEnvironmentID] [int] NULL,
	[IsValid] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[LastLoadStartDT] [datetime2](7) NULL,
	[LastLoadEndDT] [datetime2](7) NULL,
	[LastLoadResult] [smallint] NULL,
	[LoadStatus] [bit] NULL,
	[IsActive] [bit] NULL,
	[FieldListForDDL]  AS ([adf].[GetSapEntityColumnList]([SourceEntityName],'E')),
	[TargetRC] [int] NULL,
	[FieldListForSelect]  AS ([adf].[GetSapEntityColumnList_SOURCE]([SourceEntityName],'E')),
	[IsUseStageTable] [bit] NULL,
 CONSTRAINT [PK_ADF_LoadConfig] PRIMARY KEY CLUSTERED 
(
	[LoadConfigID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
