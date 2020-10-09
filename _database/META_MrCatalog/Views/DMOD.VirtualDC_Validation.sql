SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [DMOD].[VirtualDC_Validation] AS


SELECT 'Missing DC Table' AS [Description],dmde.DataEntityName AS DataEntity ,dcde.DataEntityName AS Field FROM DMOD.DataEntity_VirtualDC dmde
LEFT JOIN DC.DataEntity dcde 
ON DMDE.DataEntityName = dcde.DataEntityName
WHERE dcde.DataEntityName is null
Union ALL
SELECT 'Missing Field in DC Table', de.DataEntityName, dmde.fieldname FROM DMOD.Field_VirtualDC dmde
LEFT JOIN DC.Field dcde 
ON DMDE.FieldName = dcde.FieldName
LEFT JOIN DC.DataEntity DE
on de.DataEntityID = dmde.dataentityid
WHERE dcde.FieldName IS NULL


GO
