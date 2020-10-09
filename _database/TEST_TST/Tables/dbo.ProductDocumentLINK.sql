SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductDocumentLINK](
	[ProductDocumentVID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductVID] [bigint] NOT NULL,
	[DocumentVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
