SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [dbo].[vw_dataset_GLFiscalSet]
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
,	fset.[GL FiscalSet Key]
,	acc.[Account Group COD]
,	acc.[Account FMTTD]
,	acc.[Account ID]
,	acc.[Account Name]
,	fset.[Fiscal Year]
,	fset.[Fiscal Period]
,	fset.[Currency Type]
,	fset.[Fiscal Set]
,	fset.[Currency Code]
,	fset.[Transaction Amount]
FROM
	DataManager_2020723.ACCESS.vw_ReportingHierarchyAccess rh
	LEFT JOIN
		vw_pres_DimGlAccount acc
		ON rh.BusinessKey = acc.[Account ID]
		AND	  rh.ReportingHierarchyTypeCode IN ( 'FRHIS' , 'FRHBS')
	LEFT JOIN
		vw_pres_FactGLFiscalSet fset
		ON acc.[GL Account Key] = fset.[GL Account Key]

GO
