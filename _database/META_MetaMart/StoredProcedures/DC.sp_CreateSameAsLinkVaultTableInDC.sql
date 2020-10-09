SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- ====================================================================================================
-- Author:      Francois Senekal
-- Create Date: 6 February 2019
-- Description: Creates SAL tables and CLSAT in DC and auto-creates relationships to Source/SAL
-- ==============================================================

CREATE PROCEDURE [DC].[sp_CreateSameAsLinkVaultTableInDC] 
@HubID int,
@TargetDatabaseID int
AS
/*--====================================================================================================
Test Case 1:

--====================================================================================================*/

--====================================================================================================
--TempTable CreatedHere for SAL
--====================================================================================================
--DECLARE @HubID INT
--SET @HubID = 1035
--DECLARE @TargetDatabaseID int = 8


DECLARE @TargetSchemaName varchar (100) = 'raw'
DROP TABLE IF EXISTS #SalDataEntity
CREATE TABLE #SalDataEntity
						(LinkName varchar(100)
						,SourceName varchar(100)
						,MasterSchemaName varchar(100)
						,MasterFieldID int
						,SlaveFieldID int
						,TargetDataEntityID INT
						
						)
INSERT INTO #SalDataEntity
select SameAsLinkName 
	  ,REPLACE(SameAsLinkName,'SAL_','')  AS SourceName
	  ,masterfield.SchemaName
	  ,MasterFieldID
	  ,SlaveFieldID 
	  ,NULL
FROM DMOD.SameAsLink sal 
INNER JOIN DMOD.SameAsLinkField salf ON
salf.SameAsLinkID = sal.SameAsLinkID
INNER JOIN DC.vw_rpt_DatabaseFieldDetail masterfield ON
masterfield.FieldID = salf.MasterFieldID
WHERE HubID = @HubID
--====================================================================================================
--TempTable CreatedHere for CLSAL
--====================================================================================================

--DECLARE @CLSATTemp TABLE
--						(SourceDataEntityID INT
--						,InitialSourceDataEntityName VARCHAR(100)
--						,DataEntityName VARCHAR(100)
--						,HubID INT
--						,HubName VARCHAR(100)
--						,SourceFieldID INT
--						,FieldName VARCHAR(100)
--						,SameAsLinkID INT
--						,SameAsLinkName VARCHAR(100)
--						,SchemaID INT
--						,SchemaName VARCHAR(100)
--						,DBObjectID INT
--						,SATDataEntityID INT
--						,SATDataEntityName VARCHAR(100)
--						)
--INSERT INTO @CLSATTemp
--SELECT  hw.SourceDataEntityID
--	   ,RIGHT(SameAsLinkName, LEN(SameAsLinkName) - 4) AS InitialSourceDataEntityName
--	   ,de.DataEntityName
--	   ,hw.HubID
--	   ,HubName
--	   ,SourceFieldID
--	   ,FieldName
--	   ,SameAsLinkID
--	   ,SameAsLinkName
--	   ,s.SchemaID
--	   ,s.SchemaName
--	   ,DBObjectID	
--	   ,NULL
--	   ,'CLSAT_'+RIGHT(SameAsLinkName, LEN(SameAsLinkName) - 4) AS SateliteDataEntityName	
--FROM dmod.hub_working hw
--INNER JOIN DMOD.HubBusinessKey_Working hbw ON	
--	hbw.HubID = hw.HubID
--INNER JOIN DMOD.SameAsLink_Working salw ON
--	salw.HubID = hw.HubID
--INNER JOIN DC.DataEntity de ON
--	de.DataEntityID = hw.SourceDataEntityID
--INNER JOIN DC.Field f ON
--	f.DataEntityID = de.DataEntityID
--INNER JOIN DC.[Schema] s ON
--	s.Schemaid = de.SchemaID
--WHERE HW.HubID = @HubID

--====================================================================================================
--	Insert the Target Schema in DC (if it does not exist) - the M2MLink db schema is equal to the source system abbreviation,
--	accoarding to the naming convention
--====================================================================================================
DECLARE @TargetSchemaID int
SET @TargetSchemaID =
						(
						SELECT	TOP 1 sc.SchemaID
						FROM	DC.[Schema] sc
						WHERE	DatabaseID = @TargetDatabaseID
							and SchemaName = @TargetSchemaName
						)

if @TargetSchemaID IS NULL 
	INSERT INTO DC.[Schema] 
	(SchemaName
	,DatabaseID
	,DBSchemaID
	,CreatedDT
	)
	(SELECT @TargetSchemaName
		   ,@TargetDatabaseID
		   ,NULL
		   ,GETDATE()
	)
if @TargetSchemaID IS NULL
set @TargetSchemaID = @@IDENTITY

