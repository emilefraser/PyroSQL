SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



-- ====================================================================================================
-- Author:      Francois Senekal
-- Create Date: 24 January 2019
-- Description: Creates Satelite tables in DC and auto-creates relationships to Source/SAT
-- ====================================================================================================
-- Version Control
-- ====================================================================================================
/*
	Date		| Person				| Notes
	---------------------------------------------------------------------------------------------------
	2019-02-20	| Frans Germishuizen	| Reviewed and approved --> to be tested

*/
-- ====================================================================================================

CREATE PROCEDURE [DC].[sp_CreateSatelliteTableInDC_Backup20190917] 
@HubID int
,@TargetSatDatabaseID int
AS

/*--====================================================================================================
Test Case 1 :
1. Set @TargetSATDatabaseID to one that doesn't exist (9999)
2. Run the Proc
3. Check if new entries where created (TODO: Change CreatedDT to date proc ran)
	SELECT * FROM DC.[SCHEMA] WHERE CREATEDDT > '2019/01/31'
	SELECT * FROM DC.DATAENTITY WHERE CREATEDDT > '2019/01/31'
	SELECT * FROM DC.FIELD WHERE CREATEDDT > '2019/01/31'
	SELECT * FROM DC.FIELDRELATION WHERE CREATEDDT > '2019/01/31'
4. Delete test entries !!!(BEWARE OF DELETE STATEMENTS)!!!

Test Case 2 :
1. Set @TargetSATDatabaseID to one that already exists 
2. Run the Proc
3. Check if no new entries where created (TODO: Change CreatedDT to date proc ran)
	SELECT * FROM DC.[SCHEMA] WHERE CREATEDDT > '2019/01/31'
	SELECT * FROM DC.DATAENTITY WHERE CREATEDDT > '2019/01/31'
	SELECT * FROM DC.FIELD WHERE CREATEDDT > '2019/01/31'
	SELECT * FROM DC.FIELDRELATION WHERE CREATEDDT > '2019/01/31'
--====================================================================================================*/

--====================================================================================================
--	All Variables Declared Here
--====================================================================================================

--DECLARE	@HubID INT
--SET		@HubID = 1016

--DECLARE @TargetSATDatabaseID INT
--SET		@TargetSATDatabaseID = 8

DECLARE @TargetSchemaID INT
DECLARE @TargetSchemaName VARCHAR(20)
--SET @TargetSchemaName = (SELECT schemaname FROM dc.[schema] WHERE databaseid = @TargetSATDatabaseID)
SET @TargetSchemaName = 'raw'

--DELETE fr FROM DC.FieldRelation fr LEFT JOIN DC.Field f ON f.FieldID = fr.SourceFieldID WHERE f.FieldID IS NULL
--DELETE fr FROM DC.FieldRelation fr LEFT JOIN DC.Field f ON f.FieldID = fr.TargetFieldID WHERE f.FieldID IS NULL


--====================================================================================================
--	Insert the SAT in TempTable
--====================================================================================================
DROP TABLE IF EXISTS #SatDataEntity
CREATE TABLE #SatDataEntity
(
 HubID int
,HubName varchar(100)
,HubBusinessKeyID int
,BusinessKeyFriendlyName varchar(100)
,HubSourceSystemName varchar(100)
,HubBKDBName varchar(100)
,HubBKDEID int
,HubBKDEName varchar(100)
,HubBKDataEntityHKName varchar(100)
,HubBKFieldID int
,HubBKFieldName varchar(100)
,SatelliteName varchar(100)
,SatelliteDataVelocityTypeID int 
,SatelliteDataVelocityTypeCode varchar(100)
,SatSourceSystemName varchar(100)
,SatDBName varchar(100)
,SatBKDEID int
,SatDEName varchar(100)
,SatFieldID int
,SatFieldName varchar(100)
,SatFieldDataType varchar(100)
,SatFieldMaxLength int
,SatFieldPrecision int
,SatFieldScale int
,SatFieldFieldSortOrder int
,SatelliteDataEntityID int
,SatelliteDataEntityName varchar(100)
)

INSERT INTO #SatDataEntity

