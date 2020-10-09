SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[backupmediafamily](
	[media_set_id] [int] NOT NULL,
	[family_sequence_number] [tinyint] NOT NULL,
	[media_family_id] [uniqueidentifier] NULL,
	[media_count] [int] NULL,
	[logical_device_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[physical_device_name] [nvarchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[device_type] [tinyint] NULL,
	[physical_block_size] [int] NULL,
	[mirror] [tinyint] NOT NULL
) ON [PRIMARY]

GO