--====================================================================================================
--	Copy the structure of the Source Data Entity into DataEntity table in DC (if it does not exist)
--
--	Correct fields?  
--		Add IsActive field
--====================================================================================================
		
INSERT INTO DC.DataEntity
(DataEntityName
,SchemaID
,CreatedDT
)
SELECT DISTINCT  'SALink_'+ SourceName  
				,@TargetSchemaID
				,GETDATE()
FROM	#SalDataEntity
WHERE NOT EXISTS
	 (SELECT 1
	  FROM	#SalDataEntity salt
	  INNER JOIN DC.DataEntity de ON
	  'SALink_'+ salt.SourceName = de.DataEntityName
		 AND de.SchemaID = @TargetSchemaID
	  )
----Create DataEntity for the CLSAT
--INSERT INTO DC.DataEntity
--(DataEntityName
--,SchemaID
--,CreatedDT
--)
--SELECT DISTINCT  SATDataEntityName
--				,@TargetSchemaID
--				,GETDATE()
--FROM	@CLSATTemp
--WHERE NOT EXISTS
--	 (SELECT 1
--	  FROM	@CLSATTemp cls
--	  INNER JOIN DC.DataEntity de ON
--	  cls.SATDataEntityName = de.DataEntityName
--		 AND de.SchemaID = @TargetSchemaID
--	  )


--====================================================================================================
--	Updates DataEntityID
--====================================================================================================
UPDATE	salt
SET		TargetDataEntityID = de.DataEntityID
FROM	#SalDataEntity salt
INNER JOIN DC.DataEntity de ON 'SALink_'+ salt.SourceName = de.DataEntityName
	AND de.SchemaID = @TargetSchemaID
----Update DataEntity for the CLSAT
--UPDATE	cls
--SET		SATDataEntityID = de.DataEntityID
--FROM	@CLSATTemp cls
--INNER JOIN DC.DataEntity de ON cls.SATDataEntityName = de.DataEntityName
--	AND de.SchemaID = @TargetSchemaID
--DECLARE @StageDEID INT = (SELECT DISTINCT TargetDataEntityID FROM @SALTemp)
--DECLARE @StageDEIDCL INT = (SELECT DISTINCT SATDataEntityID FROM @CLSATTemp)

