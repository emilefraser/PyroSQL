SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON





-- Validate if all Satellite fields are base entity fields

CREATE VIEW [DMOD].[vw_rpt_Validate_SatelliteFieldsfromDifferentSystems] AS

SELECT TOP 10
	h.HubID
	, h.HubName
	, s.SatelliteID
	, s.SatelliteName
FROM
	[DMOD].Hub h
		INNER JOIN [DMOD].Satellite s					ON s.HubID = h.HubID
WHERE
	s.IsActive = 1
	AND s.SatelliteID IN (
						SELECT
							SatelliteID
						FROM
							(
							SELECT DISTINCT
								f.SatelliteID 
								, fd.SystemID
							FROM
								[DMOD].SatelliteField f
									INNER JOIN [DC].vw_rpt_DatabaseFieldDetail fd	ON fd.[FieldID] = f.FieldID
							WHERE
								f.IsActive = 1
							) ss
						GROUP BY
							SatelliteID
						HAVING
							COUNT(*) > 1)


GO
