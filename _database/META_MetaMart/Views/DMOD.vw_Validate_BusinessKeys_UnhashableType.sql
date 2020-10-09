SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_Validate_BusinessKeys_UnhashableType]
AS
SELECT 
	 h.HubID, h.HubName, hbk.HubBusinessKeyID, hbk.BKFriendlyName
	, hbkf.IsBaseEntityField
	,	hbkf.HubBusinessKeyFieldID	
	, f.FieldID,f.FieldName, f.DataType, f.[MaxLength]
	, de.DataEntityID, de.DataEntityName
	, s.SchemaID, s.SchemaName
	, db.DatabaseID, db.DatabaseName
FROM 
			DMOD.Hub AS h
		INNER JOIN 
			DMOD.HubBusinessKey AS hbk
			ON hbk.HubID = h.HubID
		INNER JOIN 
			DMOD.HubBusinessKeyField AS hbkf
			ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
		INNER JOIN 
			DC.[Field] AS f
			ON f.FieldID = hbkf.FieldID
		INNER JOIN 
			DC.DataEntity AS de
			ON de.DataEntityID = f.DataEntityID
		INNER JOIN 
			DC.[Schema] AS s
			ON s.SchemaID = de.SchemaID
		INNER JOIN 
			DC.[Database] AS db
			ON db.DatabaseID = s.DatabaseID
		WHERE 
			h.IsActive = 1
		AND
			hbk.IsActive = 1
		AND
			hbkf.IsActive = 1
		AND
			f.DataType IN
			(
				SELECT 
					[name] 
				FROM 
					sys.types 
				WHERE 
					[name] LIKE  '%date%' 
				OR	[name] LIKE '%time%' 
				OR	[name] IN	(
									'geometry'
								,	'geography'
								,	'image'
								)
			)

GO
