SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [DMOD].[vw_mat_HubBusinessKeySourceFields] AS
SELECT  h.HubID AS [Hub ID]
		,h.HubName AS [Hub Name]
		,h.HubDataEntityID AS [Hub Data Entity ID]
		,k.HubBusinessKeyID AS [Hub Business Key ID]
		,k.HubBKFieldID AS [Hub Business Key Field ID]
		,k.FieldSortOrder AS [Field Sort Order]
		,k.BKFriendlyName AS [Business Key Friendly Name]
		,k.IsActive
		,f.[HubBusinessKeyID]
		,f.[FieldID] AS [Source Field ID]
		,f.IsBaseEntityField AS [Is Base Entity Field]
		,dc.FieldName AS [Source Field Name]
		,dc.DataEntityName AS [Source Data Entity Name]
		,dc.DatabaseName AS [Database Name]
		,dc.SchemaName AS [Schema Name]
		,dc.SystemName AS [System Name]
		,dc.ServerName AS [Server Name]

  FROM [DMOD].[Hub] h
	LEFT JOIN  [DMOD].[HubBusinessKey] k
		ON k.HubID = h.HubID
	LEFT JOIN [DMOD].[HubBusinessKeyField] f
		ON f.HubBusinessKeyID = k.HubBusinessKeyID 
	LEFT JOIN DC.vw_rpt_DatabaseFieldDetail dc
		ON dc.FieldID = f.FieldID

GO
