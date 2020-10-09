SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[external_libraries_installed](
	[db_id] [int] NOT NULL,
	[principal_id] [int] NOT NULL,
	[language_id] [int] NOT NULL,
	[external_library_id] [int] NOT NULL,
	[name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[mdversion] [binary](8) NOT NULL
) ON [PRIMARY]

GO
