SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [dbo].[ExecutionLog2]
AS
SELECT 
	InstanceName, 
	COALESCE(C.Path, 'Unknown') AS ReportPath, 
	UserName,
	ExecutionId, 
	CASE(RequestType)
		WHEN 0 THEN 'Interactive'
		WHEN 1 THEN 'Subscription'
		ELSE 'Unknown'
		END AS RequestType, 
	-- SubscriptionId, 
	Format, 
	Parameters, 
	CASE(ReportAction)		
		WHEN 1 THEN 'Render'
		WHEN 2 THEN 'BookmarkNavigation'
		WHEN 3 THEN 'DocumentMapNavigation'
		WHEN 4 THEN 'DrillThrough'
		WHEN 5 THEN 'FindString'
		WHEN 6 THEN 'GetDocumentMap'
		WHEN 7 THEN 'Toggle'
		WHEN 8 THEN 'Sort'
		ELSE 'Unknown'
		END AS ReportAction,
	TimeStart, 
	TimeEnd, 
	TimeDataRetrieval, 
	TimeProcessing, 
	TimeRendering,
	CASE(Source)
		WHEN 1 THEN 'Live'
		WHEN 2 THEN 'Cache'
		WHEN 3 THEN 'Snapshot' 
		WHEN 4 THEN 'History'
		WHEN 5 THEN 'AdHoc'
		WHEN 6 THEN 'Session'
		WHEN 7 THEN 'Rdce'
		ELSE 'Unknown'
		END AS Source,
	Status,
	ByteCount,
	[RowCount],
	AdditionalInfo
FROM ExecutionLogStorage EL WITH(NOLOCK)
LEFT OUTER JOIN Catalog C WITH(NOLOCK) ON (EL.ReportID = C.ItemID)

GO
