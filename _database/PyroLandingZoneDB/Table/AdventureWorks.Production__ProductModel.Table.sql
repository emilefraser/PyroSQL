SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Production__ProductModel]') AND type in (N'U'))
BEGIN
CREATE TABLE [AdventureWorks].[Production__ProductModel](
	[ProductModelID] [int] NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[CatalogDescription] [xml] NULL,
	[Instructions] [xml] NULL,
	[rowguid] [uniqueidentifier] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
