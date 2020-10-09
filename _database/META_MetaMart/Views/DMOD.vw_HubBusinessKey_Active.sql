SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [DMOD].[vw_HubBusinessKey_Active]
AS

SELECT 
	h.HubID, h.HubName
,	hbk.HubBusinessKeyID, hbk.FieldSortOrder AS FieldSortOrder_HubBusinessKey, hbk.BKFriendlyName
,	hbkf.HubBusinessKeyFieldID, hbkf.FieldID AS FieldID_HubBusinessKeyField, hbkf.IsBaseEntityField
,	f.FieldID, f.FieldName
,	de.DataEntityID, de.DataEntityName
FROM
	DMOD.Hub AS h
LEFT JOIN 
	DMOD.HubBusinessKey AS hbk
	ON hbk.HubID = h.HubID
INNER JOIN 
	DMOD.HubBusinessKeyField AS hbkf
	ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
INNER JOIN 
	DC.Field AS f
	ON f.FieldID = hbkf.FieldID
INNER JOIN 
	DC.DataEntity AS de
	On de.DataEntityID = f.DataEntityID
WHERE
	h.IsActive = 1
AND
	hbk.IsActive = 1
AND
	hbkf.IsActive = 1
AND
	f.IsActive = 1
AND
	de.IsActive = 1

GO
