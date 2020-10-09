SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DocumentBelongsToParentDocumentLINK](
	[DocumentBelongsToParentDocumentVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[DocumentVID] [bigint] NOT NULL,
	[ParentDocumentVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
