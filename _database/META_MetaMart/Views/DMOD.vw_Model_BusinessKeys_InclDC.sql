SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_Model_BusinessKeys_InclDC] AS
SELECT
	h.HubID
,	h.HubName, h.HubDataEntityID
,	h.EnsembleStatus
,	h.IsActive AS IsActive_Hub
,	hbk.HubBusinessKeyID
,	hbk.BKFriendlyName
,	hbk.FieldSortOrder
,	hbk.IsActive AS IsActive_HubBuisnessKey
,	hbkf.HubBusinessKeyFieldID
,	hbkf.IsBaseEntityField
,	hbkf.FieldID AS FieldID_HubBusinessKeyField
,	hbkf.IsActive AS IsActive_HubHubBusinessKeyField
,	f.FieldName
,	f.IsActive AS IsActive_Field
,	de.DataEntityID
,	de.IsActive AS IsActive_DataEntity
,	s.SchemaID
,	s.SchemaName
,	s.IsActive AS IsActive_Schema
,	db.DatabaseID
,	db.DatabaseName
,	db.IsActive AS IsActive_Database
FROM 
	DMOD.Hub AS h
INNER JOIN 
	DMOD.HubBusinessKey AS hbk
	ON hbk.HubID = h.HubID
INNER JOIN 
	DMOD.HubBusinessKeyField AS hbkf
	ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
INNER JOIN 
	DC.Field AS f
ON 
	f.FieldID = hbkf.FieldID
INNER JOIN 
	DC.DataEntity AS de
ON 
	de.DataEntityID = f.DataEntityID
INNER JOIN 
	DC.[Schema] AS s
ON	
	s.SchemaID = de.SchemaID
INNER JOIN
	DC.[Database] AS db
ON 
	db.DatabaseID = s.DatabaseID


GO
