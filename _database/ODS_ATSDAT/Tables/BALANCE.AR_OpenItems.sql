SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [BALANCE].[AR_OpenItems](
	[ReportingDate] [date] NULL,
	[CustomerNo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CustomerName] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TransactionCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DocumentNr] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DocumentDate] [date] NULL,
	[Current] [float] NULL,
	[30 Days] [float] NULL,
	[60 Days] [float] NULL,
	[90 Days] [float] NULL,
	[120 Days] [float] NULL,
	[Total] [float] NULL
) ON [PRIMARY]

GO
