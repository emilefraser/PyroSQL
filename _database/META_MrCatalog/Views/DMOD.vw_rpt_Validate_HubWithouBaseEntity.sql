SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_rpt_Validate_HubWithouBaseEntity] AS 

SELECT
	nbe.*
FROM
	(
	SELECT
		  h.HubName
		, dcf.SystemName
		, dcf.DataEntityName
	FROM
		DMOD.Hub h
			INNER JOIN DMOD.HubBusinessKey hbk				ON h.HubID = hbk.HubID
			LEFT OUTER JOIN DMOD.HubBusinessKeyField hbkf		ON hbk.HubBusinessKeyID = hbkf.HubBusinessKeyID AND hbkf.IsBaseEntityField = 1
			LEFT OUTER JOIN DC.vw_rpt_DatabaseFieldDetail dcf	ON hbkf.FieldID = dcf.FieldID 
	WHERE
		1=1
		AND dcf.FieldID is NOT null
		AND ISNULL(h.IsActive, 1) = 1
	) be
	FULL OUTER JOIN
	(
	SELECT
		  h.HubName
		, dcf.SystemName
		, dcf.DataEntityName
	FROM
		DMOD.Hub h
			INNER JOIN DMOD.HubBusinessKey hbk				ON h.HubID = hbk.HubID
			LEFT OUTER JOIN DMOD.HubBusinessKeyField hbkf		ON hbk.HubBusinessKeyID = hbkf.HubBusinessKeyID AND hbkf.IsBaseEntityField = 1
			LEFT OUTER JOIN DC.vw_rpt_DatabaseFieldDetail dcf	ON hbkf.FieldID = dcf.FieldID 
	WHERE
		1=1
		AND dcf.FieldID is null
		AND ISNULL(h.IsActive, 1) = 1
	) nbe
	ON be.HubName = nbe.HubName 
WHERE
	be.HubName is null


GO
