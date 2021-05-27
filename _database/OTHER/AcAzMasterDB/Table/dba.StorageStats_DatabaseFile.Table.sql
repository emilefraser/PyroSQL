SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[StorageStats_DatabaseFile]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[StorageStats_DatabaseFile](
	[StorageStats_DatabaseFileID] [int] IDENTITY(1,1) NOT NULL,
	[BatchID] [int] NULL,
	[file_id] [int] NULL,
	[file_guid] [uniqueidentifier] NULL,
	[file_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[file_type] [int] NULL,
	[file_type_desc] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[file_classification] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[file_path] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[file_drive] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[size_file] [bigint] NULL,
	[max_size] [bigint] NULL,
	[growth] [bigint] NULL,
	[database_id] [int] NOT NULL,
	[SqlServerInstanceName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MachineName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
