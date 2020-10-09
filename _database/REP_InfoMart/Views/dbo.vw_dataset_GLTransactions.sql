SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [dbo].[vw_dataset_GLTransactions]
AS

SELECT 
	rh.ReportingHierarchyItemID
,	rh.ReportingHierarchyItemCode
,	rh.ReportingHierarchyItemName
,	rh.[BusinessKey]
,	rh.[DataCatalogFieldID]
,	rh.[FieldName]
,	rh.[IsDefaultHierarchyItem]
,	rh.[L1]
,	rh.[L2]
,	rh.[L3]
,	rh.[L4]
,	rh.[L5]
,	rh.[L6]
,	rh.[L7]
,	rh.[L8]
,	rh.[L9]
,	rh.[L10]
,	rh.[L1SortOrder]
,	rh.[L2SortOrder]
,	rh.[L3SortOrder]
,	rh.[L4SortOrder]
,	rh.[L5SortOrder]
,	rh.[L6SortOrder]
,	rh.[L7SortOrder]
,	rh.[L8SortOrder]
,	rh.[L9SortOrder]
,	rh.[L10SortOrder]
,	acc.[GL Account Key]
,	trans.[GL Transaction Key]
,	acc.[Account Group COD]
,	acc.[Account FMTTD]
,	acc.[Account ID]
,	acc.[Account Name]
,	trans.[Fiscal Year]
,	trans.[Fiscal Period]
,	trans.[Source Currency]
,	trans.[Source Ledger Code]
,	trans.[Source Type Code]
,	trans.[Detail Count]
,	trans.[Journal Date]
,	trans.[Detail Description]
,	trans.[Detail Reference]
,	trans.[Transaction Amount]
,	trans.[Transaction Quantity]
,	trans.[Source Currency Amount]
,	trans.[Source Currency Code]
,	trans.[Document Date]
FROM
	DataManager_2020723.ACCESS.vw_ReportingHierarchyAccess rh
	LEFT JOIN
		vw_pres_DimGlAccount acc
		ON rh.BusinessKey = acc.[Account ID]
		AND	 rh.ReportingHierarchyTypeName IN ( 'FRHIS' , 'FRHBS')
	LEFT JOIN
		vw_pres_FactGLTransactions trans
		ON acc.[GL Account Key] = trans.[GL Account Key]

GO
