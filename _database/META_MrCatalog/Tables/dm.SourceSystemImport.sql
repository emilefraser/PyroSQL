SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dm].[SourceSystemImport](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceType] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceTableCode] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SourceTableName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetServer] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetDatabase] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetSchema] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetTable]  AS (([SourceTableCode]+'_')+[SourceTableName]),
	[IsInitialRun] [bit] NULL,
	[IsRunNow] [bit] NULL,
	[IsDropAndRecreate] [bit] NULL,
	[HasRun] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
