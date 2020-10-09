SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DMOD].[vw_OrphanSatelliteFields] AS
SELECT  sf.*
		,s.SatelliteID AS Satellite_SatelliteID
		,s.SatelliteName AS Satellite_SatelliteName
		,h.HubID AS Hub_HubID
  FROM [DMOD].[SatelliteField] sf
  LEFT JOIN [DMOD].[Satellite] s
		ON s.SatelliteID = sf.SatelliteID
  LEFT JOIN [DMOD].[Hub] h
		ON h.HubID = s.HubID

WHERE	isnull(s.SatelliteID,'')=''
	OR isnull(h.HubID,'')=''

GO
