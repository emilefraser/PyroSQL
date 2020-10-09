SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_mat_BusinessKeySourceFields]
AS

SELECT HBKF.HubBusinessKeyID, HBKF.IsBaseEntityField, HBKF.IsActive, HBKF.FieldID, DB.FieldName, DB.DataEntityName,
DB.DatabaseName, DB.SchemaName, DB.SystemName, DB.ServerName 

FROM DMOD.HubBusinessKeyField AS HBKF
LEFT JOIN [DC].[vw_rpt_DatabaseFieldDetail] AS DB
ON HBKF.FieldID = DB.FieldID


GO
