SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].[vw_rpt_Validate_BusinessKeyIsDateDataType] AS
SELECT	h.HubID,h.HubName, f.FieldName, f.DataType
FROM	DMOD.HubBusinessKeyField bkf
	INNER JOIN	DC.Field f on bkf.FieldID = f.FieldID
	INNER JOIN	DMOD.HubBusinessKey bk ON bkf.HubBusinessKeyID = bk.HubBusinessKeyID
	INNER JOIN	DMOD.Hub h ON bk.HubID = h.HubID
WHERE H.IsActive = 1 
	AND f.DataType  LIKE '%date%'

GO
