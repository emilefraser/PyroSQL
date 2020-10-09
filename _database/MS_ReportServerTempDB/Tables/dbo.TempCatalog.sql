SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TempCatalog](
	[EditSessionID] [varchar](32) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TempCatalogID] [uniqueidentifier] NOT NULL,
	[ContextPath] [nvarchar](425) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Name] [nvarchar](425) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Content] [varbinary](max) NULL,
	[Description] [nvarchar](max) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Intermediate] [uniqueidentifier] NULL,
	[IntermediateIsPermanent] [bit] NOT NULL,
	[Property] [nvarchar](max) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Parameter] [nvarchar](max) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OwnerID] [uniqueidentifier] NOT NULL,
	[CreationTime] [datetime] NOT NULL,
	[ExpirationTime] [datetime] NOT NULL,
	[DataCacheHash] [varbinary](64) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
