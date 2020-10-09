SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmail_principalprofile](
	[profile_id] [int] NOT NULL,
	[principal_sid] [varbinary](85) NOT NULL,
	[is_default] [bit] NOT NULL,
	[last_mod_datetime] [datetime] NOT NULL,
	[last_mod_user] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
