SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BusinessEntityContactLINK](
	[BusinessEntityContactVID] [bigint] IDENTITY(1,1) NOT NULL,
	[BusinessEntityVID] [bigint] NOT NULL,
	[PersonVID] [bigint] NOT NULL,
	[ContactTypeID] [bigint] NOT NULL
) ON [PRIMARY]

GO
