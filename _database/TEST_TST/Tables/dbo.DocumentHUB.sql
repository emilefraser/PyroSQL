SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DocumentHUB](
	[DocumentVID] [bigint] IDENTITY(1,1) NOT NULL,
	[DocumentID] [hierarchyid] NOT NULL
) ON [PRIMARY]

GO