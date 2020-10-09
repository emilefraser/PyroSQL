SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [DMOD].[vw_rpt_ModeledFields] AS

--Hub Business Keys
SELECT
	  h.HubName
	, 'HubBusinessKey' AS FieldUse
	, dcde.DataEntityID
	, dcde.DataEntityName
	, dcf.FieldID
	, dcf.FieldName
FROM
	DMOD.Hub h
		INNER JOIN DMOD.HubBusinessKey hbk			ON h.HubID = hbk.HubID AND hbk.IsActive = 1
		INNER JOIN DMOD.HubBusinessKeyField hbkf	ON hbk.HubBusinessKeyID = hbkf.HubBusinessKeyID AND hbkf.IsActive = 1
		INNER JOIN DC.Field dcf						ON hbkf.FieldID = dcf.FieldID
		INNER JOIN DC.DataEntity dcde				ON dcf.DataEntityID = dcde.DataEntityID
WHERE h.IsActive = 1

UNION ALL

--PKFK Link Primary Keys
SELECT
	  h.HubName
	, 'PKFKLinkPrimaryKey' AS FieldUse
	, dcde.DataEntityID
	, dcde.DataEntityName
	, dcf.FieldID
	, dcf.FieldName
FROM
	DMOD.Hub h
		INNER JOIN DMOD.PKFKLink pkfkl				ON h.HubID = pkfkl.ChildHubID AND pkfkl.IsActive = 1
		INNER JOIN DMOD.PKFKLinkField pkfklf		ON pkfkl.PKFKLinkID = pkfklf.PKFKLinkID AND pkfklf.IsActive = 1
		INNER JOIN DC.Field dcf						ON pkfklf.PrimaryKeyFieldID = dcf.FieldID
		INNER JOIN DC.DataEntity dcde				ON dcf.DataEntityID = dcde.DataEntityID 
WHERE H.IsActive = 1 AND pkfkl.IsActive = 1

UNION ALL

--PKFK Link Foreign Keys
SELECT
	  h.HubName
	, 'PKFKLinkForeignKey' AS FieldUse
	, dcde.DataEntityID
	, dcde.DataEntityName
	, dcf.FieldID
	, dcf.FieldName
FROM
	DMOD.Hub h
		INNER JOIN DMOD.PKFKLink pkfkl				ON h.HubID = pkfkl.ChildHubID AND pkfkl.IsActive = 1
		INNER JOIN DMOD.PKFKLinkField pkfklf		ON pkfkl.PKFKLinkID = pkfklf.PKFKLinkID AND pkfklf.IsActive = 1
		INNER JOIN DC.Field dcf						ON pkfklf.ForeignKeyFieldID = dcf.FieldID
		INNER JOIN DC.DataEntity dcde				ON dcf.DataEntityID = dcde.DataEntityID 
WHERE H.IsActive = 1 AND pkfkl.IsActive = 1

UNION ALL

--Satellite Fields
SELECT
	  h.HubName
	, 'SatelliteField' AS FieldUse
	, dcde.DataEntityID
	, dcde.DataEntityName
	, dcf.FieldID
	, dcf.FieldName
FROM
	DMOD.Hub h
		INNER JOIN DMOD.Satellite sat				ON h.HubID = sat.HubID AND sat.IsActive = 1
		INNER JOIN DMOD.SatelliteField satf			ON sat.SatelliteID = satf.SatelliteID AND satf.IsActive = 1
		INNER JOIN DC.Field dcf						ON satf.FieldID = dcf.FieldID
		INNER JOIN DC.DataEntity dcde				ON dcf.DataEntityID = dcde.DataEntityID 
WHERE h.IsActive = 1 AND sat.IsActive = 1

GO
