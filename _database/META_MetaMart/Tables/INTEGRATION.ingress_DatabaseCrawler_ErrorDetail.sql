SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [INTEGRATION].[ingress_DatabaseCrawler_ErrorDetail](
	[DBCrawlErrorDetailID] [int] IDENTITY(1,1) NOT NULL,
	[ErrorCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ErrorDescription] [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DatabaseInstanceID] [int] NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ActualConnectionString] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SQLQueryText] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ErrorDT] [datetime2](7) NOT NULL,
	[CrawlBatchID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
