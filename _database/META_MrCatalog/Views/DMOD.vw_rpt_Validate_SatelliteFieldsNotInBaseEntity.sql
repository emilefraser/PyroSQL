SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- Validate if all Satellite fields are base entity fields

CREATE VIEW [DMOD].[vw_rpt_Validate_SatelliteFieldsNotInBaseEntity] AS
SELECT	h.HubID
		,h.HubName
		,s.SatelliteID
		,s.SatelliteName
		,f.FieldID
		,fd.FieldName
		,fd.DataEntityName
		,fd.SchemaName
		,fd.DatabaseID
		,fd.DataBaseName
 
	FROM [DMOD].Hub h
	JOIN [DMOD].Satellite s
		ON s.HubID = h.HubID
	JOIN [DMOD].SatelliteField f
		ON f.SatelliteID = s.SatelliteID
	JOIN [DC].vw_rpt_DatabaseFieldDetail fd
		ON fd.[FieldID] = f.FieldID
	WHERE f.FieldID NOT IN
		(SELECT [Field ID] 
			FROM [DMOD].[vw_mat_BaseEntityFields] b
			WHERE b.[Hub ID] = s.HubID)
		AND F.IsActive = 1

 


 



GO
