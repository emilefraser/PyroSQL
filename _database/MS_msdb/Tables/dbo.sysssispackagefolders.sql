SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysssispackagefolders](
	[folderid] [uniqueidentifier] NOT NULL,
	[parentfolderid] [uniqueidentifier] NULL,
	[foldername] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
