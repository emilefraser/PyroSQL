SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [DMOD].[vw_Model_Satellite] AS
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
--,	sdvt.IsActive AS IsActive_SatelliteDataVeloctiy
,	h.HubID
,	h.HubName
,	h.HubDataEntityID
,	h.EnsembleStatus
,	h.IsActive AS IsActive_Hub

--SELECT *
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



GO
