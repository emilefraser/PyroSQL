SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- ====================================================================================================
-- Author:      Francois Senekal
-- Create Date: 24 January 2019
-- Description: Creates Link tables in DC and auto-creates relationships to Source/Hub
-- ====================================================================================================

CREATE PROCEDURE [DC].[sp_CreateLinkTableInDC]
	
AS
/*====================================================================================================
TEST Case 1: 
1.Check what the variables are
SELECT * FROM [DMOD].[Hub_Working] WHERE HUBID = 2
SELECT * FROM DC.DataEntity WHERE DataEntityID = 68

2.Use a @TargetHUBDatabaseID that does not exist (9999)

3.Run Proc

4.Check if a schema / dataentity / fields WHERE created
TODO = Change the Date to the date the proc ran
SELECT * FROM DC.[Schema] WHERE CreatedDT > '2019/01/31'
SELECT * FROM DC.[DataEntity] WHERE CreatedDT > '2019/01/31'
SELECT * FROM DC.Field WHERE CreatedDT > '2019/01/31'
SELECT * FROM DC.FieldRelation WHERE CreatedDT > '2019/01/31'


5. Delete the temporary schema / dataentity / fields entries. !!!(BE CAREFUL BEFORE YOU RUN DELETE STATEMENTS)!!!

TEST Case 1: 
1.Run the proc with a @TargetHUBDatabaseID that already exists (48)
2.Check if a schema / dataentity / fields was not added
TODO = Change the Date to the date the proc ran
SELECT * FROM DC.[Schema] WHERE CreatedDT > '2019/01/31'
SELECT * FROM DC.[DataEntity] WHERE CreatedDT > '2019/01/31'
SELECT * FROM DC.Field WHERE CreatedDT > '2019/01/31'
SELECT * FROM DC.FieldRelation WHERE CreatedDT > '2019/01/31'

====================================================================================================*/


/*====================================================================================================
Declare all variables here
====================================================================================================*/
DECLARE @HubID INT
SET @HubID = 2
DECLARE @TargetHUBDatabaseID INT
SET @TargetHUBDatabaseID = 9999
DECLARE @InitialSourceDataEntityID INT
SET @InitialSourceDataEntityID = (SELECT SourceDataEntityID FROM [DMOD].[Hub_Working] WHERE HubID =@HubID)
DECLARE @InitialSourceDataEntityName VARCHAR(50)
SET @InitialSourceDataEntityName = (SELECT DataEntityName FROM dc.DataEntity WHERE DataEntityID = @InitialSourceDataEntityID)
DECLARE @HUBName VARCHAR(50)
SET @HUBName = (SELECT HubName FROM [DMOD].[Hub_Working] WHERE hubid = @HubID )
DECLARE @TargetSchemaID INT
DECLARE @TargetSchemaName varchar(20)
--SET @TargetSchemaName = (SELECT schemaname FROM dc.[schema] WHERE databaseid = @TargetHUBDatabaseID)
SET @TargetSchemaName = 'RAW'

	
	
--====================================================================================================
--	Insert the Target Schema in DC (if it does not exist) - the HUB db schema is equal to the source system abbreviation,
--	accoarding to the naming convention
--====================================================================================================

SET @TargetSchemaID =
						(
						SELECT	TOP 1 sc.SchemaID
						FROM	DC.[Schema] sc
						WHERE	DatabaseID = @TargetHUBDatabaseID
							and SchemaName = @TargetSchemaName
						)


IF @TargetSchemaID IS NULL 
INSERT INTO DC.[Schema] 
			(SchemaName
			,DatabaseID
			,DBSchemaID
			,CreatedDT
			 )
(SELECT @TargetSchemaName
	  ,@TargetHUBDatabaseID
	  ,NULL
	  ,GETDATE()
 )

IF @TargetSchemaID IS NULL
SET @TargetSchemaID = @@IDENTITY


--====================================================================================================
--	Copy the structure of the Source Data Entity into DataEntity table in DC (if it does not exist)
--
--	Correct fields?  
--		Add IsActive field
--====================================================================================================

