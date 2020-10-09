SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_rpt_Validate_HubEntitiesIsActiveNotNull] AS

SELECT
	  h.HubID
	, h.HubName
	, h.IsActive 
FROM
	DMOD.Hub h
		LEFT JOIN	DMOD.HubBusinessKey hbk			ON h.HubID = hbk.HubID
		LEFT JOIN	DMOD.HubBusinessKeyField hbkf	ON hbk.HubBusinessKeyID = hbkf.HubBusinessKeyID 
WHERE
	h.IsActive Is Null
	OR (hbk.HubBusinessKeyID Is Not Null AND hbk.IsActive Is Null)
	OR (hbkf.HubBusinessKeyID Is Not Null AND hbkf.IsActive Is Null)

GO
