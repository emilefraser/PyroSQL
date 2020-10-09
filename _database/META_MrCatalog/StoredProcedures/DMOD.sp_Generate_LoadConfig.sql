SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

												-- Metadata --
/* ========================================================================================================================
	Created by	:	Emile Fraser
	Dreated on	:	2020-07-01
	Function	:	Creates the Load Configutation for ODS to Vault Loads
	Description	:	Creates the Load Configutation for ODS to Vault Loads
======================================================================================================================== */

												-- ChangeLog --
/* ========================================================================================================================
	 2020-07-01	:	Intial Script Using a CTE to create the config via Lineage
	 TODO		:	Pulling Load types into Variables and using that instead of Number
	 TODO		:	Other Load Types like status tracking Satellite
======================================================================================================================== */

											-- Execution & Testing --
/* ========================================================================================================================
    EXEC [DMOD].[sp_Generate_LoadConfig]
======================================================================================================================== */
CREATE PROCEDURE [DMOD].[sp_Generate_LoadConfig]
AS
BEGIN
	
	DECLARE @IsDebug BIT = 1

	IF ( @IsDebug = 1 )
	BEGIN
		SELECT 'Initial LoadConfig' AS [Step], * FROM [DMOD].[LoadConfig]
	END	


	-- Temp table filled with loadconfig from app and is manipulated to perform stage load configs  
	-- Resets the loads config back to its original modeled state Resets back to ODS Join to get all higher level 
	DELETE FROM 
		[DMOD].[LoadConfig]
	WHERE
		[LoadConfigID] IN (
					SELECT DISTINCT
						[LC1].[LoadConfigID]
					FROM
						[DMOD].[LoadConfig] AS [LC1]
					LEFT JOIN
						[DMOD].[LoadConfig] AS [LC2]
						ON [LC1].[SourceDataEntityID] = [LC2].[TargetDataEntityID]
					WHERE 
						[LC2].[LoadConfigID] IS NOT NULL
	)

	-- Also part of the Reset... All targets should be null
	UPDATE 
		[DMOD].[LoadConfig]
	SET
		[TargetDataEntityID] = NULL

	IF ( @IsDebug = 1 )
	BEGIN
		SELECT 'LoadConfig After Nullifying' AS [Step], * FROM [DMOD].[LoadConfig]
	END	

	-- Holder for Loadconfig to be used to add the levels
	DROP TABLE IF EXISTS [#loadconfigtemp]
	CREATE TABLE [#loadconfigtemp] (
		[LoadConfigID]                INT NULL
	  , [SourceDataEntityID]          INT NULL
	  , [DataEntityTypeID]            INT NULL
	  , [TargetDataEntityID]          INT NULL
	  , [TargetDataEntityname]        VARCHAR(200) NULL
	  , [LoadTypeCode]                VARCHAR(200) NULL
	  , [CreatedDT_FieldID]           INT NULL
	  , [UpdatedDT_FieldID]           INT NULL
	  , [LoadTypeID]                  INT NULL
	)

	-- Initially we move from ODS to Stage, Only active LoadConfigs
	-- Thus need to reactivate older loads before they will appear
	INSERT INTO [#loadconfigtemp] (
		[LoadConfigID]
	  , [SourceDataEntityID]
	  , [DataEntityTypeID]
	  , [TargetDataEntityID]
	  , [TargetDataEntityname]
	  , [LoadTypeCode]
	  , [CreatedDT_FieldID]
	  , [UpdatedDT_FieldID]
	)
	SELECT
		[lc].[LoadConfigID]
	  , [lc].[SourceDataEntityID]
	  , [lt].[DataEntityTypeID]
	  , [trgDE].[TargetDataEntityID]
	  , [trgDE].[TargetDataEntityname]
	  , [lt].[LoadTypeCode]
	  , [lc].[CreatedDT_FieldID]
	  , [lc].[UpdatedDT_FieldID]
	FROM
		[DMOD].[LoadConfig] AS [lc]
	INNER JOIN
		[DMOD].[LoadType] AS [lt]
		ON [lt].[LoadTypeID] = [lc].[LoadTypeID]
	INNER JOIN
		[DC].[DataEntityType] AS [det]
		ON
		   [det].[DataEntityTypeID] = [lt].[DataEntityTypeID]
	LEFT JOIN
		(
			SELECT DISTINCT
				[lin].[SourceDataEntityID]
			  , [lin].[SourceDataEntityName]
			  , [lin].[SourceDataEntityTypeCode]
			  , [lin].[TargetDataEntityID]
			  , [lin].[TargetDataEntityname]
			  , [lin].[TargetDataEntityTypeCode]
			FROM
				[DC].[vw_DCDataLineage] AS [lin]
			WHERE 
				[lin].[TargetFieldName] = 'BKHash' 
			AND 
				[lin].[TargetFieldName] <> 'HashDiff'
	) AS [trgDE]
		ON	[trgDE].[TargetDataEntityTypeCode] = [det].[DataEntityTypeCode] 
		AND [lc].[SourceDataEntityID] = [trgDE].[sourceDataEntityID]
	LEFT JOIN
		[dc].[DataEntity] AS [de1]
		ON [de1].[DataEntityID] = [lc].[SourceDataEntityID]
	LEFT JOIN
		[dc].[Schema] AS [s1]
		ON [de1].[SchemaID] = [s1].[SchemaID]
	LEFT JOIN
		[dc].[database] AS [db1]
		ON [db1].[DatabaseID] = [s1].[DatabaseID]
	LEFT JOIN
		[dc].[DataEntity] AS [de2]
		ON [de2].[DataEntityID] = [trgDE].[TargetDataEntityID]
	LEFT JOIN
		[dc].[Schema] AS [s2]
		ON [de2].[SchemaID] = [s2].[SchemaID]
	LEFT JOIN
		[dc].[database] AS [db2]
		ON [db2].[DatabaseID] = [s2].[DatabaseID]
	WHERE [LC].[IsActive] = 1
	--where db2.DatabaseEnvironmentTypeID = db1.DatabaseEnvironmentTypeID
	
	
	IF ( @IsDebug = 1 )
	BEGIN
		SELECT 'Initial ODS' AS [Step], * FROM [#loadconfigtemp]
	END	
	
	
	
	
	--SELECT * FROM #loadconfigtemp
	--****Gives the initial load configs target dataenetityids
	-- ODS to STAGE
	UPDATE [DMOD].[LoadConfig]
	SET
		[TargetDataEntityID] = [LCF].[TargetDataEntityID]
	FROM [#loadconfigtemp] [LCF]
	WHERE
		[DMOD].[LOADCONFIG].[LoadConfigID] = [LCF].[LoadConfigID]

	--SELECT * FROM DMOD.LoadConfig
	--SELECT * FROM #loadconfigtemp
	--** DONT DELETE THIS CODE
	-- Adds LoadType to 1st Level (In our case to ODS-Stage)
	UPDATE [#loadconfigtemp]
	SET
		[LoadTypeID] = [j].[LoadTypeID1]
	FROM (
			 SELECT
				 [LCT].[LoadConfigID] AS [LoadConfigID1] /*LCT.*, LC.LoadTypeID, LT.LoadTypeCode,*/				 --**** Make Dynamic so that the code doesnt run off hardcoded stuff
			   , CASE
										 -- EF: To add SATSTAT HERE when loadtype created
					 WHEN [LCT].[TargetDataEntityName] LIKE '%REF_%_KEYS'
						 THEN 48 -- 20191003 - Added by FG to create Load Configs for REF tables
					 WHEN [LCT].[TargetDataEntityName] LIKE '%REF_%_%VD'
						 THEN 49 -- 20191003 - Added by FG to create Load Configs for REFSAT tables
					 WHEN [LT].[LOADTYPECODE] LIKE '%LVD%'
						 THEN 35
					 WHEN [LT].[LOADTYPECODE] LIKE '%KEYS%'
						 THEN 33
					 WHEN [LT].[LOADTYPECODE] LIKE '%MVD%'
						 THEN 36
					 WHEN [LT].[LOADTYPECODE] LIKE '%HVD%'
						 THEN 37
						 ELSE 6666
				 END AS [LoadTypeID1]
			 FROM
				 [#loadconfigtemp] AS [LCT]
			 LEFT JOIN
				 [DMOD].[LoadConfig] AS [LC]
				 ON [LC].[LoadConfigID] = [LCT].[LoadConfigID]
			 LEFT JOIN
				 [DMOD].[LoadType] AS [LT]
				 ON [LC].[LoadTypeID] = [LT].[LoadTypeID]
	) [j]
	WHERE
		[LoadConfigID] = [j].[LoadConfigID1]

	-- END LEVEL 1
	IF ( @IsDebug = 1 )
	BEGIN
		SELECT 'Level 1 end (Stage)' AS [Step], * FROM [#loadconfigtemp]
	END	




	-- START OF 2nd LEVEL					
	--***************************************************** Convert the Stage loads to vault loads ***********************************************************
	DROP TABLE IF EXISTS
		[#loadconfigtempVault]
	CREATE TABLE [#loadconfigtempVault] (
		[LoadConfigID]                INT NULL
	  , [SourceDataEntityID]          INT NULL
	  , [DataEntityTypeID]            INT NULL
	  , [TargetDataEntityID]          INT NULL
	  , [TargetDataEntityname]        VARCHAR(200) NULL
	  , [LoadTypeCode]                VARCHAR(200) NULL
	  , [CreatedDT_FieldID]           INT NULL
	  , [UpdatedDT_FieldID]           INT NULL,
	)

	-- Joins through Lineage to Stage 
	-- Adds Level 2 Loads (Stage-Vault)
	INSERT INTO [#loadconfigtempVault]
	SELECT
		NULL AS [Loadconfigid]
	  , [k].[SourceDataEntityID]
	  , [k].[DataEntityTypeID]
	  , [k].[TargetDataEntityID]
	  , [de2].[DataEntityName] AS [trgtDE]
	  , [k].[loadtypecode]
	  , NULL AS [created]
	  , NULL AS [updated]--, de1.DataEntityName as srcde, de2.DataEntityName as trgde from (
	FROM
		(
			SELECT
				[lc].[LoadConfigID]
			  , [lc].[TargetDataEntityID] AS [SourceDataEntityID]
			  , [lt].[DataEntityTypeID]
			  , [trgDE].[TargetDataEntityID]
			  , [trgDE].[TargetDataEntityname]
			  , [lt].[LoadTypeCode]
			  , [lc].[CreatedDT_FieldID]
			  , [lc].[UpdatedDT_FieldID]
			FROM
				[#loadconfigtemp] AS [lc]
			INNER JOIN
				[DMOD].[LoadType] AS [lt]
				ON [lt].[LoadTypeID] = [lc].[LoadTypeID]
			INNER JOIN
				[DC].[DataEntityType] AS [det]
				ON
				   [det].[DataEntityTypeID] = [lt].[DataEntityTypeID]
			INNER JOIN
				(
					SELECT DISTINCT
						[lin].[SourceDataEntityID]
					  , [lin].[SourceDataEntityName]
					  , [lin].[SourceDataEntityTypeCode]
					  , [lin].[TargetDataEntityID]
					  , [lin].[TargetDataEntityname]
					  , [lin].[TargetDataEntityTypeCode]
					  , [lin].[TargetFieldName]
					FROM
						[DC].[vw_DCDataLineage] AS [lin]
					WHERE 1 = 1 AND [lin].[TargetFieldName] LIKE 'HK_%'
				--and lin.TargetDataEntityname like '%Date%'
			) AS [trgDE]
				ON 1 = 1 AND
							 [trgDE].[TargetDataEntityTypeCode] = [det].[DataEntityTypeCode] AND
																								 [lc].[TargetDataEntityID] = [trgDE].[sourceDataEntityID]
	) AS [k]
	LEFT JOIN
		[dc].[DataEntity] AS [de1]
		ON
		   [k].[SourceDataEntityID] = [de1].[DataEntityID]
	LEFT JOIN
		[dc].[DataEntity] AS [de2]
		ON
		   [k].[TargetDataEntityID] = [de2].[DataEntityID]
	LEFT JOIN
		[dc].[Schema] AS [s1]
		ON [de1].[SchemaID] = [s1].[SchemaID]
	LEFT JOIN
		[dc].[database] AS [db1]
		ON [db1].[DatabaseID] = [s1].[DatabaseID]
	LEFT JOIN
		[dc].[Schema] AS [s2]
		ON [de2].[SchemaID] = [s2].[SchemaID]
	LEFT JOIN
		[dc].[database] AS [db2]
		ON [db2].[DatabaseID] = [s2].[DatabaseID]



	-- END LEVEL 1
	IF ( @IsDebug = 1 )
	BEGIN
		SELECT 'Temp Vault Relationsips' AS [Step], * FROM [#loadconfigtempVault]
	END	


	--where db2.DatabaseEnvironmentTypeID = db1.DatabaseEnvironmentTypeID
	--***************************************************** INSERTS HUBS & SATS ***********************************************************
	--INSERT INTO [DMOD].[LoadConfig] (
	--	[LoadTypeID]
	--  , [SourceDataEntityID]
	--  , [TargetDataEntityID]
	--  , [IsSetForReloadOnNextRun]
	--  , [OffsetDays]
	--  , [CreatedDT_FieldID]
	--  , [UpdatedDT_FieldID]
	--  , [CreatedDT]
	--  , [UpdatedDT]
	--  , [IsActive]
	--)
	SELECT --NULL as LoadConfigID, --WILL INSERT HUB AND SATS OF VAULT INTO LOAD CONFIG
		CASE
			WHEN [lct].[TargetDataEntityname] LIKE 'REFSAT_%VD'
				THEN 49 -- 20191003 - Added by FG to create Load Configs for REFSAT tables
			WHEN [lct].[TargetDataEntityname] LIKE 'REF_%'
				THEN 48 -- 20191003 - Added by FG to create Load Configs for REF tables
			WHEN [lct].[TargetDataEntityname] LIKE 'HUB%'
				THEN 33
			WHEN [lct].[TargetDataEntityname] LIKE 'LINK%'
				THEN 34
			WHEN [lct].[TargetDataEntityname] LIKE '%LVD'
				THEN 35
			WHEN [lct].[TargetDataEntityname] LIKE '%MVD'
				THEN 36
			WHEN [lct].[TargetDataEntityname] LIKE '%HVD'
				THEN 37
				ELSE 66666
		END AS [LoadTypeID]
	  , [lct].[SourceDataEntityID]
	  , [lct].[TargetDataEntityID]
	  , 0
	  , NULL
	  , NULL
	  , NULL
	  , GETDATE()
	  , NULL
	  , 1
	--,TargetDataEntityname
	FROM
		[#loadconfigtempVault] AS [lct]
	INNER JOIN
		[DMOD].[LoadType] AS [lt]
		ON [lt].[LoadTypeCode] = [lct].[LoadTypeCode]
	WHERE NOT EXISTS (
						 SELECT
							 1
						 FROM
							 [DMOD].[LoadConfig]
						 WHERE
							   [SourceDataEntityID] = [lct].[SourceDataEntityID] AND
																					 [TargetDataEntityID] = [lct].[TargetDataEntityID] AND [LoadTypeID] = [lt].[LoadTypeID]
	)


	-- END LEVEL 1
	IF ( @IsDebug = 1 )
	BEGIN
		SELECT 'Hubs and Links Done' AS [Step], * FROM [DMOD].[LoadConfig]
	END	

	--SELECT * FROM DMOD.LoadConfig --113 WAS LAST LOAD  NB!!!
	--******************************************************* INSERTS LINKS *************************************************************
	--INSERT INTO [DMOD].[LoadConfig] (
	--	[LoadTypeID]
	--  , [SourceDataEntityID]
	--  , [TargetDataEntityID]
	--  , [IsSetForReloadOnNextRun]
	--  , [OffsetDays]
	--  , [CreatedDT_FieldID]
	--  , [UpdatedDT_FieldID]
	--  , [CreatedDT]
	--  , [UpdatedDT]
	--  , [IsActive]
	--)
	SELECT    --THIS WILL INSERT ALL THE LOAD CONFIGS FOR LINKS INTO THE LOAD CONFIG
	--NULL,
		34 AS [LoadTypeID]
	  , [lcv].[SourceDataEntityID]
	  , [de].[DataEntityID] AS [TargetDataEntityID]
		--z.LinkName as TargetDataEntityName ,
		--DE1.DataEntityName,
	  , 0
	  , NULL
	  , NULL
	  , NULL
	  , GETDATE()
	  , NULL
	  , 1
	FROM
		[#loadconfigtempVault] AS [LCV]
	LEFT JOIN
		[DMOD].[HUB] AS [H]
		ON [H].[HUBNAME] = [LCV].[TARGETDATAENTITYNAME]
	LEFT JOIN
		[DMOD].[PKFKLINK] AS [PFL]
		ON [PFL].[CHILDHUBID] = [H].[HUBID]
	LEFT JOIN
		[DC].[DataEntity] AS [DE]
		ON
		   [DE].[DataEntityName] = ISNULL('LINK_'
										  + [PFL].[ParentHubNameVariation]
										  + '_'
										  + [DMOD].[udf_get_HubName_HubID] ([PFL].[ChildHubID]
	), [PFL].[LinkName])
	LEFT JOIN
		[DC].[DataEntity] AS [DE1]
		ON
		   [DE1].[DataEntityID] = [lcv].[TargetDataEntityID]
	LEFT JOIN
		[DC].[Schema] AS [S1]
		ON [S1].[SchemaID] = [DE1].[SchemaID]
	LEFT JOIN
		[DC].[Database] AS [DB1]
		ON [DB1].[DatabaseID] = [S1].[DatabaseID]
	LEFT JOIN
		[DC].[DataEntity] AS [DE2]
		ON [DE2].[DataEntityID] = [de].[DataEntityID]
	LEFT JOIN
		[DC].[Schema] AS [S2]
		ON [S2].[SchemaID] = [DE2].[SchemaID]
	LEFT JOIN
		[DC].[Database] AS [DB2]
		ON [DB2].[DatabaseID] = [S2].[DatabaseID]
	WHERE [PFL].[PKFKLinkID] IS NOT NULL AND [PFL].[IsActive] = 1 AND [db1].[DatabaseID] = [db2].[DatabaseID] AND
																												  [db1].[DatabaseEnvironmentTypeID] = [db2].[DatabaseEnvironmentTypeID]

												
												
												
	-- END LEVEL 1
	IF ( @IsDebug = 1 )
	BEGIN
		SELECT 'Links Done' AS [Step], * FROM [DMOD].[LoadConfig]
	END													
												
												
												
												--*******************************Deletes links that should no exist according to field relation ***************
																												  --this is an double fix at kevro due to having two systems
/*
delete from dmod.LoadConfig

select * from dmod.vw_LoadConfig
where LoadConfigID in(
select lc.LoadConfigID from dmod.LoadConfig lc
left join dc.DataEntity de
on de.DataEntityID = lc.TargetDataEntityID
left join 
(
	select 
	--lc.*,fs.FieldName,fs.FieldID, 1, ft.FieldName, ft.FieldID 
	distinct lc.LoadConfigID
	from dmod.LoadConfig lc
	left join dc.DataEntity des
	on des.DataEntityID = lc.SourceDataEntityID
	left join dc.Field fs
	on fs.DataEntityID = des.DataEntityID

	left join dc.DataEntity det
	on det.DataEntityID = lc.TargetDataEntityID
	left join dc.Field ft
	on ft.DataEntityID = det.DataEntityID

	left join dc.FieldRelation fr
	on fr.SourceFieldID = fs.FieldID and fr.TargetFieldID = ft.FieldID
	where det.DataEntityName like 'link_%'
	and fr.TargetFieldID is not null
	and fs.FieldName like 'hk_%'
	and ft.FieldName like 'hk_%'
) k 
on k.LoadConfigID = lc.LoadConfigID
where DataEntityName like 'link_%'
and k.LoadConfigID is null
)

*/

																												  --select * from dc.[database]
/*
select    --THIS WILL INSERT ALL THE LOAD CONFIGS FOR LINKS INTO THE LOAD CONFIG
--NULL,
CASE 
   WHEN DE1.DataEntityName LIKE 'HUB%' THEN 33
   WHEN DE1.DataEntityName LIKE 'LINK%' THEN 34
   WHEN DE1.DataEntityName LIKE '%LVD' THEN 35
   WHEN DE1.DataEntityName LIKE '%MVD' THEN 36
   WHEN DE1.DataEntityName LIKE '%HVD' THEN 37
   ELSE 6666666
   END  AS LoadTypeID,
lcv.SourceDataEntityID,
z.LINKID as TargetDataEntityID,
--z.LinkName as TargetDataEntityName ,
--DE1.DataEntityName,
0,
NULL,
NULL,
NULL,
GETDATE(),
NULL,
1
from #loadconfigtempVault lcv
LEFT JOIN (
SELECT
DE.DataEntityName,
SUBSTRING(DE.DATAENTITYNAME,(2+LEN(DE.DataEntityName)-PATINDEX('%[_]%',REVERSE(de.DataEntityName))),LEN(DE.DataEntityName)) AS LinkName
,de.DataEntityID AS LINKID
FROM dc.DataEntity de
WHERE de.DataEntityName like 'link%'
) Z
ON Z.LinkName = REPLACE(lcv.TargetDataEntityname,'hub_','')

LEFT JOIN DC.DataEntity DE1
ON DE1.DataEntityID = Z.LINKID
LEFT JOIN DC.[Schema] S1
ON S1.SchemaID = DE1.SchemaID
LEFT JOIN DC.[Database] DB1
ON DB1.DatabaseID = S1.DatabaseID

LEFT JOIN DC.DataEntity DE2
ON DE2.DataEntityID = LCV.TargetDataEntityID
LEFT JOIN DC.[Schema] S2
ON S2.SchemaID = DE2.SchemaID
LEFT JOIN DC.[Database] DB2
ON DB2.DatabaseID = S2.DatabaseID

where lcv.TargetDataEntityname like 'hub%'
AND DB1.DatabaseID = DB2.DatabaseID

*/

/*                                      *****************USE TO CONNECT LINKS TO TABLES
SELECT * FROM #loadconfigtempVault LCV
LEFT JOIN DMOD.HUB H
ON H.HUBNAME = LCV.TARGETDATAENTITYNAME
LEFT JOIN DMOD.PKFKLINK PFL
ON PFL.CHILDHUBID = H.HUBID

WHERE H.HUBNAME IS NOT NULL
*/
END
GO
