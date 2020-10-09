SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_HubBusinessKey]
AS

SELECT 
	h.HubID, h.HubName, h.IsActive AS IsAtive_Hub
,	hbk.HubBusinessKeyID, hbk.FieldSortOrder AS FieldSortOrder_HubBusinessKey, hbk.BKFriendlyName, hbk.IsActive AS IsActive_HubBusinessKey
,	hbkf.HubBusinessKeyFieldID, hbkf.FieldID AS FieldID_HubBusinessKeyField, hbkf.IsBaseEntityField, hbkf.IsActive AS IsActive_HubBusinessKeyField
FROM
	DMOD.Hub AS h
LEFT JOIN 
	DMOD.HubBusinessKey AS hbk
	ON hbk.HubID = h.HubID
INNER JOIN 
	DMOD.HubBusinessKeyField AS hbkf
	ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID

GO
