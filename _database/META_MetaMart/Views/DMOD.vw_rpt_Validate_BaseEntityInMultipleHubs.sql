SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [DMOD].[vw_rpt_Validate_BaseEntityInMultipleHubs] AS 
SELECT DISTINCT
		dcf.DataEntityName
		, h.HubName
	FROM
		DMOD.HubBusinessKeyField hbkf
			INNER JOIN DC.vw_rpt_DatabaseFieldDetail dcf	ON hbkf.FieldID = dcf.FieldID
			INNER JOIN DMOD.HubBusinessKey hbk				ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID AND hbk.IsActive = 1
			INNER JOIN DMOD.Hub h							ON hbk.HubID = h.HubID 
	WHERE
		hbkf.IsBaseEntityField = 1
		AND hbkf.IsActive = 1
		AND dcf.DataEntityName IN	(
									SELECT
										DataEntityName
									FROM
										(
										SELECT DISTINCT
											dcf.DataEntityName
											, h.HubName
										FROM
											DMOD.HubBusinessKeyField hbkf
												INNER JOIN DC.vw_rpt_DatabaseFieldDetail dcf	ON hbkf.FieldID = dcf.FieldID
												INNER JOIN DMOD.HubBusinessKey hbk				ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID AND hbk.IsActive = 1
												INNER JOIN DMOD.Hub h							ON hbk.HubID = h.HubID 
										WHERE
											hbkf.IsBaseEntityField = 1
											AND hbkf.IsActive = 1
											AND h.IsActive = 1
										) be
									GROUP BY
										DataEntityName
									HAVING
										COUNT(1) > 1
									)
								AND h.IsActive = 1

GO
