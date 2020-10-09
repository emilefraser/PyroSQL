SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [CTE].[CALCSAT](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LoadDT] [datetime] NULL,
	[CalendarDate] [date] NULL,
	[StockCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Qty] [int] NULL
) ON [PRIMARY]

GO
