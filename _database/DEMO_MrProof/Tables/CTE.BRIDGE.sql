SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [CTE].[BRIDGE](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CalendarDateTime] [datetime] NULL,
	[StockCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BranchKey] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Qty] [int] NULL,
	[rn] [int] NULL
) ON [PRIMARY]

GO
