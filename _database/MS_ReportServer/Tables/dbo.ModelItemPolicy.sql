SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ModelItemPolicy](
	[ID] [uniqueidentifier] NOT NULL,
	[CatalogItemID] [uniqueidentifier] NOT NULL,
	[ModelItemID] [nvarchar](425) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PolicyID] [uniqueidentifier] NOT NULL
) ON [PRIMARY]

GO
