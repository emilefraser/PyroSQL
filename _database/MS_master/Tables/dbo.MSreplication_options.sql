SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MSreplication_options](
	[optname] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[value] [bit] NOT NULL,
	[major_version] [int] NOT NULL,
	[minor_version] [int] NOT NULL,
	[revision] [int] NOT NULL,
	[install_failures] [int] NOT NULL
) ON [PRIMARY]

GO
