SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DEVMNGMT].[EnvironmentRefreshLoadConfig](
	[LoadConfigID] [int] IDENTITY(1,1) NOT NULL,
	[SourceDataEntityID] [int] NOT NULL,
	[TargetDatabaseID] [int] NOT NULL,
	[DateFieldID] [int] NULL,
	[StartDT] [datetime2](7) NULL,
	[EndDT] [datetime2](7) NULL,
	[IsCreateIndexes] [bit] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
