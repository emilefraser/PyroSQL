SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_ModellingStructure] AS
SELECT h.HubID, h.HubName, /* h.HubDataEntityID, h.EnsembleStatus,*/ h.IsActive AS IsActive_Hub
, hbk.HubBusinessKeyID, hbk.BKFriendlyName, hbk.FieldSortOrder, hbk.IsActive AS IsActive_HubBuisnessKey
, hbkf.HubBusinessKeyFieldID, hbkf.IsBaseEntityField, hbkf.FieldID AS FieldID_HubBusinessKeyField, hbkf.IsActive AS IsActive_HubHubBusinessKeyField
, pkfk.PKFKLinkID, pkfk.LinkName, pkfk.ParentHubNameVariation, pkfk.ParentHubID, pkfk.ChildHubID, pkfk.IsActive AS IsActive_PKFKLink
, pkfkf.PKFKLinkFieldID, pkfkf.PrimaryKeyFieldID, pkfkf.ForeignKeyFieldID ,pkfkf.IsActive AS IsActive_PKFKLinkField
, s.SatelliteID, s.SatelliteName, s.IsActive AS IsActive_Satellite
, sf.SatelliteFieldID, sf.FieldID AS FieldID_SatelliteField, sf.IsActive AS IsActive_SatelliteField
, sdvt.SatelliteDataVelocityTypeID, sdvt.SatelliteDataVelocityTypeCode
, sal.SameAsLinkID, sal.SameAsLinkName, sal.IsActive AS IsActive_SameAsLink
, salf.SameAsLinkFieldID, salf.MasterFieldID, salf.SlaveFieldID, salf.IsActive AS IsActive_SameAsLinkField
	FROM 
	DMOD.Hub AS h
INNER JOIN 
	DMOD.HubBusinessKey AS hbk
	ON hbk.HubID = h.HubID
INNER JOIN 
	DMOD.HubBusinessKeyField AS hbkf
	ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
LEFT JOIN 
	DMOD.PKFKLink AS pkfk
	ON pkfk.ChildHubID = h.HubID
LEFT JOIN 
	DMOD.PKFKLinkField AS pkfkf
	ON pkfkf.PKFKLinkID = pkfk.PKFKLinkID
LEFT JOIN 
	DMOD.Satellite AS s
	ON s.HubID = h.HubID
LEFT JOIN 
	DMOD.SatelliteField AS sf
	ON sf.SatelliteID = s.SatelliteID
LEFT JOIN 
	DMOD.SatelliteDataVelocityType AS sdvt
	ON sdvt.SatelliteDataVelocityTypeID = s.SatelliteDataVelocityTypeID
LEFT JOIN 
	DMOD.SameAsLink AS sal
	ON sal.HubID = h.HubID
LEFT JOIN 
	DMOD.SameAsLinkField AS salf
	ON salf.SameAsLinkID = sal.SameAsLinkID

	/*
	SELECT * FROM DMOD.vw_ModellingStructure
	WHERE HubID = 16

	SELECT * FROM DMOD.HUB

	*/

GO
