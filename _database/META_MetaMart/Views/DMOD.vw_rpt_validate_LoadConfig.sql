SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_rpt_validate_LoadConfig] AS 
SELECT lc.*
FROM
	[DMOD].[LoadConfig] lc
		LEFT OUTER JOIN (
SELECT DISTINCT
		 sourcede.DataEntityID AS SourceDataEntityID
	   , targetde.DataEntityID AS TargetDataEntityID
  FROM (
		SELECT DISTINCT DataEntityID, SchemaName, DataEntityName, FieldID
			   , CASE
					WHEN LEN(DataEntityName) - LEN(REPLACE(DataEntityName, '_', '')) > 2 THEN SUBSTRING(DataEntityName, CHARINDEX('_', DataEntityName) + 1, CHARINDEX('_', DataEntityName, CHARINDEX('_', DataEntityName) + 1) - CHARINDEX('_', DataEntityName) - 1)
					ELSE SUBSTRING(DataEntityName, 1, CHARINDEX('_',DataEntityName)-1)
				 END AS BusinessEntity
		  FROM DC.vw_rpt_DatabaseFieldDetail
		 WHERE DatabaseName = 'DEV_StageArea' AND
			   DataEntityName IS NOT NULL
		) AS targetde
	   INNER JOIN DC.FieldRelation fr ON
			fr.TargetFieldID = targetde.FieldID
	   INNER JOIN DC.vw_rpt_DatabaseFieldDetail sourcede ON
			sourcede.FieldID = fr.SourceFieldID
	   INNER JOIN DMOD.HubBusinessKeyField hub_bkf ON
			hub_bkf.FieldID = sourcede.FieldID
	   INNER JOIN DMOD.HubBusinessKey hub_bk ON
			hub_bk.HubBusinessKeyID = hub_bkf.HubBusinessKeyID
	   INNER JOIN DMOD.Hub hub ON
			hub.HubID = hub_bk.HubID
 WHERE --targetde.DataEntityID = 47563 AND
	   BusinessEntity
			= SUBSTRING(hub.HubName, 5, 1000)
			) vlc
		ON lc.SourceDataEntityID = vlc.SourceDataEntityID 
		AND lc.TargetDataEntityID = vlc.TargetDataEntityID 
WHERE
	vlc.TargetDataEntityID is null

GO
