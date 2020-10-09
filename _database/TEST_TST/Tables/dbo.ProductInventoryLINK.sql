SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductInventoryLINK](
	[ProductInventoryVID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductVID] [bigint] NOT NULL,
	[LocationVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
