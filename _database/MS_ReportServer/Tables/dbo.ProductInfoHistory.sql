SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductInfoHistory](
	[DateTime] [datetime] NULL,
	[DbSchemaHash] [varchar](128) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Sku] [varchar](25) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[BuildNumber] [varchar](25) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL
) ON [PRIMARY]

GO
