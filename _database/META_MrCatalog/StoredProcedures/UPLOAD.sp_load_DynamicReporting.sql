SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [UPLOAD].[sp_load_DynamicReporting]
AS

DECLARE @Today datetime2(7) = GETDATE()

/* Testing:
TRUNCATE TABLE [DYNREP].[LinkReportField]
TRUNCATE TABLE [DYNREP].[FieldDataValueGroup]
TRUNCATE TABLE [DYNREP].[FieldDataValue]
SELECT * FROM [UPLOAD].[DynamicReporting]
SELECT * FROM [DYNREP].[LinkReportField]
SELECT * FROM [DYNREP].[FieldDataValueGroup]
SELECT * FROM [DYNREP].[FieldDataValue]
SELECT * FROM #uploadnewonly
SELECT * FROM #upload
SELECT * FROM [DYNREP].[vw_egress_DynamicReporting]
*/

--Get only the new entries (avoiding duplicates)
SELECT ReportID, FieldID1, DataValue1, FieldID2, DataValue2, FieldID3, DataValue3
  INTO #uploadnewonly
  FROM [UPLOAD].DynamicReporting upload
 WHERE NOT EXISTS (SELECT 1
					 FROM [DYNREP].[vw_egress_DynamicReporting] vw
					WHERE vw.ReportID = upload.ReportID AND
						  vw.FieldID1 = upload.FieldID1 AND
						  vw.DataValue1 = upload.DataValue1 AND
						  ISNULL(vw.FieldID2, 0) = ISNULL(upload.FieldID2, 0) AND
						  ISNULL(vw.DataValue2, '') = ISNULL(upload.DataValue2, '') AND
						  ISNULL(vw.FieldID3, 0) = ISNULL(upload.FieldID3, 0) AND
						  ISNULL(vw.DataValue3, '') = ISNULL(upload.DataValue3, '')
				  )

--Union the upload table and assign a FieldDataValueGroupID
DECLARE @MaxFieldDataValueGroupID INT = (SELECT ISNULL(MAX(FieldDataValueGroupID), 0) FROM DYNREP.FieldDataValueGroup)
SELECT 1 AS SortOrder,
	   ReportID,
	   FieldID1 AS FieldID,
	   DataValue1 AS DataValue,
	   ROW_NUMBER() OVER(PARTITION BY ReportID ORDER BY ReportID) + @MaxFieldDataValueGroupID AS FieldDataValueGroupID
  INTO #upload
  FROM #uploadnewonly
UNION ALL
SELECT 2 AS SortOrder,
	   ReportID,
	   FieldID2 AS FieldID,
	   DataValue2 AS DataValue,
	   ROW_NUMBER() OVER(PARTITION BY ReportID ORDER BY ReportID) + @MaxFieldDataValueGroupID AS FieldDataValueGroupID
  FROM #uploadnewonly
 WHERE FieldID2 IS NOT NULL
UNION ALL
SELECT 3 AS SortOrder,
	   ReportID,
	   FieldID3 AS FieldID,
	   DataValue3 AS DataValue,
	   ROW_NUMBER() OVER(PARTITION BY ReportID ORDER BY ReportID) + @MaxFieldDataValueGroupID AS FieldDataValueGroupID
  FROM #uploadnewonly
 WHERE FieldID3 IS NOT NULL

--Insert FieldID from Upload table
INSERT INTO [DYNREP].[LinkReportField] (ReportID, FieldID, CreatedDT, IsActive)
SELECT upload.ReportID, upload.FieldID, @Today, 1
FROM (SELECT DISTINCT SortOrder, ReportID, FieldID FROM #upload) upload
WHERE NOT EXISTS (SELECT 1
					FROM [DYNREP].[LinkReportField] lrf
					WHERE lrf.ReportID = upload.ReportID AND
						  lrf.FieldID = upload.FieldID)
ORDER BY upload.SortOrder

INSERT INTO [LOG].[DynamicReportingUploadResult]
VALUES (@Today, '[DYNREP].[LinkReportField]', @@ROWCOUNT)

--Create FieldDataValueGroups if a group for the relevant values doesn't already exist
SET IDENTITY_INSERT [DYNREP].[FieldDataValueGroup] ON

INSERT INTO [DYNREP].[FieldDataValueGroup] (FieldDataValueGroupID, ReportID, CreatedDT, IsActive)
SELECT upload.FieldDataValueGroupID, upload.ReportID, @Today, 1
  FROM (SELECT DISTINCT ReportID, FieldDataValueGroupID FROM #upload) upload

SET IDENTITY_INSERT [DYNREP].[FieldDataValueGroup] OFF

INSERT INTO [LOG].[DynamicReportingUploadResult]
VALUES (@Today, '[DYNREP].[FieldDataValueGroup]', @@ROWCOUNT)

--Insert FieldDataValues
INSERT INTO [DYNREP].[FieldDataValue] (FieldDataValueGroupID, LinkReportFieldID, DataValue, CreatedDT, IsActive)
SELECT upload.FieldDataValueGroupID,
	   lrf.LinkReportFieldID,
	   upload.DataValue,
	   @Today,
	   1
  FROM #upload upload
	   INNER JOIN DYNREP.LinkReportField lrf ON
			lrf.ReportID = upload.ReportID AND
			lrf.FieldID = upload.FieldID

INSERT INTO [LOG].[DynamicReportingUploadResult]
VALUES (@Today, '[DYNREP].[FieldDataValue]', @@ROWCOUNT)

GO