--====================================================================================================
--Inserts HK LoadDT Resource fields
--====================================================================================================
DECLARE @TargetDataEntityID int = (SELECT DISTINCT TargetDataEntityID FROM #SalDataEntity)
DROP TABLE IF EXISTS #Fields
CREATE TABLE #Fields
		(SALStageFieldID int,
		 [FieldName] [varchar](1000) NOT NULL,
		 [DataType] [varchar](500) NULL,
		 [MaxLength] [int] NULL,
		 [Precision] [int] NULL,
		 [Scale] [int] NULL,
		 [DataEntityID] [int] NULL,
		 [CreatedDT] [datetime2](7) NULL,
		 [FieldSortOrder] [int] NULL,
		 [IsActive] [bit] NULL
		 )
DECLARE @InitialSourceDataEntityName VARCHAR(100) = (SELECT DISTINCT SourceName FROM #SalDataEntity)
	INSERT #Fields VALUES
		  (NULL,'SALHK_'+@InitialSourceDataEntityName,'varchar',40,0,0,@TargetDataEntityID, GETDATE(), 1, 1),
		  (NULL,'LoadDT','datetime2',8,27,7,@TargetDataEntityID, GETDATE(), 2, 1),
		  (NULL,'RecSrcDataEntityID','int',4,0,0,@TargetDataEntityID, GETDATE(), 3, 1),
		  (NULL,'HK_Master_'+@InitialSourceDataEntityName,'varchar',40,0,0,@TargetDataEntityID, GETDATE(), 4, 1),
		  (NULL,'HK_Slave_'+@InitialSourceDataEntityName,'varchar',40,0,0,@TargetDataEntityID, GETDATE(), 5, 1)

INSERT INTO [DC].[Field] 
	   ([FieldName],[DataType],[MAXLENGTH],[Precision],[Scale],[DataEntityID],[CreatedDT],[IsActive],[FieldSortOrder] )

SELECT	   f.FieldName
		  ,f.DataType
		  ,f.[MAXLENGTH]
		  ,f.[Precision]
		  ,f.[Scale]
		  ,f.[DataEntityID]
		  ,GETDATE()
		  ,1
		  ,f.[FieldSortOrder]		
FROM #Fields f
WHERE NOT EXISTS (SELECT 1
				  FROM DC.FIELD f1
				  WHERE f1.FieldName = f.FieldName
					AND f.DataEntityID = f1.DataEntityID		  
				  )
UPDATE f
SET SALStageFieldID = f1.FieldID
FROM #Fields f 
INNER JOIN DC.Field f1 ON
f1.DataEntityID = @TargetDataEntityID AND
f.FieldName = f1.FieldName

----Update Fields for the CLSAT
--DECLARE @FieldsCL TABLE
--		([FieldName] [varchar](1000) NOT NULL,
--		 [DataType] [varchar](500) NULL,
--		 [MaxLength] [int] NULL,
--		 [Precision] [int] NULL,
--		 [Scale] [int] NULL,
--		 [DataEntityID] [int] NULL,
--		 [CreatedDT] [datetime2](7) NULL,
--		 [FieldSortOrder] [int] NULL,
--		 [IsActive] [bit] NULL
--		 )
--DECLARE @InitialSourceDataEntityNameCL VARCHAR(100) = (SELECT DISTINCT InitialSourceDataEntityName FROM @CLSATTemp)
--	INSERT @FieldsCL VALUES
--		  ('HK_'+@InitialSourceDataEntityName,'varchar',40,0,0,-1, GETDATE(), 1, 1),
--		  ('LoadDT','datetime2',8,27,7,-1, GETDATE(), 2, 1),
--		  ('LoadEndDT','datetime2',8,27,7,-1, GETDATE(), 3, 1),
--		  ('RecSrcDataEntityID','int',4,0,0,-1, GETDATE(), 4, 1),
--		  ('ConfidenceLevel','decimal',38,6,3,-1, GETDATE(), 5, 1)


--DECLARE @TargetDEIDCL int
--SET @TargetDEIDCL = (Select distinct SATDataEntityID from @CLSATTemp)
--INSERT INTO [DC].[Field] 
--	   ([FieldName],[DataType],[MAXLENGTH],[Precision],[Scale],[DataEntityID],[CreatedDT],[IsActive],[FieldSortOrder] )

--SELECT	   f.FieldName
--		  ,f.DataType
--		  ,f.[MAXLENGTH]
--		  ,f.[Precision]
--		  ,f.[Scale]
--		  ,@TargetDEIDCL
--		  ,GETDATE()
--		  ,[IsActive]
--		  ,f.[FieldSortOrder]		
--FROM @FieldsCL f
--WHERE NOT EXISTS (SELECT 1
--				  FROM DC.FIELD f1
--				  WHERE f1.FieldName = f.FieldName
--					AND @TargetDEIDCL = f1.DataEntityID		  
--				  )



	

------====================================================================================================
------	Insert the entries into the DC.FieldRelation table (type = 2) for the Data Entity
------====================================================================================================

DROP TABLE IF EXISTS #FieldRelation
CREATE TABLE #FieldRelation
	([SourceFieldID] int,
		[TargetFieldID] int, 
		[FieldRelationTypeID] int,
		[CreatedDT] datetime2(7),
		[IsActive] int
		)
INSERT INTO #FieldRelation
SELECT [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID_SAL_BKHash](sal.MasterFieldID)
	  ,f.SALStageFieldID 
	  ,2
	  ,GETDATE()
	  ,1
FROM #Fields f
INNER JOIN #SalDataEntity sal
ON f.DataEntityID = sal.TargetDataEntityID
WHERE f.FieldName like 'SALHK_%'


INSERT INTO #FieldRelation
SELECT [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID_SAL_HKMaster](sal.MasterFieldID)
	  ,f.SALStageFieldID 
	  ,2
	  ,GETDATE()
	  ,1
FROM #Fields f
INNER JOIN #SalDataEntity sal
ON f.DataEntityID = sal.TargetDataEntityID
WHERE f.FieldName like 'HK_Master_%'

INSERT INTO #FieldRelation
SELECT [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID_SAL_HKSlave](sal.MasterFieldID) 
	  ,f.SALStageFieldID 
	  ,2
	  ,GETDATE()
	  ,1
FROM #Fields f
INNER JOIN #SalDataEntity sal
ON f.DataEntityID = sal.TargetDataEntityID
WHERE f.FieldName like 'HK_Slave_%' 

INSERT INTO DC.FieldRelation 
([SourceFieldID] ,
 [TargetFieldID] , 
 [FieldRelationTypeID] ,
 [CreatedDT] ,
 [IsActive] 
		)
SELECT 
 [SourceFieldID] ,
 [TargetFieldID] , 
 [FieldRelationTypeID] ,
 [CreatedDT] ,
 [IsActive] 
		
FROM #FieldRelation fr
WHERE NOT EXISTS (SELECT 1
				  FROM DC.FieldRelation fr1
				  WHERE SourceFieldID = fr.SourceFieldID
				  AND TargetFieldID = fr.TargetFieldID
				  AND FieldRelationTypeID = 2)

GO
