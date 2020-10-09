SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DMOD].[vw_OrphanHubBusinessKeys] AS
SELECT  bk.*
	   ,h.HubID AS Hub_HubID
	FROM  [DMOD].[HubBusinessKey] bk
	LEFT JOIN [DMOD].[Hub] h
		ON h.HubID = bk.HubID
	WHERE isnull(h.HubID,'')=''


/*
--SELECT * 
DELETE
FROM [DMOD].[HubBusinessKey] WHERE HubBusinessKeyID IN (28,29)
*/


GO