--DECLARE	@HubID INT
--SET		@HubID = 1016

--DECLARE @TargetSATDatabaseID INT
--SET		@TargetSATDatabaseID = 8

SELECT DISTINCT HubID = h.HubID 
	  ,HubName = h.HubName
	  ,HubBusinessKeyID = hbk.HubBusinessKeyID
	  ,BusinessKeyFriendlyName = hbk.BKFriendlyName
	  ,HubSourceSystemName = hubsys.SystemName 
	  ,HubBKDBName = hubbkfielddetail.DatabaseName
	  ,HubBKDEID = hubbkfielddetail.DataEntityID 
	  ,HubBKDEName = hubbkfielddetail.DataEntityName 
	  ,HubBKDataEntityHKName = 'HK_' + REPLACE(h.HubName, 'HUB_', '')
	  ,hbkf.FieldID AS HubBKFieldID
	  ,hubbkfielddetail.FieldName AS HubBKFieldName
	  ,s.SatelliteName
	  ,s.SatelliteDataVelocityTypeID
	  ,satvel.SatelliteDataVelocityTypeCode
	  ,Satsys.SystemName AS SatSourceSystemName
	  ,satfielddetail.DatabaseName AS SatDBName
	  ,satfielddetail.DataEntityID AS SatBKDEID
	  ,satfielddetail.DataEntityName AS SatDEName
	  ,satf.FieldID AS SatFieldID
	  ,satfielddetail.FieldName AS SatFieldName
	  ,satfielddetail.DataType
	  ,satfielddetail.MaxLength
	  ,satfielddetail.Precision
	  ,satfielddetail.Scale
	  ,satfielddetail.FieldSortOrder
	  ,NULL
	  ,NULL
FROM DMOD.Hub h 
	INNER JOIN DMOD.HubBusinessKey hbk
		ON h.HubID = hbk.HubID
	INNER JOIN DMOD.HubBusinessKeyField hbkf 
		ON hbk.HubBusinessKeyID = hbkf.HubBusinessKeyID
	INNER JOIN DC.vw_rpt_DatabaseFieldDetail hubbkfielddetail 
		ON hubbkfielddetail.FieldID = hbkf.FieldID
	LEFT JOIN DC.[System] Hubsys 
		ON Hubsys.SystemID = hubbkfielddetail.SystemID
	INNER JOIN DMOD.Satellite s 
		ON s.HubID = h.HubID
	INNER JOIN DMOD.SatelliteDataVelocityType satvel 
		ON satvel.SatelliteDataVelocityTypeID = s.SatelliteDataVelocityTypeID
	INNER JOIN DMOD.SatelliteField satf 
		ON satf.SatelliteID = s.SatelliteID
	INNER JOIN DC.vw_rpt_DatabaseFieldDetail satfielddetail 
		ON satfielddetail.FieldID = satf.FieldID
	LEFT JOIN DC.[System] Satsys 
		ON Satsys.SystemID = satfielddetail.SystemID  

WHERE h.HubID = @HubID
	AND Satsys.SystemID = Hubsys.SystemID
	AND satf.IsActive = 1

--====================================================================================================
--	Insert the Target Schema in DC (if it does not exist) - the SAT db schema is equal to the source system abbreviation,
--	accoarding to the naming convention
--====================================================================================================

-- Check if the schema already exists in the DC
SET @TargetSchemaID =	(
							SELECT	TOP 1 sc.SchemaID
							FROM	DC.[Schema] sc
							WHERE	DatabaseID = @TargetSATDatabaseID
								AND SchemaName = @TargetSchemaName
						 )
-- If the schema does not exists, create it in the DC.Schema table
IF @TargetSchemaID IS NULL 
	BEGIN
		INSERT INTO DC.[Schema] 
			(
				SchemaName
				, DatabaseID
				, DBSchemaID
				, CreatedDT
			)
		SELECT	@TargetSchemaName
				, @TargetSATDatabaseID
				, NULL
				, GETDATE()

		-- Get newly inserted SchemaID
		SET @TargetSchemaID = @@IDENTITY
	END

