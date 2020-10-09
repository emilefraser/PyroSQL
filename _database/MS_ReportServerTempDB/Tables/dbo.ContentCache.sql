SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ContentCache](
	[ContentCacheID] [bigint] IDENTITY(1,1) NOT NULL,
	[CatalogItemID] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ParamsHash] [int] NULL,
	[EffectiveParams] [nvarchar](max) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ContentType] [nvarchar](256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ExpirationDate] [datetime] NOT NULL,
	[Version] [smallint] NULL,
	[Content] [varbinary](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
