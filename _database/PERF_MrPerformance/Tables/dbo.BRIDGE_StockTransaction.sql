SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BRIDGE_StockTransaction](
	[StockTransactionKey] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BranchKey] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StockKey] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LogID] [bigint] NULL,
	[TransactionDate] [datetime] NULL,
	[TransactionCreateDT] [datetime] NULL,
	[QtyAfter] [bigint] NULL,
	[AveCostPerUnit] [decimal](20, 2) NULL,
	[RowCount] [bigint] NULL
) ON [PRIMARY]

GO
