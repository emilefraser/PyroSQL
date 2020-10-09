SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[backupfile](
	[backup_set_id] [int] NOT NULL,
	[first_family_number] [tinyint] NULL,
	[first_media_number] [smallint] NULL,
	[filegroup_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[page_size] [int] NULL,
	[file_number] [numeric](10, 0) NOT NULL,
	[backed_up_page_count] [numeric](10, 0) NULL,
	[file_type] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[source_file_block_size] [numeric](10, 0) NULL,
	[file_size] [numeric](20, 0) NULL,
	[logical_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[physical_drive] [nvarchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[physical_name] [nvarchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[state] [tinyint] NULL,
	[state_desc] [nvarchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_lsn] [numeric](25, 0) NULL,
	[drop_lsn] [numeric](25, 0) NULL,
	[file_guid] [uniqueidentifier] NULL,
	[read_only_lsn] [numeric](25, 0) NULL,
	[read_write_lsn] [numeric](25, 0) NULL,
	[differential_base_lsn] [numeric](25, 0) NULL,
	[differential_base_guid] [uniqueidentifier] NULL,
	[backup_size] [numeric](20, 0) NULL,
	[filegroup_guid] [uniqueidentifier] NULL,
	[is_readonly] [bit] NULL,
	[is_present] [bit] NULL
) ON [PRIMARY]

GO
