SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [BALANCE].[AR_Summary](
	[ReportingDate] [date] NULL,
	[NationalAccount] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CustomerNo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CustomerName] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Current] [float] NULL,
	[30 Days] [float] NULL,
	[60 Days] [float] NULL,
	[90 Days] [float] NULL,
	[120 Days] [float] NULL,
	[Total] [float] NULL,
	[Status] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Director] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CRM] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Acc Man] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
