SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysdownloadlist](
	[instance_id] [int] IDENTITY(1,1) NOT NULL,
	[source_server] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[operation_code] [tinyint] NOT NULL,
	[object_type] [tinyint] NOT NULL,
	[object_id] [uniqueidentifier] NOT NULL,
	[target_server] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[error_message] [nvarchar](1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[date_posted] [datetime] NOT NULL,
	[date_downloaded] [datetime] NULL,
	[status] [tinyint] NOT NULL,
	[deleted_object_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
