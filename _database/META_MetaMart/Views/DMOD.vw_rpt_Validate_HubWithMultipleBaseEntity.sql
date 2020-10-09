SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_rpt_Validate_HubWithMultipleBaseEntity] AS 

SELECT
	h.HubName
	, hbk.BKFriendlyName
	, dcf.DatabaseName
	, dcf.SchemaName
	, dcf.DataEntityName
	, dcf.FieldName
FROM
	DMOD.Hub h
		INNER JOIN DMOD.HubBusinessKey hbk					ON h.HubID = hbk.HubID
		LEFT OUTER JOIN DMOD.HubBusinessKeyField hbkf		ON hbk.HubBusinessKeyID = hbkf.HubBusinessKeyID AND hbkf.IsBaseEntityField = 1
		LEFT OUTER JOIN DC.vw_rpt_DatabaseFieldDetail dcf	ON hbkf.FieldID = dcf.FieldID
		LEFT OUTER JOIN 
				(
				SELECT
					  sh.HubName
					, sdcf.SystemName
				FROM
					DMOD.Hub sh
						INNER JOIN DMOD.HubBusinessKey shbk					ON sh.HubID = shbk.HubID
						LEFT OUTER JOIN DMOD.HubBusinessKeyField shbkf		ON shbk.HubBusinessKeyID = shbkf.HubBusinessKeyID AND shbkf.IsBaseEntityField = 1
						LEFT OUTER JOIN DC.vw_rpt_DatabaseFieldDetail sdcf	ON shbkf.FieldID = sdcf.FieldID 
				WHERE
					1=1
					AND sdcf.FieldID is NOT null
					AND
						ISNULL(sh.IsActive,0) = 1
					AND
						ISNULL(shbk.IsActive,0) = 1
					AND
						ISNULL(shbkf.IsActive,0) = 1	
				GROUP BY
					sh.HubName
					, sdcf.SystemName
				HAVING
					COUNT(DISTINCT sdcf.DataEntityName) > 1
				
				) DupBE
				ON h.HubName = DupBE.HubName AND dcf.SystemName = DupBE.SystemName
WHERE
	DupBE.HubName is not null
AND
	ISNULL(h.IsActive,0) = 1
AND
	ISNULL(hbk.IsActive,0) = 1
AND
	ISNULL(hbkf.IsActive,0) = 1

GO
