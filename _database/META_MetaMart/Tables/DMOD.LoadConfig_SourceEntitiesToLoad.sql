SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[LoadConfig_SourceEntitiesToLoad](
	[SourceEntityToLoadID] [int] IDENTITY(1,1) NOT NULL,
	[SourceDataEntityID] [int] NULL,
	[SourceDataEntityName] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceDatabaseID] [int] NOT NULL,
	[SourceSchemaName] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[HasFieldRelation_Source_ODS] [bit] NULL,
	[ODSDataEntityID] [int] NULL,
	[ODSDataEntityName] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HasFieldRelation_Source_Stage] [bit] NULL,
	[StageDataEntityID] [int] NULL,
	[StageDataEntityName] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StageHasKeysTable] [bit] NULL,
	[StageHasVelocityTable] [bit] NULL,
	[StageHasKeysProc] [bit] NULL,
	[StageHasVelocityProc] [bit] NULL,
	[StageIsKeysPopulated] [bit] NULL,
	[StageIsVelocityPopulated] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[ModifiedDT] [datetime2](2) NULL
) ON [PRIMARY]

GO
