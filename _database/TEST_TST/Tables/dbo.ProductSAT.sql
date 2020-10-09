SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductSAT](
	[ProductVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[FinishedGoodsFlag] [bit] NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ProductNumber] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
