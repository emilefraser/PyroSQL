SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_rpt_Validate_PKFKLinkEntitiesIsActiveNotNull] AS

SELECT
	  l.PKFKLinkID 
	, l.LinkName
	, l.IsActive AS LinkIsActive
	, pf.FieldName AS PrimaryKeyField
	, ff.FieldName AS ForeignKeyField
	, lf.IsActive AS LinkFieldIsActive
FROM
	DMOD.PKFKLink l
		LEFT JOIN DMOD.PKFKLinkField lf	ON l.PKFKLinkID = lf.PKFKLinkID
		LEFT JOIN DC.Field pf			ON lf.PrimaryKeyFieldID = pf.FieldID 
		LEFT JOIN DC.Field ff			ON lf.ForeignKeyFieldID = ff.FieldID 
WHERE
	l.IsActive Is Null
	OR (lf.PKFKLinkID Is Not Null AND lf.IsActive Is Null)

GO
