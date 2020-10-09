SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [ETL].[vw_rpt_ODSLoadMonitoring]
AS
SELECT TOP 2 LoadControlID
		,MAX(ProcessingFinishedDT) AS ProcessingFinishedDT
		,NewRowCount
		,CASE WHEN LoadControlID IN (4,49)
		AND NewRowCount = 0 
		AND DATEADD(MINUTE, -5, GETDATE()) > MAX(ProcessingFinishedDT)
		THEN '1'
		ELSE '0' 
		END AS [ODSLoadFail]
		,CASE WHEN	DATEADD(MINUTE, -5, GETDATE()) > MAX(ProcessingFinishedDT)
		THEN '1'
		ELSE 0 END AS [ODSNotRunning]
FROM [ETL].[LoadControlLog]
WHERE LoadControlID in (4,49)
GROUP BY LoadControlID
		,ProcessingFinishedDT
		,NewRowCount
ORDER BY ProcessingFinishedDT desc

GO
