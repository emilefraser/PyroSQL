SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductSubcategoryBelongsToProductCategoryLINK](
	[ProductSubcategoryBelongsToProductCatego] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductCategoryVID] [bigint] NOT NULL,
	[ProductSubcategoryVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
