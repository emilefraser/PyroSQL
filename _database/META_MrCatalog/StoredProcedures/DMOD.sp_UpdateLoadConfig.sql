SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [DMOD].[sp_UpdateLoadConfig]
	@StageAreaDBName varchar(50)
AS









-- DO NOT USE THIS PROC - TALK TO FRANS OR KARL
-- This functionality is replaced by front end functionality














/*


--INSERT INTO [DMOD].[LoadConfig]
--	(
--	LoadTypeID
--	, SourceDataEntityID
--	, TargetDataEntityID
--	, IsSetForReloadOnNextRun
--	, IsActive
--	, CreatedDT 
--	)
SELECT DISTINCT
		 CASE REPLACE(SUBSTRING(targetde.DataEntityName, LEN(targetde.DataEntityName) - 3, 4), '_', '')
			WHEN 'KEYS' THEN 7 --KEYS
			WHEN 'LVD'	THEN 8 --Velocity
			WHEN 'MVD'	THEN 8 --Velocity
			WHEN 'HVD'	THEN 8 --Velocity
			ELSE -1
		 END AS LoadType
	   , sourcede.DataEntityID AS SourceDataEntityID
	   --, sourcede.DatabaseName AS SourceDatabaseName
	   --, sourcede.SchemaName AS SourceSchemaName
	   --, sourcede.DataEntityName AS SourceDataEntityName
	   , targetde.DataEntityID AS TargetDataEntityID
	   --, targetde.SchemaName AS TargetSchemaName
	   --, targetde.DataEntityName AS TargetDataEntityName
	   --, hub.HubName
	   --, REPLACE(SUBSTRING(targetde.DataEntityName, LEN(targetde.DataEntityName) - 3, 4), '_', '') AS Type
	   , 0 AS IsSetForReloadOnNextRun
	   , 1 AS IsActive
	   , GetDate() AS CreatedDT
  FROM (
		SELECT DISTINCT DataEntityID, SchemaName, DataEntityName, FieldID
			   , CASE
					WHEN LEN(DataEntityName) - LEN(REPLACE(DataEntityName, '_', '')) > 2 THEN SUBSTRING(DataEntityName, CHARINDEX('_', DataEntityName) + 1, CHARINDEX('_', DataEntityName, CHARINDEX('_', DataEntityName) + 1) - CHARINDEX('_', DataEntityName) - 1)
					WHEN LEN(DataEntityName) - LEN(REPLACE(DataEntityName, '_', '')) = 1 THEN SUBSTRING(DataEntityName, 1, CHARINDEX('_',DataEntityName)-1)
					ELSE ''
				 END AS BusinessEntity
		  FROM DC.vw_rpt_DatabaseFieldDetail
		 WHERE DatabaseName = @StageAreaDBName AND
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
	   LEFT JOIN [DMOD].[LoadConfig] lc ON
			sourcede.DataEntityID = lc.SourceDataEntityID AND targetde.DataEntityID = lc.TargetDataEntityID
 WHERE 
	targetde.BusinessEntity = SUBSTRING(hub.HubName, 5, 1000)
	   AND lc.LoadConfigID is null

SELECT 'Load config records that are not valid'

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
					WHEN LEN(DataEntityName) - LEN(REPLACE(DataEntityName, '_', '')) = 1 THEN SUBSTRING(DataEntityName, 1, CHARINDEX('_',DataEntityName)-1)
					ELSE ''
				 END AS BusinessEntity
		  FROM DC.vw_rpt_DatabaseFieldDetail
		 WHERE DatabaseName = @StageAreaDBName AND
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
WHERE vlc.SourceDataEntityID is null


*/

GO
