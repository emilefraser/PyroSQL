SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductModelProductDescriptionCultureLINK](
	[ProductModelProductDescriptionCultureVID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductModelVID] [bigint] NOT NULL,
	[ProductDescriptionVID] [bigint] NOT NULL,
	[CultureID] [bigint] NOT NULL
) ON [PRIMARY]

GO
