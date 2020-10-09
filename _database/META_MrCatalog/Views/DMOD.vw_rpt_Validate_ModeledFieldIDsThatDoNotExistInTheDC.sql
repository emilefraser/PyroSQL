SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [DMOD].[vw_rpt_Validate_ModeledFieldIDsThatDoNotExistInTheDC]
AS 

SELECT 'HubBusinessKeyFieldID modeled but not in DC' AS [Description]
	   , hbkf.FieldID AS [FieldID]
	   , hbk.BKFriendlyName AS Area
	   , h.HubName
FROM DMOD.HubBusinessKeyField hbkf
	JOIN DMOD.HubBusinessKey hbk	ON hbk.HubBusinessKeyID = hbkf.HubBusinessKeyID
	JOIN DMOD.Hub h					ON h.HubID = hbk.HubID AND ISNULL(h.IsActive, 1) = 1
	LEFT JOIN DC.Field f			ON hbkf.FieldID = f.FieldID AND ISNULL(f.IsActive, 1) = 1
WHERE f.FieldID IS NULL
	AND ISNULL(hbkf.IsActive, 1) = 1

UNION ALL

SELECT 'SatelliteFieldID modeled but not in DC' AS [Description]
	   , hbkf.FieldID AS [FieldID]
	   , sat.SatelliteName
	   , h.HubName
FROM DMOD.SatelliteField hbkf
	JOIN DMOD.Satellite sat	ON sat.SatelliteID = hbkf.SatelliteID
	JOIN DMOD.Hub h			ON h.HubID = sat.HubID AND ISNULL(h.IsActive, 1) = 1
	LEFT JOIN DC.Field f	ON hbkf.FieldID = f.FieldID AND ISNULL(f.IsActive, 1) = 1
WHERE f.FieldID IS NULL
	AND ISNULL(hbkf.IsActive, 1) = 1

UNION ALL

SELECT  'ForeignKeyFieldID modeled but not in DC' AS [Description]
		, hbkf.ForeignKeyFieldID AS [FieldID]
		, pkfk.LinkName 
		, h.HubName
FROM DMOD.PKFKLinkField hbkf
	JOIN DMOD.PKFKLink pkfk	ON pkfk.PKFKLinkID = hbkf.PKFKLinkID
	JOIN DMOD.Hub h			ON h.HubID = pkfk.ChildHubID AND ISNULL(h.IsActive, 1) = 1
	LEFT JOIN DC.Field f	ON hbkf.ForeignKeyFieldID = f.FieldID AND ISNULL(f.IsActive, 1) = 1
WHERE f.FieldID IS NULL
	AND ISNULL(hbkf.IsActive, 1) = 1

UNION ALL

SELECT 'PrimaryKeyFieldID modeled but not in DC' AS [Description]
		, hbkf.PrimaryKeyFieldID AS [FieldID]
		, pkfk.LinkName 
		, h.HubName
FROM DMOD.PKFKLinkField hbkf
	JOIN DMOD.PKFKLink pkfk	ON pkfk.PKFKLinkID = hbkf.PKFKLinkID
	JOIN DMOD.Hub h			ON h.HubID = pkfk.ChildHubID AND ISNULL(h.IsActive, 1) = 1
	LEFT JOIN DC.Field f ON hbkf.PrimaryKeyFieldID = f.FieldID AND ISNULL(f.IsActive, 1) = 1
WHERE f.FieldID IS NULL
	AND ISNULL(hbkf.IsActive, 1) = 1

GO
