SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [DMOD].[vw_rpt_Validate_HubsWithNoSateliteOrSateliteFromDifferentEntity] AS

SELECT
	  hub.HubID
	, h.HubName
	, sat.SatelliteName 
FROM
	(
	SELECT DISTINCT
		  h.HubID
		, f.DataEntityID 
	FROM
		DMOD.Hub h
			INNER JOIN DMOD.HubBusinessKey hbk			ON h.HubID = hbk.HubID
			INNER JOIN DMOD.HubBusinessKeyField hbkf	ON hbk.HubBusinessKeyID = hbkf.HubBusinessKeyID
			INNER JOIN DC.Field f						ON hbkf.FieldID = f.FieldID
		WHERE h.IsActive = 1 and hbkf.IsActive = 1
	) hub
	FULL OUTER JOIN
	(
	SELECT DISTINCT
		  sat.HubID
		, sat.SatelliteName 
		, f.DataEntityID 
	FROM
		DMOD.Satellite sat
			INNER JOIN DMOD.SatelliteField sf	ON sat.SatelliteID = sf.SatelliteID 
			INNER JOIN DC.Field f						ON sf.FieldID = f.FieldID
	WHERE sat.IsActive = 1 and sf.IsActive = 1
	) sat
		ON hub.HubID = sat.HubID 
		AND hub.DataEntityID = sat.DataEntityID 
	INNER JOIN DMOD.Hub AS h	ON hub.HubID = h.HubID 
WHERE
	hub.HubID Is Null
	OR sat.HubID Is Null

GO
