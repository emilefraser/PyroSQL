SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[DatabaseCrawler_ErrorHeader](
	[DBCrawlErrorID] [int] IDENTITY(1,1) NOT NULL,
	[CrawlBatchID] [int] NULL,
	[DatabaseInstanceID] [int] NULL,
	[DatabaseID] [int] NULL,
	[ErrorDT] [datetime] NULL,
	[ErrorCount] [bigint] NULL,
	[CrawlSessionStatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
