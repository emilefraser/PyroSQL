SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE VIEW [DMOD].[vw_mat_BaseEntityFields] AS
SELECT   BaseEntity.HubID AS [Hub ID]
		,HubName AS [Hub Name]
		,BaseEntity.DataEntityID AS [Entity ID]
		,DBColumnID AS [Sort Order]
		,dc.FieldID AS [Field ID]
		,dc.FieldName AS [Field Name]
		,dc.DataType AS [Data Type]
		,dc.IsPrimaryKey AS [Is PK]
		,dc.IsForeignKey AS [Is FK]
		,IsNull(IsUsed,0) AS IsUsed
		,dc.DataEntityName AS [Data Entity Name]
		,dc.DatabaseName AS [Database Name]
		,dc.SchemaName AS [Schema Name]
		,dc.SystemName AS [System Name]
		,dc.ServerName AS [Server Name]
		,SUM(IsNull(IsBK,0)) AS IsBK
		,SUM(IsNull(IsLink,0)) AS IsLink
		,SUM(IsNull(IsSat,0)) AS IsSat
 FROM
 -- Select 'base' fields
(SELECT DISTINCT DataEntityID, HubName, hub.HubID
	FROM [DMOD].[Hub] hub
	JOIN  [DMOD].[HubBusinessKey] bk
		ON bk.HubID = hub.HubID
			AND bk.IsActive = 1
	JOIN [DMOD].[HubBusinessKeyField] bkf
		ON bkf.HubBusinessKeyID = bk.HubBusinessKeyID 
			AND bkf.IsBaseEntityField = 1
			AND bkf.IsActive = 1
	JOIN DC.vw_rpt_DatabaseFieldDetail dc
		ON dc.FieldID = bkf.FieldID) BaseEntity
	JOIN DC.vw_rpt_DatabaseFieldDetail dc
		ON dc.DataEntityID = BaseEntity.DataEntityID
 
-- Join to used fields
	 LEFT JOIN 
		--Business Keys
	   (SELECT bk.HubID AS HubID, FieldID AS UsedFieldID, 
					1 AS IsUsed, 
					1 AS IsBK, 0 AS IsLink, 0 AS IsSat--, 'BK' AS UsedAs
		FROM  [DMOD].[HubBusinessKey] bk
		JOIN [DMOD].[HubBusinessKeyField] bkf
			ON bkf.HubBusinessKeyID = bk.HubBusinessKeyID
				AND bkf.IsActive = 1
		UNION
		--Links
		SELECT l.ChildHubID AS HubID, ForeignKeyFieldID AS UsedFieldID, 
					1 AS IsUsed, 
					0 AS IsBK, 1 AS IsLink, 0 AS IsSat--, 'LINK' AS UsedAs
			FROM  [DMOD].[PKFKLink] l
			JOIN [DMOD].[PKFKLinkField] lf
				ON lf.PKFKLinkID = l.PKFKLinkID
				AND lf.IsActive = 1
		UNION
		-- Satellites
		SELECT s.HubID AS HubID, sf.FieldID AS UsedFieldID, 
					1 AS IsUsed, 
					0 AS IsBK, 0 AS IsLink, 1 AS IsSat--, 'SAT' AS UsedAs
			FROM  [DMOD].[Satellite] s
			JOIN [DMOD].[SatelliteField] sf
				ON sf.SatelliteID = s.SatelliteID
				AND sf.IsActive = 1
				 
		UNION
		--HLinks
		SELECT HubID AS HubID, PKFieldID AS UsedFieldID, 
					1 AS IsUsed, 
					0 AS IsBK, 1 AS IsLink, 0 AS IsSat--, 'HLINK' AS UsedAs
			FROM [DMOD].[HierarchicalLink]
		UNION
		SELECT HubID AS HubID, ParentFieldID AS UsedFieldID, 
					1 AS IsUsed, 
					0 AS IsBK, 1 AS IsLink, 0 AS IsSat--, 'HLINK' AS UsedAs
			FROM [DMOD].[HierarchicalLink])  AS UsedFields
		ON UsedFields.UsedFieldID = dc.FieldID 
		--Newly added:
			AND UsedFields.HubID = BaseEntity.HubID
		GROUP BY
			BaseEntity.HubID  
			,HubName  
			,BaseEntity.DataEntityID  
			,DBColumnID  
			,dc.FieldID  
			,dc.FieldName  
			,dc.IsPrimaryKey  
			,dc.IsForeignKey 
			,IsNull(IsUsed,0)  
			,dc.DataEntityName  
			,dc.DatabaseName  
			,dc.SchemaName 
			,dc.SystemName  
			,dc.ServerName  
			,dc.DataType
		--where HubName = 'HUB_Employee' and [DataEntityName] = 'EMPLOYEE'
		--ORDER BY [Data Entity Name],[Sort Order] 
	

GO