--====================================================================================================
--	Copy the structure of the Source Data Entity into DataEntity table in DC (if it does not exist)
--
--	Correct fields?  
--		Add IsActive field
--====================================================================================================

-- Check if the Data Entity for the Satellites exists, otherwise insert		
INSERT INTO DC.DataEntity
	(
		  DataEntityName
		, SchemaID
		, CreatedDT
	)
SELECT	DISTINCT  SatelliteName
				, @TargetSchemaID
				, GETDATE()
FROM	#SatDataEntity sat
	left JOIN DC.DataEntity de ON sat.SatelliteName = de.DataEntityName
		and de.SchemaID = @TargetSchemaID
where	de.DataEntityID is null


--FG: Removed the where not exists because it was not working, could not figure out at the time why not - replaced it with a left join IS NULL
--WHERE NOT EXISTS
--	(
--		SELECT	*
--		FROM	#SatDataEntity sat
--			INNER JOIN DC.DataEntity de ON
--				sat.SatelliteName = de.DataEntityName
--					AND de.SchemaID = 24 --@TargetSchemaID
--	)

----====================================================================================================
----	Copy the structure of the Source Data Entity into Fields table in DC (if it does not exist) and
----	insert the additional SAT Fields (if it does not exist) 
----====================================================================================================
UPDATE	sat
SET		SatelliteDataEntityID = de.DataEntityID,
		SatelliteDataEntityName = de.DataEntityName
FROM	#SatDataEntity sat
	INNER JOIN DC.DataEntity de ON sat.SatelliteName = de.DataEntityName
		AND de.SchemaID = @TargetSchemaID

