SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [DMOD].[vw_rpt_validate_HubNameInSatelliteName] AS
SELECT
	h.HubName
	, s.SatelliteName
FROM
	DMOD.Hub h
		INNER JOIN DMOD.Satellite s ON s.HubID = h.HubID
WHERE
	REPLACE(s.SatelliteName, 'SAT_', '') NOT Like '%' + REPLACE(REPLACE(h.HubName, 'HUB_', ''), 'REF_', '')  + '%'

GO
