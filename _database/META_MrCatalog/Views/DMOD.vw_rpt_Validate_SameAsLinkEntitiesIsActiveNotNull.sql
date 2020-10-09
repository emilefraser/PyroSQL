SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_rpt_Validate_SameAsLinkEntitiesIsActiveNotNull] AS

SELECT
	  l.SameAsLinkID
	, l.SameAsLinkName
	, l.IsActive AS LinkIsActive
	, mf.FieldName AS MasterFieldName
	, sf.FieldName AS SlaveFieldName
	, lf.IsActive as LinkFieldIsActive
FROM
	DMOD.SameAsLink l
		LEFT JOIN	DMOD.SameAsLinkField lf	ON l.SameAsLinkID = lf.SameAsLinkID
		LEFT JOIN	DC.Field mf				ON lf.MasterFieldID = mf.FieldID 
		LEFT JOIN	DC.Field sf				ON lf.SlaveFieldID = sf.FieldID 
WHERE
	l.IsActive Is Null
	OR (lf.SameAsLinkID Is Not Null AND lf.IsActive Is Null)

GO
