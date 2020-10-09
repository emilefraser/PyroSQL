SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[ArchiveControl](
	[ArchiveControlID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Tablename] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[IsDataExportedToCSV] [bit] NULL,
	[IsArchivedToBlob] [bit] NULL,
	[IsSchemaScriptCreated] [bit] NULL,
	[IsDeleted] [bit] NULL
) ON [PRIMARY]

GO