DECLARE @ID table (ID INT)

INSERT INTO [DC].[DataEntity]
			([DataEntityName],
			[SchemaID],
			[CreatedDT]
			)
OUTPUT inserted.DataEntityID INTO @ID
SELECT   @Hubname
		,@TargetSchemaID
		,GETDATE()
FROM DC.DataEntity
WHERE DataEntityID = @InitialSourceDataEntityID 
	AND NOT EXISTS
	(SELECT TOP  1 * 
	 FROM dc.[DataEntity] 
	 WHERE DataEntityName = @Hubname
		AND SchemaID = @TargetSchemaID
	 )
				
 

DECLARE @NewDataEntityID INT = (SELECT TOP 1 ID FROM @ID)
IF @NewDataEntityID IS NULL
SELECT @NewDataEntityID = DataEntityID 
FROM dc.[DataEntity] 
WHERE	DataEntityName = @HubName
	AND SchemaID = @TargetSchemaID

		
 
--====================================================================================================
--	Copy the structure of the Source Data Entity into Fields table in DC (if it does not exist) and
--	insert the additional HUB Fields (if it does not exist) 
--====================================================================================================
DECLARE @BusinessKeyFriendlyName varchar(50)
SET @BusinessKeyFriendlyName = (SELECT  
								BKFriendlyname 
								FROM DMOD.HubBusinessKey_Working bkw 
								INNER JOIN [DMOD].[Hub_Working] hw ON 
								bkw.hubid = hw.hubid 
								WHERE SourceDataEntityID = @InitialSourceDataEntityID
								)
	--Insert standard staging fields (use sort orders 1 to 6)							
CREATE TABLE #HubFields 
			(FieldName VARCHAR(1000)
			,DataType VARCHAR(500)
			,[MAXLENGTH] INT 
			,[Precision] INT
			,[Scale] INT
			,DataEntityID INT
			,CreatedDt DATETIME2(7)
			,FieldSortOrder INT
			,IsActive INT
			)
INSERT #HubFields VALUES
	   (@Hubname,'varchar',40,0,0,@NewDataEntityID, GETDATE(), 1, 1),
	   ('LoadDT','datetime2',8,27,7,@NewDataEntityID, GETDATE(), 2, 1),
	   ('RecSrcDataEntityID','INT',4,0,0,@NewDataEntityID, GETDATE(), 3, 1),
	   (@BusinessKeyFriendlyName,'VARCHAR',40,0,0,@NewDataEntityID, GETDATE(), 4, 1)

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
SELECT   FieldName
		,DataType
		,[MAXLENGTH]
		,[Precision] 
		,[Scale]
		,@NewDataEntityID
		,GETDATE()
		,1
		,FieldSortOrder
FROM #HUBFields
WHERE FieldName NOT IN (SELECT FieldName 
						FROM [DC].[Field]
						WHERE DataEntityID = @NewDataEntityID
						)
DROP TABLE #HUBFields
	

--====================================================================================================
--	Insert the entries into the DC.FieldRelation table (type = 2) for the Data Entity
--
--  TO DO:  Check for existing entries
--			Can there be an inactive relationship (must be done in the update portion of the code)
--====================================================================================================

--INSERT INTO [DC].[FieldRelation]
--		([SourceFieldID],
--		 [TargetFieldID],
--		 [FieldRelationTypeID],
--		 [CreatedDT],
--		 [IsActive]
--		 )
--SELECT s.fieldid
--	  ,t.fieldid
--	  ,2
--	  ,GETDATE()
--	  ,1
--FROM DC.Field s, DC.Field t
--WHERE   s.DataEntityID = @InitialSourceDataEntityID
--	AND t.DataEntityID = @NewDataEntityID
--	AND s.fieldid+' '+t.fieldid+' '+2 NOT IN (SELECT SourceFieldID+' '+TargetFieldID+' '+2
--											  FROM [DC].[FieldRelation]
--											  )
--GO

GO
