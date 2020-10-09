SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON












CREATE VIEW [ACCESS].[vw_ReportingHierarchyAccess] AS

/*
SELECT DISTINCT '' AS HashKey
 , RHUALev.CompanyID as CompanyID
 , RHT.ReportingHierarchyTypeID, RHT.ReportingHierarchyTypeCode, RHT.ReportingHierarchyTypeName
 , RHI.ReportingHierarchyItemID, RHI.ItemCode AS ReportingHierarchyItemCode, RHI.ItemName AS ReportingHierarchyItemName
 , RHIP.ReportingHierarchyItemID AS ParentReportingHierarchyItemID, RHIP.ItemCode AS ParentReportingHierarchyItemCode, RHIP.ItemName as ParentReportingHierarchyItemName
 , LBKC.BusinessKey
 , LBKC.DataCatalogFieldID, F.FieldName
 , RHUALev.IsDefaultHierarchyItem ,RU.DomainAccount
 , IsFullAccessUser



 , RHUALev.L1
 , RHUALev.L2
 , RHUALev.L3
 , RHUALev.L4
 , RHUALev.L5
 , RHUALev.L6
 , RHUALev.L7
 , RHUALev.L8
 , RHUALev.L9
 , RHUALev.L10
 ,[L1SortOrder]
        ,[L2SortOrder]
        ,[L3SortOrder]
        ,[L4SortOrder]
        ,[L5SortOrder]
        ,[L6SortOrder]
        ,[L7SortOrder]
        ,[L8SortOrder]
        ,[L9SortOrder]
        ,[L10SortOrder]
 

--SELECT *
FROM [ACCESS].[vw_ReportingHierarchyUserAccessWithLevels] RHUALev
LEFT JOIN [MASTER].[ReportingHierarchyType] RHT ON RHT.ReportingHierarchyTypeID = RHUALev.ReportingHierarchyTypeID
LEFT JOIN [MASTER].[ReportingHierarchyItem] RHI on RHI.ReportingHierarchyItemID = RHUALev.ReportingHierarchyItemID
LEFT JOIN [MASTER].[ReportingHierarchyItem] RHIP ON RHI.ParentItemID = RHIP.ReportingHierarchyItemID
LEFT JOIN [MASTER].[LinkReportingHierarchyItemToBKCombination] LRHI ON RHUALev.ReportingHierarchyItemID = LRHI.ReportingHierarchyItemID
--ORDER BY RHUALev.ReportingHierarchyItemID, RHUALev.ReportUserID
LEFT JOIN [MASTER].[LinkBKCombination] LBKC ON LRHI.LinkID = LBKC.LinkID
LEFT JOIN [DC].[Field] F ON LBKC.DataCatalogFieldID = F.FieldID

LEFT JOIN [ACCESS].[ReportUser] RU ON RU.ReportUserID = RHUALev.ReportUserID
LEFT JOIN [SOURCELINK].[Employee] E ON E.EmployeeID = RU.EmployeeID
LEFT JOIN [SOURCELINK].[EmployeePosition] EP ON EP.EmployeeID = RU.EmployeeID
LEFT JOIN [ACCESS].[ReportPosition] RP ON RP.EmployeePositionID = EP.EmployeePositionID

LEFT JOIN [ACCESS].[ReportingHierarchyUserAccess] RHUA on RHUA.ReportingHierarchyItemID = RHUALev.ReportingHierarchyItemID
 AND RHUA.ReportPositionID = RP.ReportPositionID
-- where RU.DomainAccount = 'tharisa\pliebenberg'
-- ORDER BY RU.DomainAccount,RHI.ReportingHierarchyItemID,  LBKC.BusinessKey
----where RHI.ItemCode = 'CHAL'
--where RU.DomainAccount <> 'tharisa\fgermishuizen'

 

--WHERE DomainAccount = 'THARISA\mmathebula'
--WHERE RHT.ReportingHierarchyTypeCode = 'PRODREP'
--WHERE RHI.ItemName = 'Voyager'
*/

