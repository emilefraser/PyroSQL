SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_rpt_Validate_DataEntitiesNotFullyModeled] AS

SELECT
	dcf.DatabaseName
	, dcf.SchemaName 
	, dcf.DataEntityName
	, dcf.FieldName
	, mf.HubName
	, mf.FieldUse
FROM
	DC.vw_rpt_DatabaseFieldDetail dcf
		LEFT OUTER JOIN DMOD.vw_rpt_ModeledFields mf	ON dcf.FieldID = mf.FieldID
WHERE
	dcf.DataEntityID IN	(
						SELECT DISTINCT
							dc.DataEntityID
						FROM
							DC.vw_rpt_DatabaseFieldDetail dc
								LEFT OUTER JOIN DMOD.vw_rpt_ModeledFields mfv	ON dc.FieldID = mfv.FieldID
						WHERE
							dc.DataEntityID IN	(
												SELECT DISTINCT
													DataEntityID
												FROM
													DMOD.vw_rpt_ModeledFields
												)
							AND mfv.HubName is null
						)


GO
