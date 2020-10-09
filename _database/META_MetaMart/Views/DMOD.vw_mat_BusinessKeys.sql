SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [DMOD].[vw_mat_BusinessKeys] AS
SELECT  h.HubID AS [Hub ID]
		,h.HubName AS [Hub Name]
		,k.HubBusinessKeyID AS [Hub Business Key ID]
		,k.HubBKFieldID AS [Hub Business Key Field ID]
		,k.FieldSortOrder AS [Field Sort Order]
		,k.BKFriendlyName AS [Business Key Friendly Name]
		--,f.[HubBusinessKeyID]
		,f.[FieldID] AS [Source Field ID]
		,dcf.FieldName AS [Source Field Name]
		,de.DataEntityName AS [Source Data Entity]
		,f.IsBaseEntityField AS [Is Base Entity Field]

  FROM [DMOD].[Hub] h
  JOIN  [DMOD].[HubBusinessKey] k
		ON k.HubID = h.HubID
			AND k.IsActive = 1
  JOIN [DMOD].[HubBusinessKeyField] f
		ON f.HubBusinessKeyID = k.HubBusinessKeyID
			AND f.IsActive = 1
	JOIN [DC].Field dcf
		ON dcf.FieldID = f.FieldID
	JOIN [DC].[DataEntity] de
		ON de.DataEntityID = dcf.DataEntityID

GO
