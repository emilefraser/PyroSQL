SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [UPLOAD].[sp_load_EmployeeReportingHierarchyItemAccess] 
	@Today datetime2(7)=NULL
AS

SET @Today = ISNULL(@Today,GETDATE())
--SELECT *
--FROM [UPLOAD].[EmployeeReportingHierarchyItemAccess]
/*
--Insert new report user records only
INSERT INTO [ACCESS].[ReportUser] (DomainAccount, IsActive, EmployeeID, CreatedDT)
SELECT Upload.EmployeeCode, 1, E.EmployeeID, @Today
FROM [UPLOAD].[EmployeeReportingHierarchyItemAccess] upload
	INNER JOIN [SOURCELINK].[Employee] E ON E.EmployeeCode = upload.EmployeeCode
WHERE NOT EXISTS (SELECT 1
					FROM [ACCESS].[ReportUser] RU
					WHERE RU.EmployeeID = E.EmployeeID)

*/
/*
INSERT INTO [LOG].[EmployeeReportingHierarchyItemAccessUploadResult]
VALUES (@Today, '[G0V].[Person]', @@RowCount)          --was [access].[reportuser]

--TODO Create insert statement for ReportPosition
INSERT INTO [ACCESS].[PersonAccessControlList] (OrgChartPositionID, CreatedDT)    
SELECT EP.EmployeePositionID, @Today
FROM [UPLOAD].[EmployeeReportingHierarchyItemAccess] upload
	INNER JOIN [SOURCELINK].[Employee] E 
		ON E.EmployeeCode = upload.EmployeeCode
	INNER JOIN [SOURCELINK].[EmployeePosition] EP
		ON EP.EmployeeID = E.EmployeeID
WHERE NOT EXISTS (SELECT 1
					FROM [ACCESS].[PersonAccessControlList] RP
					WHERE RP.EmployeePositionID = EP.EmployeePositionID)
*/
--***************************************************************************
INSERT INTO [ACCESS].[PersonAccessControlList] (OrgChartPositionID, CreatedDT)    
SELECT OCP.OrgChartPositionID, @Today
FROM [UPLOAD].[EmployeeReportingHierarchyItemAccess] upload
	INNER JOIN [GOV].[PersonEmployee] PE 
		ON PE.PersonEmployeeCode = upload.EmployeeCode
	INNER JOIN [GOV].[OrgChartPosition] OCP
		ON OCP.OrgChartPositionID = PE.PersonEmployeeID
WHERE NOT EXISTS (SELECT 1
					FROM [ACCESS].[PersonAccessControlList] PACL
					WHERE PACL.PersonAccessControlListID = OCP.OrgChartPositionID)
--***************************************************************************

INSERT INTO [LOG].[PersonEmployeeReportingHierarchyItemAccessUploadResult]
VALUES (@Today, '[ACCESS].[PersonAccessControlList]', @@RowCount)
/*
--Insert access to items
INSERT INTO [ACCESS].[ReportingHierarchyUserAccess] (ReportingHierarchyItemID, ReportPositionID, IsDefaultHierarchyItem, CreatedDT)
SELECT RHI.ReportingHierarchyItemID, RP.ReportPositionID, 1 AS IsDefaultHierarchyItem, @Today
--INTO #temp
FROM [UPLOAD].[EmployeeReportingHierarchyItemAccess] upload
		INNER JOIN [MASTER].[ReportingHierarchyItem] RHI 
			ON RHI.ItemCode = upload.ReportingHierarchyItemCode
		INNER JOIN [MASTER].[ReportingHierarchyType] RHT
			ON RHT.ReportingHierarchyTypeID = RHI.ReportingHierarchyTypeID
			AND upload.ReportingHierarchyTypeCode = RHT.ReportingHierarchyTypeCode
		INNER JOIN [SOURCELINK].[Employee] E
			ON E.EmployeeCode = upload.EmployeeCode
		INNER JOIN [SOURCELINK].[EmployeePosition] EP
			ON EP.EmployeeID = E.EmployeeID
		INNER JOIN [ACCESS].[PersonAccessControlList] RP
			ON RP.EmployeePositionID = EP.EmployeePositionID
WHERE NOT EXISTS (SELECT 1
					FROM [ACCESS].[ReportingHierarchyUserAccess] RHUA
					WHERE RP.ReportPositionID = RHUA.ReportPositionID
						AND RHI.ReportingHierarchyItemID = RHUA.ReportingHierarchyItemID)
*/


--********************************************************************************************** ws: -WORKS
--Insert access to items
INSERT INTO [ACCESS].[ReportingHierarchyUserAccess] (ReportingHierarchyItemID, PersonAccessControlListID, IsDefaultHierarchyItem, CreatedDT)
SELECT RHI.ReportingHierarchyItemID, PACL.PersonAccessControlListID, 1 AS IsDefaultHierarchyItem, @Today 
--INTO #temp
FROM [UPLOAD].[EmployeeReportingHierarchyItemAccess] upload
		INNER JOIN [MASTER].[ReportingHierarchyItem] RHI 
			ON RHI.ItemCode = upload.ReportingHierarchyItemCode --fine
		INNER JOIN [MASTER].[ReportingHierarchyType] RHT
			ON RHT.ReportingHierarchyTypeID = RHI.ReportingHierarchyTypeID
			AND upload.ReportingHierarchyTypeCode = RHT.ReportingHierarchyTypeCode
		INNER JOIN [GOV].[PersonEmployee] PE
			ON PE.PersonEmployeeCode = upload.EmployeeCode
		INNER JOIN [GOV].[OrgChartPosition] OCP
			ON OCP.OrgChartPositionID = PE.PersonEmployeeID
		INNER JOIN [ACCESS].[PersonAccessControlList] PACL
			ON PACL.PersonAccessControlListID = OCP.OrgChartPositionID
WHERE NOT EXISTS (SELECT 1
					FROM [ACCESS].[ReportingHierarchyUserAccess] RHUA
					WHERE PACL.PersonAccessControlListID = RHUA.PersonAccessControlListID
						AND RHI.ReportingHierarchyItemID = RHUA.ReportingHierarchyItemID)
--**********************************************************************************************


INSERT INTO [LOG].[PersonEmployeeReportingHierarchyItemAccessUploadResult]
VALUES (@Today, '[ACCESS].[ReportingHierarchyUserAccess]', @@RowCount)


--SELECT *
--FROM #temp
--WHERE ReportPositionID = 316
--GROUP BY ReportPositionID
--HAVING COUNT(1) > 1

GO
