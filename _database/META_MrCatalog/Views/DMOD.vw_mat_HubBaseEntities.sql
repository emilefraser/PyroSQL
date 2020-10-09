SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON










/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [DMOD].[vw_mat_HubBaseEntities] AS
SELECT  HubID AS [Hub ID]
		,HubName AS [Hub Name]
		,BaseEntity.DataEntityID AS [Entity ID]
		,BaseEntity.IsBaseEntityField AS [Is Base]
		,dc.DataEntityName AS [Data Entity Name]
		,dc.DatabaseName AS [Database Name]
		,dc.SchemaName AS [Schema Name]
		,dc.SystemName AS [System Name]
		,dc.ServerName AS [Server Name]

 FROM
 -- Get list of 'base' fields
(SELECT DISTINCT DataEntityID, HubName, hub.HubID, bkf.IsBaseEntityField
	FROM [DMOD].[Hub] hub
	LEFT JOIN  [DMOD].[HubBusinessKey] bk
		ON bk.HubID = hub.HubID
			AND bk.IsActive = 1
			AND hub.IsActive = 1
	JOIN [DMOD].[HubBusinessKeyField] bkf
		ON bkf.HubBusinessKeyID = bk.HubBusinessKeyID 
			AND bkf.IsBaseEntityField = 1
			AND bkf.IsActive = 1
	LEFT JOIN DC.vw_rpt_DatabaseFieldDetail dc
		ON dc.FieldID = bkf.FieldID) BaseEntity

	LEFT JOIN (SELECT DISTINCT DataEntityID, DataEntityName, DatabaseName, 
						   SchemaName, ServerName, SystemName
			 FROM DC.vw_rpt_DatabaseFieldDetail) dc
		ON  dc.DataEntityID = BaseEntity.DataEntityID
 -- ORDER BY BaseEntity.HubID


GO
