SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysssispackages](
	[name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[id] [uniqueidentifier] NOT NULL,
	[description] [nvarchar](1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[createdate] [datetime] NOT NULL,
	[folderid] [uniqueidentifier] NOT NULL,
	[ownersid] [varbinary](85) NOT NULL,
	[packagedata] [image] NOT NULL,
	[packageformat] [int] NOT NULL,
	[packagetype] [int] NOT NULL,
	[vermajor] [int] NOT NULL,
	[verminor] [int] NOT NULL,
	[verbuild] [int] NOT NULL,
	[vercomments] [nvarchar](1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[verid] [uniqueidentifier] NOT NULL,
	[isencrypted] [bit] NOT NULL,
	[readrolesid] [varbinary](85) NULL,
	[writerolesid] [varbinary](85) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