SELECT DISTINCT '' AS HashKey
 , RHUALev.CompanyID as CompanyID
 , RHT.ReportingHierarchyTypeID, RHT.ReportingHierarchyTypeCode, RHT.ReportingHierarchyTypeName
 , RHI.ReportingHierarchyItemID, RHI.ItemCode AS ReportingHierarchyItemCode, RHI.ItemName AS ReportingHierarchyItemName
 , RHIP.ReportingHierarchyItemID AS ParentReportingHierarchyItemID, RHIP.ItemCode AS ParentReportingHierarchyItemCode, RHIP.ItemName as ParentReportingHierarchyItemName
 , LBKC.BusinessKey
 , LBKC.DataCatalogFieldID, F.FieldName
 , RHUALev.IsDefaultHierarchyItem ,P.DomainAccountName
 , P.FirstName
 , P.Surname
 , P.Email
 , IsFullAccessUser



 , RHUALev.L1
 , RHUALev.L2
 , RHUALev.L3
 , RHUALev.L4
 , RHUALev.L5
 , RHUALev.L6
 , RHUALev.L7
 , RHUALev.L8
 , RHUALev.L9
 , RHUALev.L10
 ,[L1SortOrder]
        ,[L2SortOrder]
        ,[L3SortOrder]
        ,[L4SortOrder]
        ,[L5SortOrder]
        ,[L6SortOrder]
        ,[L7SortOrder]
        ,[L8SortOrder]
        ,[L9SortOrder]
        ,[L10SortOrder]
 

--SELECT *
FROM [ACCESS].[vw_ReportingHierarchyUserAccessWithLevels] RHUALev
LEFT JOIN [MASTER].[ReportingHierarchyType] RHT ON RHT.ReportingHierarchyTypeID = RHUALev.ReportingHierarchyTypeID
LEFT JOIN [MASTER].[ReportingHierarchyItem] RHI on RHI.ReportingHierarchyItemID = RHUALev.ReportingHierarchyItemID
LEFT JOIN [MASTER].[ReportingHierarchyItem] RHIP ON RHI.ParentItemID = RHIP.ReportingHierarchyItemID
LEFT JOIN [MASTER].[LinkReportingHierarchyItemToBKCombination] LRHI ON RHUALev.ReportingHierarchyItemID = LRHI.ReportingHierarchyItemID
--ORDER BY RHUALev.ReportingHierarchyItemID, RHUALev.ReportUserID
LEFT JOIN [MASTER].[LinkBKCombination] LBKC ON LRHI.LinkID = LBKC.LinkID
LEFT JOIN [DC].[Field] F ON LBKC.DataCatalogFieldID = F.FieldID

LEFT JOIN [GOV].[Person] P ON P.PersonID = RHUALev.PersonID --done
LEFT JOIN [GOV].[PersonEmployee] PE ON PE.PersonID = P.PersonID --done
LEFT JOIN [GOV].[OrgChartPosition] OCP ON OCP.PersonEmployeeID = PE.PersonEmployeeID/**issue***/      -- linkorgchartpos on personemp :: org chart position is linked to the PERSONEMPLOYEE id?
LEFT JOIN [ACCESS].[PersonAccessControlList] PACL ON PACL.OrgChartPositionID = OCP.OrgChartPositionID

LEFT JOIN [ACCESS].[ReportingHierarchyUserAccess] RHUA on RHUA.ReportingHierarchyItemID = RHUALev.ReportingHierarchyItemID
 AND RHUA.PersonAccessControlListID = PACL.PersonAccessControlListID

 WHERE RHUA.IsActive = '1' AND LBKC.IsActive = '1'

-- where RU.DomainAccount = 'tharisa\pliebenberg'
-- ORDER BY RU.DomainAccount,RHI.ReportingHierarchyItemID,  LBKC.BusinessKey
----where RHI.ItemCode = 'CHAL'
--where RU.DomainAccount <> 'tharisa\fgermishuizen'

 

--WHERE DomainAccount = 'THARISA\mmathebula'
--WHERE RHT.ReportingHierarchyTypeCode = 'PRODREP'
--WHERE RHI.ItemName = 'Voyager'

GO
