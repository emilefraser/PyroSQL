SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[StageTableTestFrancois]
AS
--====================================================================================================
--	All Variables Declared Here
--====================================================================================================

DECLARE	@HubID INT
SET		@HubID = 2

DECLARE @TargetStageDatabaseID INT
SET		@TargetStageDatabaseID = 12

DECLARE @InitialSourceDataEntityID INT
SET		@InitialSourceDataEntityID = (	
										SELECT	SourceDataEntityID 
										FROM	[DMOD].[Hub_Working] 
										WHERE	HubID = @HubID
									 )

DECLARE @InitialSourceDataEntityName VARCHAR(50)
SET		@InitialSourceDataEntityName =	(
											SELECT	[DC].[udf_ConvertStringToCamelCase](DataEntityName) 
											FROM	dc.dataentity 
											WHERE	DataEntityID = @InitialSourceDataEntityID
										)
DECLARE @TargetSchemaID INT
DECLARE @TargetSchemaName VARCHAR(20)
SET @TargetSchemaName = 'XT'

/*******************************************************************************************
LVD
*******************************************************************************************/
DECLARE @LVDTemp TABLE
(SatelliteFieldDataVelocityID INT
,HubID INT 
,HubName VARCHAR(100)
,SourceSystemDataEntityID INT 
,SourceSystemDataEntityName VARCHAR(100)
,HubBKFieldID INT
,HubBKFieldName VARCHAR(100)
,BKSourceFieldID INT
,BKSourceFieldName VARCHAR(100)
,BKFriendlyName VARCHAR(100)
,VelocityFieldID INT
,VelocityFieldName VARCHAR(100)
,VelocityDataType VARCHAR(500)
,VelocityMaxLength INT 
,VelocityPrecision INT
,VelocityScale INT
,VelocityCreatedDt DATETIME2(7)
,VelocityFieldSortOrder INT
,VelocityIsActive INT
,VelocityType VARCHAR(100)
,TargetDataEntityID INT
,TargetDataEntityName VARCHAR(100)
)
INSERT INTO @LVDTemp
SELECT sfw.SatelliteFieldDataVelocityID
	  ,sfw.HubID
	  ,hw.HubName
	  ,hw.SourceDataEntityID
	  ,de.DataEntityName
	  ,hkw.HubBKFieldID
	  ,f2.FieldName
	  ,hkw.SourceFieldID
	  ,f.FieldName
	  ,hkw.BKFriendlyName
	  ,sfw.FieldID
	  ,f1.FieldName
	  ,f1.DataType
	  ,f1.MaxLength
	  ,f1.Precision
	  ,f1.Scale
	  ,GETDATE()
	  ,f1.FieldSortOrder + 4
	  ,1
	  ,svt.SatelliteFieldDataVelocityTypeCode
	  ,NULL
	  ,CONCAT(@TargetSchemaName,'.dbo_',de.DataEntityName,'_LVD')
FROM DMOD.SatelliteFieldDataVelocity_Working sfw
INNER JOIN DMOD.SatelliteFieldDataVelocityType svt ON
sfw.SatelliteFieldDataVelocityTypeID = svt.SatelliteFieldDataVelocityTypeID
INNER JOIN DMOD.Hub_Working hw ON
hw.HubID = sfw.HubID
INNER JOIN DMOD.HubBusinessKey_Working hkw ON
hkw.HubID = sfw.HubID
INNER JOIN DC.DataEntity de ON
de.DataEntityID = SourceDataEntityID
INNER JOIN DC.Field f ON
f.FieldID = SourceFieldID
INNER JOIN DC.Field f1 ON
f1.FieldID = sfw.FieldID
INNER JOIN DC.Field f2 ON
f2.FieldID = HubBKFieldID
WHERE sfw.HubID IS NOT NULL
AND svt.SatelliteFieldDataVelocityTypeID = 1 --(1:LVD , 2:MVD , 3:HVD)
AND sfw.HubID = @HubID --Department HUB

