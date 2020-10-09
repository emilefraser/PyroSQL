SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_OrphanHubBusinessKeyFields] AS

SELECT
	  bkf.[HubBusinessKeyID]
	, bkf.[FieldID]
	, bkf.[IsBaseEntityField]
	, bkf.IsActive AS HubBusinessKeyField_IsActive
	, bk.HubBusinessKeyID AS HubBusinessKey_HubBusinessKeyID
	, bk.BKFriendlyName AS HubBusinessKey_BKFriendlyName
	, bk.IsActive AS HubBusinessKey_IsActive
	, h.HubID AS Hub_HubID
FROM
	[DMOD].[HubBusinessKeyField] bkf
		LEFT JOIN [DMOD].[HubBusinessKey] bk	ON bk.HubBusinessKeyID = bkf.HubBusinessKeyID
		LEFT JOIN [DMOD].[Hub] h				ON h.HubID = bk.HubID
WHERE
	isnull(bk.HubBusinessKeyID,'') = ''
	OR isnull(h.HubID,'') = ''

GO
