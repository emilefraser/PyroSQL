SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [DMOD].[vw_rpt_Validate_OrphanFields] AS

SELECT
	  f.DataEntityID
	, f.FieldID
	, f.FieldName
	, f.FriendlyName
	, f.DataType
	, f.[MaxLength]
	, f.[Precision]
	, f.[Scale]
	, f.FieldSortOrder
FROM
	DC.[Field] f
		LEFT JOIN DC.DataEntity de				ON f.DataEntityID = de.DataEntityID AND ISNULL(de.IsActive, 1) = 1
WHERE
	(f.DataEntityID Is Null
	OR de.DataEntityID Is Null)
	AND ISNULL(f.IsActive, 1) = 1


GO