--DECLARE @InitialSourceDataEntityName varchar(100) = (SELECT TOP 1 HubBKDataEntityHKName FROM #SatDataEntity)

DROP TABLE IF EXISTS #Fields

CREATE TABLE #Fields
	(
		[SatFieldID] [int] NULL,
		[FieldOriginalID] [int] NULL,
		[FieldName] [varchar](1000) NULL,
		[DataType] [varchar](500) NULL,
		[MaxLength] [int] NULL,
		[Precision] [int] NULL,
		[Scale] [int] NULL,
		[DataEntityID] [int] NULL,
		[CreatedDT] [datetime2](7) NULL,
		[IsActive] [bit] NULL,
		[FieldSortOrder] [int] NULL
	)

INSERT INTO #Fields

SELECT DISTINCT NULL
	  ,(select top 1 HubBKFieldID from #SatDataEntity satf where satf.SatelliteName = sat.SatelliteName)
	  ,HubBKDataEntityHKName
	  ,'varchar'
	  ,40
	  ,0
	  ,0
	  ,SatelliteDataEntityID
	  ,GETDATE()
	  ,1
	  ,1
FROM #SatDataEntity sat

UNION ALL

SELECT DISTINCT NULL
	  ,NULL
	  ,'LoadDT'
	  ,'datetime2'
	  ,8
	  ,27
	  ,7
	  ,SatelliteDataEntityID
	  ,GETDATE()
	  ,1
	  ,2
FROM #SatDataEntity

UNION ALL

SELECT DISTINCT NULL
	  ,NULL
	  ,'LoadEndDT'
	  ,'datetime2'
	  ,8
	  ,27
	  ,7
	  ,SatelliteDataEntityID
	  ,GETDATE()
	  ,1
	  ,3
FROM #SatDataEntity

UNION ALL

SELECT DISTINCT NULL
	  ,NULL
	  ,'RecSrcDataEntityID'
	  ,'int'
	  ,4
	  ,0
	  ,0
	  ,SatelliteDataEntityID
	  ,GETDATE()
	  ,1
	  ,4
FROM #SatDataEntity

UNION ALL

SELECT DISTINCT NULL
	  ,NULL
	  ,'HashDiff'
	  ,'varchar'
	  ,40
	  ,0
	  ,0
	  ,SatelliteDataEntityID
	  ,GETDATE()
	  ,1
	  ,5
FROM #SatDataEntity

UNION ALL

SELECT	DISTINCT
		NULL
		,sat.SatFieldID
		,SatFieldName
		,SatFieldDataType
		,SatFieldMaxLength
		,SatFieldPrecision
		,SatFieldScale
		,SatelliteDataEntityID
		,GETDATE()
		,1
		,SatFieldFieldSortOrder +1000
FROM #SatDataEntity sat
order by 11


INSERT INTO [DC].[Field] 
	(
		[FieldName]
		,[DataType]
		,[MAXLENGTH]
		,[Precision]
		,[Scale]
		,[DataEntityID]
		,[CreatedDT]
		,[IsActive]
		,[FieldSortOrder] 
	)
select DISTINCT	[FieldName] 
		, [DataType] 
		, [MaxLength]
		, [Precision]
		, [Scale] 
		, [DataEntityID] 
		, [CreatedDT] 
		, [IsActive] 
		, ROW_NUMBER() OVER (PARTITION BY f.DataEntityID order by [FieldSortOrder]) as FieldSortOrder
from	#Fields f
WHERE NOT EXISTS (
					SELECT	1
					FROM	DC.FIELD f1
					WHERE	f1.FieldName = f.FieldName
						AND f.DataEntityID = f1.DataEntityID		  
				  )
ORDER BY [DataEntityID] , FieldSortOrder

-- Get the new field id of the satallite fields (the descriptive information fields)
-- This does not get the DataVault added fields FieldID's (HK, LoadDT, LoadEndDT, RecSrcDataEntityID, HashDiff)
update	#Fields
set		SatFieldID = f.FieldID
from	DC.Field f
	inner join #Fields satf on f.DataEntityID = satf.DataEntityID
		and f.FieldName = satf.FieldName
	inner join #SatDataEntity sde on sde.SatelliteDataEntityID = f.DataEntityID

--====================================================================================================================================================================================
--Field Relations
--====================================================================================================================================================================================
--/*
INSERT INTO DC.FieldRelation
	(
		SourceFieldID
		,TargetFieldID
		,FieldRelationTypeID
		,CreatedDT
	)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SAT attribute field mapping
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select	DISTINCT 
		[DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID_SAT_ForOneToOne] (f.FieldOriginalID, sat1.SatelliteDataVelocityTypeID) AS SourceFieldID
		, f.SatFieldID AS TargetFieldID
		, 2 AS FieldRelationType -- STT Mapping type hard coded
		,GETDATE()
from	#Fields f
	INNER JOIN (SELECT DISTINCT sat.SatelliteDataEntityID,sat.SatelliteDataVelocityTypeID FROM #SatDataEntity sat) sat1 
		ON sat1.SatelliteDataEntityID = f.DataEntityID
	INNER JOIN  (
					SELECT	DataEntityID,FieldName,SatFieldID
					FROM	#Fields
					WHERE	FieldName = 'HashDiff'
				) hdiff
		ON hdiff.DataEntityID = sat1.SatelliteDataEntityID
WHERE	f.FieldOriginalID IS NOT NULL
	AND	f.FieldName not like 'HK_%'
	AND NOT EXISTS	(
						SELECT	1 
						FROM	DC.FieldRelation fr
						WHERE	fr.SourceFieldID = [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID_SAT_ForOneToOne] (f.FieldOriginalID, sat1.SatelliteDataVelocityTypeID)
							AND fr.TargetFieldID = f.SatFieldID
							AND fr.FieldRelationTypeID  = 2
					  )

UNION ALL
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Hashdiff mapping
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select	
		DISTINCT [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID_SAT_ForHashDiff] (hdiff.FieldOriginalID, sat1.SatelliteDataVelocityTypeID) AS SourceFieldID
		, f.SatFieldID AS TargetFieldID
		, 2 AS FieldRelationType -- STT Mapping type hard coded
		,GETDATE()
from	#Fields f
	INNER JOIN (SELECT DISTINCT sat.SatelliteDataEntityID,sat.SatelliteDataVelocityTypeID FROM #SatDataEntity sat) sat1	
		ON sat1.SatelliteDataEntityID = f.DataEntityID
	INNER JOIN (
					SELECT	DataEntityID,FieldName,FieldOriginalID
					FROM	#Fields
					WHERE	FieldName NOT LIKE 'HashDiff' 
						AND FieldName NOT LIKE 'HK_%'
						AND FieldOriginalID IS NOT NULL
				) hdiff
		ON hdiff.DataEntityID = sat1.SatelliteDataEntityID
WHERE	f.FieldOriginalID IS NULL
	AND f.FieldName  like 'HashDiff%'
	AND NOT EXISTS	(
						SELECT	1 
						FROM	DC.FieldRelation fr
						WHERE	fr.SourceFieldID = [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID_SAT_ForHashDiff] (hdiff.FieldOriginalID, sat1.SatelliteDataVelocityTypeID)
							AND fr.TargetFieldID = f.SatFieldID
							AND fr.FieldRelationTypeID  = 2
					  )
UNION ALL

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Hash key mapping
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select	
		DISTINCT [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID_SAT_ForBKHash] (f.FieldOriginalID, sat1.SatelliteDataVelocityTypeID) AS SourceFieldID
		, f.SatFieldID AS TargetFieldID
		, 2 AS FieldRelationType -- STT Mapping type hard coded
		,GETDATE()
from	#Fields f
INNER JOIN (SELECT DISTINCT sat.SatelliteDataEntityID,sat.SatelliteDataVelocityTypeID FROM #SatDataEntity sat) sat1 
	ON sat1.SatelliteDataEntityID = f.DataEntityID
INNER JOIN (
				SELECT	DataEntityID,FieldName,FieldOriginalID
				FROM	#Fields
				WHERE	FieldName NOT LIKE 'HashDiff' 
					AND FieldName NOT LIKE 'HK_%'
					AND FieldOriginalID IS NOT NULL
		   ) hdiff
	ON hdiff.DataEntityID = sat1.SatelliteDataEntityID
WHERE	f.FieldName  like 'HK_%'
	AND NOT EXISTS	(
						SELECT	1 
						FROM	DC.FieldRelation fr
						WHERE	fr.SourceFieldID = [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID_SAT_ForBKHash] (f.FieldOriginalID, sat1.SatelliteDataVelocityTypeID)
							AND fr.TargetFieldID = f.SatFieldID
							AND fr.FieldRelationTypeID  = 2
					  )


----SELECT	[DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID](sat_hashsource.FieldOriginalID,sat_hashsource.SatelliteFieldDataVelocityTypeID) AS SourceFieldID
----		, sat_hashsource.SatFieldID AS TargetFieldID
----		, 2 AS FieldRelationType -- STT Mapping type hard coded
----		,GETDATE()
----FROM	
----		   (SELECT	*
----			FROM	@Fields f
----			inner join #SatDataEntity sat ON
----			sat.SatDataEntityID = f.DataEntityID

----			WHERE	FieldOriginalID <> 0
----		     ) sat_hashsource 
----WHERE NOT EXISTS(SELECT 1 
----				 FROM DC.FieldRelation fr
----				 WHERE fr.SourceFieldID = [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID](sat_hashsource.FieldOriginalID,sat_hashsource.SatelliteFieldDataVelocityTypeID)
----				 AND fr.TargetFieldID = sat_hashsource.SatFieldID
----				 AND fr.FieldRelationTypeID  = 2
----				 )

----union all


------ Generate the STT mapping for the HK columns for each DataEntityID
----select	[DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID] (hub.SourceFieldID, sat.SatelliteFieldDataVelocityTypeID) as SourceFieldID
----		, field.SatFieldID as TargetFieldID
----		, 2 AS FieldRelationType -- STT Mapping type hard coded
----		,GETDATE()
----from	#SatDataEntity sat
----	inner join [DMOD].[HubBusinessKey_Working] hub on sat.HubID = hub.HubID
----	inner join @Fields field on field.DataEntityID = sat.SatDataEntityID
----WHERE  NOT EXISTS(SELECT 1 
----				 FROM DC.FieldRelation fr
----				 WHERE fr.SourceFieldID = [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID] (hub.SourceFieldID, sat.SatelliteFieldDataVelocityTypeID)
----				 AND fr.TargetFieldID = field.SatFieldID
----				 AND fr.FieldRelationTypeID  = 2
----				 )
----AND	FieldName like 'HK%'

--*/

GO
