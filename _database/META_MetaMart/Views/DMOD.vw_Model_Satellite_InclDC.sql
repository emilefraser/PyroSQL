SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [DMOD].[vw_Model_Satellite_InclDC] AS
SELECT
	s.SatelliteID
,	s.SatelliteName
,	s.SatelliteDataEnityID
,	s.TransactionLinkID
,	s.IsDetailTransactionLinkSat
,	s.IsActive AS IsActive_Satellite
,	sf.SatelliteFieldID
,	sf.FieldID
,	sf.IsActive AS IsActive_SatelliteField
,	sdvt.SatelliteDataVelocityTypeID
,	sdvt.SatelliteDataVelocityTypeCode
,	sdvt.SatelliteDataVelocityTYpeName
,	h.HubID
,	h.HubName
,	h.HubDataEntityID
,	h.EnsembleStatus
,	h.IsActive AS IsActive_Hub
,	f.FieldName
,	f.IsActive AS IsActive_Field
,	de.DataEntityID
,	de.IsActive AS IsActive_DataEntity
,	sc.SchemaID
,	sc.SchemaName
,	sc.IsActive AS IsActive_Schema
,	db.DatabaseID
,	db.DatabaseName
,	db.IsActive AS IsActive_Database
FROM
	DMOD.Satellite AS s
INNER JOIN
	DMOD.SatelliteField AS sf
	ON sf.SatelliteID = s.SatelliteID
INNER JOIN
	DMOD.SatelliteDataVelocityType AS sdvt
	ON sdvt.SatelliteDataVelocityTypeID = s.SatelliteDataVelocityTypeID
INNER JOIN 
	DMOD.Hub AS h
	ON h.HubID = s.HubID
INNER JOIN 
	DC.Field AS f
ON 
	f.FieldID = sf.FieldID
INNER JOIN 
	DC.DataEntity AS de
ON 
	de.DataEntityID = f.DataEntityID
INNER JOIN 
	DC.[Schema] AS sc
ON	
	sc.SchemaID = de.SchemaID
INNER JOIN
	DC.[Database] AS db
ON 
	db.DatabaseID = sc.DatabaseID


GO
