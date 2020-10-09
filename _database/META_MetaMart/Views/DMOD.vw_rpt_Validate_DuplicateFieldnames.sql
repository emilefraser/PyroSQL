SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_rpt_Validate_DuplicateFieldnames] AS

SELECT
	db.DatabaseID 
	, db.DatabaseName
	, s.SchemaID
	, s.SchemaName 
	, de.DataEntityID
	, de.DataEntityName
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
		INNER JOIN (	SELECT
							DataEntityID
							, FieldName
						FROM
							DC.[Field] f
						WHERE
							f.IsActive = 1
						GROUP BY
							DataEntityID
							, FieldName
						HAVING
							COUNT(1) > 1) df	ON f.DataEntityID = df.DataEntityID 
												AND f.FieldName = df.FieldName
		INNER JOIN DC.DataEntity de				ON f.DataEntityID = de.DataEntityID AND de.IsActive = 1
		INNER JOIN DC.[Schema] s				ON de.SchemaID = s.SchemaID AND s.IsActive = 1
		INNER JOIN DC.[Database] db				ON s.DatabaseID = db.DatabaseID AND db.IsActive = 1
WHERE
	f.IsActive = 1


GO
