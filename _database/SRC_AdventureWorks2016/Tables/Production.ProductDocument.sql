SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductDocument](
	[ProductID] [int] NOT NULL,
	[DocumentNode] [hierarchyid] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
