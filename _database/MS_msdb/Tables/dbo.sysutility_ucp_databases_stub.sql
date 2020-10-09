SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_databases_stub](
	[urn] [nvarchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[powershell_path] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[processing_time] [datetimeoffset](7) NULL,
	[batch_time] [datetimeoffset](7) NULL,
	[server_instance_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[parent_urn] [nvarchar](320) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Collation] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CompatibilityLevel] [smallint] NULL,
	[CreateDate] [datetime] NULL,
	[EncryptionEnabled] [bit] NULL,
	[Name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RecoveryModel] [smallint] NULL,
	[Trustworthy] [bit] NULL,
	[state] [tinyint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
