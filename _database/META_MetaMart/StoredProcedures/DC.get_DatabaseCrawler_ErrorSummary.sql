SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [DC].[get_DatabaseCrawler_ErrorSummary]
AS

-- Summarize the info from the [INTEGRATION].[ingress_DatabaseCrawler_ErrorDetail] table
INSERT INTO [DC].[DatabaseCrawler_ErrorHeader]
			(CrawlBatchID, DatabaseInstanceID, DatabaseID, ErrorDT, ErrorCount)
SELECT	DISTINCT CrawlBatchID, DatabaseInstanceID, DatabaseID
		, GETDATE() as ErrorDT
		, COUNT(DBCrawlErrorDetailID) as ErrorCount
FROM	[INTEGRATION].[ingress_DatabaseCrawler_ErrorDetail]
WHERE	NOT EXISTS
					(
						SELECT	DISTINCT CrawlBatchID 
						FROM	DC.DatabaseCrawler_ErrorHeader
					)
GROUP BY CrawlBatchID, DatabaseInstanceID, DatabaseID

-- Update the crawl session status
UPDATE	DC.DatabaseCrawler_ErrorHeader
SET		CrawlSessionStatus =  CASE WHEN ErrorCount > 0
								THEN 'Errors Occured during crawel'
								ELSE 'Successful Crawl'
							  END
WHERE	CrawlSessionStatus IS NULL


--TODO: Add insert statement to insert into DC.DatabaseCrawler_ErrorDetail table

GO
