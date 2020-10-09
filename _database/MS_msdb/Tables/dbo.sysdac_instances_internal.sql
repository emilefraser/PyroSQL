SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysdac_instances_internal](
	[instance_id] [uniqueidentifier] NOT NULL,
	[instance_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[type_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[type_version] [nvarchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[type_stream] [varbinary](max) NOT NULL,
	[date_created] [datetime] NOT NULL,
	[created_by] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
