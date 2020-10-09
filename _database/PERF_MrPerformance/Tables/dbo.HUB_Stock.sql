SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HUB_Stock](
	[HK_STOCK] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoadDT] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RecSrcDataEntityID] [int] NULL,
	[StockID] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastSeenDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
