SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_Model_BusinessKeys] AS
SELECT
	h.HubID
,	h.HubName, h.HubDataEntityID
,	h.EnsembleStatus
,	h.IsActive AS IsActive_Hub
,	hbk.HubBusinessKeyID
,	hbk.BKFriendlyName
,	hbk.FieldSortOrder
,	hbk.IsActive AS IsActive_HubBuisnessKey
,	hbkf.HubBusinessKeyFieldID
,	hbkf.IsBaseEntityField
,	hbkf.FieldID AS FieldID_HubBusinessKeyField
,	hbkf.IsActive AS IsActive_HubHubBusinessKeyField
FROM 
	DMOD.Hub AS h
INNER JOIN 
	DMOD.HubBusinessKey AS hbk
	ON hbk.HubID = h.HubID
INNER JOIN 
	DMOD.HubBusinessKeyField AS hbkf
	ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID


GO
