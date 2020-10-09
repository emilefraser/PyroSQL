SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmail_configuration](
	[paramname] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[paramvalue] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[description] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_mod_datetime] [datetime] NOT NULL,
	[last_mod_user] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
