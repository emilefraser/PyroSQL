SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[Database](
	[DatabaseID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AccessInstructions] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Size] [decimal](19, 6) NULL,
	[DatabaseInstanceID] [int] NULL,
	[SystemID] [int] NULL,
	[ExternalDatasourceName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DatabasePurposeID] [int] NULL,
	[DBDatabaseID] [int] NULL,
	[DatabaseEnvironmentTypeID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[LastSeenDT] [datetime2](7) NULL,
	[IsBaseDatabase] [bit] NULL,
	[BaseReferenceDatabaseID] [int] NULL
) ON [PRIMARY]

GO
