SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductIsOfProductModelLINK](
	[ProductIsOfProductModelVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductVID] [bigint] NOT NULL,
	[ProductModelVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
