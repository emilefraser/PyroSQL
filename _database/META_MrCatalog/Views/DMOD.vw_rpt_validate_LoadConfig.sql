SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_rpt_validate_LoadConfig] AS 
SELECT
	  lc.LoadConfigID 
	, lc.LoadTypeID 
	, lt.LoadTypeDescription
	, lc.SourceDataEntityID
	, sf.DatabaseEnvironmentTypeName As SourceEnvironment
	, sf.DatabaseName AS SourceDatabase
	, sf.SchemaName AS SourceSchema
	, sf.DataEntityName As SourceDataEntity
	, lc.TargetDataEntityID
	, tf.DatabaseEnvironmentTypeName AS TargetEnvironment
	, tf.DatabaseName As TargetDatabase
	, tf.SchemaName As TargetSchema
	, tf.DataEntityName AS TargetDataEntity
	, lc.CreatedDT
	, lc.UpdatedDT 
	, lc.IsActive 
FROM
	[DMOD].[LoadConfig] lc
		LEFT OUTER JOIN (
						SELECT DISTINCT
							 sourcede.DataEntityID AS SourceDataEntityID
						   , targetde.DataEntityID AS TargetDataEntityID
						FROM
							(
							SELECT DISTINCT 
								vrdfd.DataEntityID
								, vrdfd.SchemaName
								, vrdfd.DataEntityName
								, vrdfd.FieldID
								,	CASE
										WHEN LEN(vrdfd.DataEntityName) - LEN(REPLACE(vrdfd.DataEntityName, '_', '')) > 2 
											THEN SUBSTRING(vrdfd.DataEntityName, CHARINDEX('_', vrdfd.DataEntityName) + 1, CHARINDEX('_', vrdfd.DataEntityName, CHARINDEX('_', vrdfd.DataEntityName) + 1) - CHARINDEX('_', vrdfd.DataEntityName) - 1)
											ELSE SUBSTRING(vrdfd.DataEntityName, 1, CHARINDEX('_',vrdfd.DataEntityName)-1)
									END AS BusinessEntity
							FROM
								DC.vw_rpt_DatabaseFieldDetail AS vrdfd
							INNER JOIN 
								DC.[DataEntity] as de
								ON de.DataEntityID = vrdfd.DataEntityID
							INNER JOIN 
								DC.[Schema] AS s
								ON s.SchemaID = de.SchemaID
							INNER JOIN 
								DC.[Database] AS db
								ON db.DatabaseID = s.DatabaseID
							INNER JOIN 
								DC.[DatabasePurpose] AS dp
								ON dp.DatabasePurposeID = db.DatabasePurposeID
							WHERE
								dp.DatabasePurposeCode IN ('StageArea', 'DataVault')
								AND vrdfd.DataEntityName IS NOT NULL
							) AS targetde
							   INNER JOIN DC.FieldRelation fr						ON fr.TargetFieldID = targetde.FieldID
							   INNER JOIN DC.vw_rpt_DatabaseFieldDetail sourcede	ON sourcede.FieldID = fr.SourceFieldID
							   INNER JOIN DMOD.HubBusinessKeyField hub_bkf			ON hub_bkf.FieldID = sourcede.FieldID
							   INNER JOIN DMOD.HubBusinessKey hub_bk				ON hub_bk.HubBusinessKeyID = hub_bkf.HubBusinessKeyID
							   INNER JOIN DMOD.Hub hub								ON hub.HubID = hub_bk.HubID
						WHERE
							1=1
							--AND targetde.DataEntityID = 47563
							AND BusinessEntity = SUBSTRING(hub.HubName, 5, 1000)
						) vlc
			ON lc.SourceDataEntityID = vlc.SourceDataEntityID 
			AND lc.TargetDataEntityID = vlc.TargetDataEntityID 
		INNER JOIN DMOD.LoadType lt					ON lt.LoadTypeID = lc.LoadTypeID 
		INNER JOIN (SELECT DISTINCT gd.DetailTypeDescription as DatabaseEnvironmentTypeName, vrdfd.DatabaseName, vrdfd.SchemaName, vrdfd.DataEntityID, vrdfd.DataEntityName 
						FROM DC.vw_rpt_DatabaseFieldDetail AS vrdfd
							INNER JOIN 
								DC.[DataEntity] as de
								ON de.DataEntityID = vrdfd.DataEntityID
							INNER JOIN 
								DC.[Schema] AS s
								ON s.SchemaID = de.SchemaID
							INNER JOIN 
								DC.[Database] AS db
								ON db.DatabaseID = s.DatabaseID
							INNER JOIN 
								DC.[DatabasePurpose] AS dp
								ON dp.DatabasePurposeID = db.DatabasePurposeID
							INNER JOIN 
								TYPE.Generic_Detail AS gd
								ON gd.DetailID = db.DatabaseEnvironmentTypeID
							INNER JOIN 
								TYPE.Generic_Header AS gh
								ON gh.HeaderID = gd.HeaderID
							WHERE 
								gd.DetailTypeCode = 'DV_ENV'
		) sf	ON sf.DataEntityID = lc.SourceDataEntityID
		INNER JOIN (SELECT DISTINCT gd.DetailTypeDescription as DatabaseEnvironmentTypeName, vrdfd.DatabaseName, vrdfd.SchemaName, vrdfd.DataEntityID, vrdfd.DataEntityName 
		FROM DC.vw_rpt_DatabaseFieldDetail AS vrdfd
							INNER JOIN 
								DC.[DataEntity] as de
								ON de.DataEntityID = vrdfd.DataEntityID
							INNER JOIN 
								DC.[Schema] AS s
								ON s.SchemaID = de.SchemaID
							INNER JOIN 
								DC.[Database] AS db
								ON db.DatabaseID = s.DatabaseID
							INNER JOIN 
								DC.[DatabasePurpose] AS dp
								ON dp.DatabasePurposeID = db.DatabasePurposeID
							INNER JOIN 
								TYPE.Generic_Detail AS gd
								ON gd.DetailID = db.DatabaseEnvironmentTypeID
							INNER JOIN 
								TYPE.Generic_Header AS gh
								ON gh.HeaderID = gd.HeaderID
							WHERE 
								gd.DetailTypeCode = 'DV_ENV'
		
		) tf	ON tf.DataEntityID = lc.TargetDataEntityID
WHERE
	vlc.TargetDataEntityID is null

GO
