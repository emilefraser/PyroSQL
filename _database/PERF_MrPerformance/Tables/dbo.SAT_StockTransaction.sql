SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SAT_StockTransaction](
	[HK_StockTransaction] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoadDT] [datetime2](7) NOT NULL,
	[LoadEndDT] [datetime2](7) NULL,
	[RecSrcDataEntityID] [int] NULL,
	[HashDiff] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Logtime] [datetime] NULL,
	[UserName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Comment] [varchar](180) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Colours] [varchar](180) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Sizes] [varchar](180) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Qty] [int] NULL,
	[QtyBefore] [int] NULL,
	[QtyAfter] [int] NULL,
	[AveCostBefore] [decimal](12, 2) NULL,
	[AveCostAfter] [decimal](12, 2) NULL,
	[MovementType] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TrailType] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GRNCost] [real] NULL,
	[QtyBefore1] [int] NULL,
	[QtyAfter1] [int] NULL,
	[Created_By] [varchar](1020) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Created_Date] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Updated_By] [varchar](1020) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Updated_Date] [datetime] NULL
) ON [PRIMARY]

GO