DECLARE @SourceDataEntityName VARCHAR(100) = (SELECT DISTINCT SourceSystemDataEntityName FROM @LVDTemp)
--====================================================================================================
--	Insert the Target Schema in DC (if it does not exist) - the LVD db schema is equal to the source system abbreviation,
--	accoarding to the naming convention
--====================================================================================================

-- Check if the schema already exists in the DC
SET @TargetSchemaID =	(
							SELECT	TOP 1 sc.SchemaID
							FROM	DC.[Schema] sc
							WHERE	DatabaseID = @TargetStageDatabaseID
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
				, @TargetStageDatabaseID
				, NULL
				, GETDATE()

		-- Get newly inserted SchemaID
		SET @TargetSchemaID = @@IDENTITY
	END
--====================================================================================================
--	Copy the structure of the Source Data Entity into DataEntity table in DC (if it does not exist)
--====================================================================================================
-- Check if the Data Entity for the Stage LVD exists, otherwise insert		
INSERT INTO DC.DataEntity
	(
		DataEntityName
		, SchemaID
		, CreatedDT
	)
SELECT	DISTINCT TargetDataEntityName
		, @TargetSchemaID
		, GETDATE()
FROM	@LVDTemp
WHERE NOT EXISTS
	(
		SELECT	1
		FROM	@LVDTemp lvd
			INNER JOIN DC.DataEntity de ON
				lvd.TargetDataEntityName = de.DataEntityName
					AND de.SchemaID = @TargetSchemaID
	)

--====================================================================================================
--	Copy the structure of the Source Data Entity into Fields table in DC (if it does not exist) and
--	insert the additional SAT Fields (if it does not exist) 
--====================================================================================================
UPDATE	@LVDTemp
SET		TargetDataEntityID = de.DataEntityID
FROM	@LVDTemp lvd
	INNER JOIN DC.DataEntity de ON lvd.TargetDataEntityName = de.DataEntityName
		AND de.SchemaID = @TargetSchemaID

DECLARE @NewDataEntityID INT = (SELECT DISTINCT TargetDataEntityID FROM @LVDTemp)
DECLARE @HubFields TABLE (FieldName VARCHAR(1000)
					     ,DataType VARCHAR(500)
						 ,[MAXLENGTH] INT 
						 ,[Precision] INT
						 ,[Scale] INT
						 ,DataEntityID INT
						 ,CreatedDt DATETIME2(7)
						 ,FieldSortOrder INT
						 ,IsActive INT
						 )
INSERT @HubFields VALUES
	('HK_'+@SourceDataEntityName,'varchar',40,0,0,@NewDataEntityID, GETDATE(), 1, 1),
	('LoadDT','datetime2',8,27,7,@NewDataEntityID, GETDATE(), 2, 1),
	('RecSrcDataEntityID','int',4,0,0,@NewDataEntityID, GETDATE(), 3, 1),
	('HashDiff_LVD','varchar',40,0,0,@NewDataEntityID, GETDATE(), 4, 1)

INSERT INTO [DC].[Field]
			([FieldName]
			,[DataType]
			,[MAXLENGTH]
			,[Precision]
			,[Scale]
			,[DataEntityID]
			,[CreatedDT]
			,[IsActive]
			,[FieldSortOrder] 
			 )
SELECT FieldName
	  ,DataType
	  ,[MAXLENGTH]
	  ,[Precision] 
	  ,[Scale]
	  ,@NewDataEntityID
	  ,GETDATE()
	  ,1
	  ,FieldSortOrder
FROM  @HUBFields
WHERE FieldName NOT IN 
	  (SELECT FieldName 
	   FROM [DC].[Field]
	   WHERE DataEntityID = @NewDataEntityID
	   )
INSERT INTO [DC].[Field]
			([FieldName]
			,[DataType]
			,[MAXLENGTH]
			,[Precision]
			,[Scale]
			,[DataEntityID]
			,[CreatedDT]
			,[IsActive]
			,[FieldSortOrder] 
			 )
SELECT VelocityFieldName
	  ,VelocityDataType
	  ,VelocityMaxLength
	  ,VelocityPrecision
	  ,VelocityScale
	  ,@NewDataEntityID
	  ,GETDATE()
	  ,VelocityIsActive
	  ,VelocityFieldSortOrder
FROM @LVDTemp
WHERE VelocityFieldName NOT IN
								(SELECT FieldName 
								 FROM [DC].[Field]
								 WHERE DataEntityID = @NewDataEntityID
								 )




--/*******************************************************************************************
--MVD
--*******************************************************************************************/
DECLARE @MVDTemp TABLE
(SatelliteFieldDataVelocityID INT
,HubID INT 
,HubName VARCHAR(100)
,SourceSystemDataEntityID INT 
,SourceSystemDataEntityName VARCHAR(100)
,HubBKFieldID INT
,HubBKFieldName VARCHAR(100)
,BKSourceFieldID INT
,BKSourceFieldName VARCHAR(100)
,BKFriendlyName VARCHAR(100)
,VelocityFieldID INT
,VelocityFieldName VARCHAR(100)
,VelocityDataType VARCHAR(500)
,VelocityMaxLength INT 
,VelocityPrecision INT
,VelocityScale INT
,VelocityCreatedDt DATETIME2(7)
,VelocityFieldSortOrder INT
,VelocityIsActive INT
,VelocityType VARCHAR(100)
,TargetDataEntityID INT
,TargetDataEntityName VARCHAR(100)
)
INSERT INTO @MVDTemp
SELECT sfw.SatelliteFieldDataVelocityID
	  ,sfw.HubID
	  ,hw.HubName
	  ,hw.SourceDataEntityID
	  ,de.DataEntityName
	  ,hkw.HubBKFieldID
	  ,f2.FieldName
	  ,hkw.SourceFieldID
	  ,f.FieldName
	  ,hkw.BKFriendlyName
	  ,sfw.FieldID
	  ,f1.FieldName
	  ,f1.DataType
	  ,f1.MaxLength
	  ,f1.Precision
	  ,f1.Scale
	  ,GETDATE()
	  ,f1.FieldSortOrder + 4
	  ,1
	  ,svt.SatelliteFieldDataVelocityTypeCode
	  ,NULL
	  ,CONCAT(@TargetSchemaName,'.dbo_',de.DataEntityName,'_MVD')
FROM DMOD.SatelliteFieldDataVelocity_Working sfw
INNER JOIN DMOD.SatelliteFieldDataVelocityType svt ON
sfw.SatelliteFieldDataVelocityTypeID = svt.SatelliteFieldDataVelocityTypeID
INNER JOIN DMOD.Hub_Working hw ON
hw.HubID = sfw.HubID
INNER JOIN DMOD.HubBusinessKey_Working hkw ON
hkw.HubID = sfw.HubID
INNER JOIN DC.DataEntity de ON
de.DataEntityID = SourceDataEntityID
INNER JOIN DC.Field f ON
f.FieldID = SourceFieldID
INNER JOIN DC.Field f1 ON
f1.FieldID = sfw.FieldID
INNER JOIN DC.Field f2 ON
f2.FieldID = HubBKFieldID
WHERE sfw.HubID IS NOT NULL
AND svt.SatelliteFieldDataVelocityTypeID = 2 --(1:LVD , 2:MVD , 3:HVD)
AND sfw.HubID = @HubID --Department HUB

DECLARE @SourceDataEntityName1 VARCHAR(100) = (SELECT DISTINCT SourceSystemDataEntityName FROM @MVDTemp)
--====================================================================================================
--	Insert the Target Schema in DC (if it does not exist) - the LVD db schema is equal to the source system abbreviation,
--	accoarding to the naming convention
--====================================================================================================

-- Check if the schema already exists in the DC
SET @TargetSchemaID =	(
							SELECT	TOP 1 sc.SchemaID
							FROM	DC.[Schema] sc
							WHERE	DatabaseID = @TargetStageDatabaseID
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
				, @TargetStageDatabaseID
				, NULL
				, GETDATE()

		-- Get newly inserted SchemaID
		SET @TargetSchemaID = @@IDENTITY
	END
--====================================================================================================
--	Copy the structure of the Source Data Entity into DataEntity table in DC (if it does not exist)
--====================================================================================================
-- Check if the Data Entity for the Stage LVD exists, otherwise insert		
INSERT INTO DC.DataEntity
	(
		DataEntityName
		, SchemaID
		, CreatedDT
	)
SELECT	DISTINCT TargetDataEntityName
		, @TargetSchemaID
		, GETDATE()
FROM	@MVDTemp
WHERE NOT EXISTS
	(
		SELECT	1
		FROM	@MVDTemp mvd
			INNER JOIN DC.DataEntity de ON
				mvd.TargetDataEntityName = de.DataEntityName
					AND de.SchemaID = @TargetSchemaID
	)

--====================================================================================================
--	Copy the structure of the Source Data Entity into Fields table in DC (if it does not exist) and
--	insert the additional SAT Fields (if it does not exist) 
--====================================================================================================
UPDATE	@MVDTemp
SET		TargetDataEntityID = de.DataEntityID
FROM	@MVDTemp lvd
	INNER JOIN DC.DataEntity de ON lvd.TargetDataEntityName = de.DataEntityName
		AND de.SchemaID = @TargetSchemaID

DECLARE @NewDataEntityID1 INT = (SELECT DISTINCT TargetDataEntityID FROM @MVDTemp)
DECLARE @HubFields1 TABLE (FieldName VARCHAR(1000)
					     ,DataType VARCHAR(500)
						 ,[MAXLENGTH] INT 
						 ,[Precision] INT
						 ,[Scale] INT
						 ,DataEntityID INT
						 ,CreatedDt DATETIME2(7)
						 ,FieldSortOrder INT
						 ,IsActive INT
						 )
INSERT @HubFields1 VALUES
	('HK_'+@SourceDataEntityName1,'varchar',40,0,0,@NewDataEntityID1, GETDATE(), 1, 1),
	('LoadDT','datetime2',8,27,7,@NewDataEntityID1, GETDATE(), 2, 1),
	('RecSrcDataEntityID','int',4,0,0,@NewDataEntityID1, GETDATE(), 3, 1),
	('HashDiff_MVD','varchar',40,0,0,@NewDataEntityID1, GETDATE(), 4, 1)
select @newdataentityid
select @newdataentityid1

INSERT INTO [DC].[Field]
			([FieldName]
			,[DataType]
			,[MAXLENGTH]
			,[Precision]
			,[Scale]
			,[DataEntityID]
			,[CreatedDT]
			,[IsActive]
			,[FieldSortOrder] 
			 )
SELECT FieldName
	  ,DataType
	  ,[MAXLENGTH]
	  ,[Precision] 
	  ,[Scale]
	  ,@NewDataEntityID
	  ,GETDATE()
	  ,1
	  ,FieldSortOrder
FROM  @HUBFields1
WHERE FieldName NOT IN 
	  (SELECT FieldName 
	   FROM [DC].[Field]
	   WHERE DataEntityID = @NewDataEntityID1
	   )
INSERT INTO [DC].[Field]
			([FieldName]
			,[DataType]
			,[MAXLENGTH]
			,[Precision]
			,[Scale]
			,[DataEntityID]
			,[CreatedDT]
			,[IsActive]
			,[FieldSortOrder] 
			 )
SELECT VelocityFieldName
	  ,VelocityDataType
	  ,VelocityMaxLength
	  ,VelocityPrecision
	  ,VelocityScale
	  ,@NewDataEntityID1
	  ,GETDATE()
	  ,VelocityIsActive
	  ,VelocityFieldSortOrder
FROM @MVDTemp
WHERE VelocityFieldName NOT IN
								(SELECT FieldName 
								 FROM [DC].[Field]
								 WHERE DataEntityID = @NewDataEntityID1
								 )




GO
