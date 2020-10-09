SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_mat_LoadType]
AS
SELECT lt.[LoadTypeID]
      ,lt.[LoadTypeCode]
      ,lt.[LoadTypeName]
      ,lt.[LoadTypeDescription]
      ,lt.[ParameterisedTemplateScript]
      ,lt.[StaticTemplateScript]
      ,lt.[LoadScriptVersionNo]
      ,lt.[DatabasePurposeID]
	  ,dp.[DatabasePurposeCode]
	  ,dp.[DatabasePurposeName]
      ,lt.[ETLLoadTypeID]
	  ,gd.DetailTypeCode AS ETLLoadTypeCode
	  ,gd.DetailTypeDescription AS ETLLoadTypeName
      ,lt.[DataEntityTypeID]
	  ,det.[DataEntityTypeCode]
	  ,det.[DataEntityTypeName]
      ,lt.[IsValidated]
      ,lt.[IsExternalTable]
      ,lt.[IsCreatedDTRequired]
      ,lt.[IsUpdatedDTRequired]
      ,lt.[CreatedBy]
      ,lt.[ModifiedBy]
      ,lt.[CreatedDT]
      ,lt.[ModifiedDT]
      ,lt.[IsActive]
  FROM [DMOD].[LoadType] AS lt
  INNER JOIN DC.[DatabasePurpose] AS dp
  ON dp.DatabasePurposeID = lt.DatabasePurposeID
  INNER JOIN [Type].[Generic_Detail] AS gd
  ON gd.[DetailID] = lt.ETLLoadTypeID 
  INNER JOIN [DC].[DataEntityType] AS det
  ON det.DataEntityTypeID = lt.DataEntityTypeID
  WHERE dp.DatabasePurposeCode IN ('StageArea', 'DataVault')
  AND lt.IsActive = 1

GO
