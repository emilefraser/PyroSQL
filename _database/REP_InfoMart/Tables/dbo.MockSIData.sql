SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MockSIData](
	[Due Date] [datetime] NULL,
	[Rate Date] [datetime] NULL,
	[Tax Amount] [decimal](19, 3) NULL,
	[Invoice Total Before Tax] [decimal](19, 3) NULL,
	[Invoice Total After Tax] [decimal](19, 3) NULL,
	[Number of Scheduled Payments] [numeric](18, 0) NULL,
	[Total Payment Amount Scheduled] [numeric](18, 0) NULL,
	[Invoice Number] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Customer Number] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Order Number] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Invoice Date] [datetime] NULL,
	[Fiscal Year] [numeric](18, 0) NULL,
	[Fiscal Period] [numeric](18, 0) NULL,
	[Ship to Location] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Ship to Address] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Ship to City] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Ship to Country] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
