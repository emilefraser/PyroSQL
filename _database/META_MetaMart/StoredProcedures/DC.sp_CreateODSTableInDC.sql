SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/**********************************************************************************************************************
Stored Procedure purpose: Creating a table from DC into the ODS format
Author: Francois Senekal
Date : 2019/01/07
TFS Job: 315
**********************************************************************************************************************/

CREATE procedure [DC].[sp_CreateODSTableInDC]
(
@NewDataEntityID int Output,
@LogOutputID int Output,
@SourceDataEntityID int,
@TargetDatabaseID INT
)
AS
/**********************************************************************************************************************
Test Case 1:  
1. Set @TargetDatabaseID to a DB that doesn't exist in DC (999)
2. Run the proc
3. Check if schema / dataentity/ fields / STT was created (TODO : Change the date to the date you ran the proc)
	SELECT * FROM DC.[SCHEMA] WHERE CREATEDDT > '2019/01/31'
	SELECT * FROM DC.DATAENTITY WHERE CREATEDDT > '2019/01/31'
	SELECT * FROM DC.FIELD WHERE CREATEDDT > '2019/01/31'
	SELECT * FROM DC.FIELDRELATION WHERE CREATEDDT > '2019/01/31'
4. Remove the created fields !!!(BEWARE DELETE STATEMENTS)!!!

Test Case 1:
1. Set @TargetDatabaseID to a DB that already exists in DC 
2. Run the proc
3. Check if schema / dataentity/ fields / STT was not created (TODO : Change the date to the date you ran the proc)
	SELECT * FROM DC.[SCHEMA] WHERE CREATEDDT > '2019/01/31'
	SELECT * FROM DC.DATAENTITY WHERE CREATEDDT > '2019/01/31'
	SELECT * FROM DC.FIELD WHERE CREATEDDT > '2019/01/31'
	SELECT * FROM DC.FIELDRELATION WHERE CREATEDDT > '2019/01/31'

**********************************************************************************************************************/

/**********************************************************************************************************************
DECLARE Variables
**********************************************************************************************************************/
--DECLARE @SourceDataEntityID INT
--SET @SourceDataEntityID = 68
--DECLARE @TargetDatabaseID INT
--SET @TargetDatabaseID = 8
DECLARE @TargetSchemaID INT
DECLARE @TargetDataEntityID INT
DECLARE @SourceSchemaName VARCHAR(max) = 
	(SELECT	s.schemaname 
	 FROM	dc.dataentity de
	 JOIN dc.[schema] s ON
		s.schemaid = de.schemaid
	 JOIN dc.[database] db ON 
		 db.databaseid = s.databaseid
	 WHERE de.dataentityid =  @SourceDataEntityID
	 )
/**********************************************************************************************************************
Create Schema where not exists
**********************************************************************************************************************/

SELECT	TOP 1 @TargetSchemaID = sc.SchemaID
FROM	DC.[Schema] sc
WHERE	DatabaseID = @TargetDatabaseID
	AND SchemaName = @SourceSchemaName

IF @TargetSchemaID IS NULL 
INSERT INTO DC.[Schema] (SchemaName,
						 DatabaseID,
						 DBSchemaID,
						 CreatedDT
					     )

(SELECT  s.schemaname 
		,@TargetDatabaseID
		,NULL
		,GETDATE()
FROM dc.[schema] s
JOIN dc.dataentity de ON
	de.schemaid = s.schemaid
WHERE de.dataentityid = @SourceDataEntityID
)

IF @TargetSchemaID IS NULL
SET @TargetSchemaID = @@IDENTITY;

/**********************************************************************************************************************
--Create table IF not exists (copy from source table)
--do an IF not exists in target db from DC
**********************************************************************************************************************/
DECLARE @DataEntityName VARCHAR(MAX) = (SELECT de.dataentityname
										FROM dc.dataentity de
										JOIN dc.[schema] s ON 
											s.schemaid = de.schemaid
										WHERE s.schemaid = @TargetSchemaID
											AND de.dataentityname =  (SELECT TOP 1 dataentityname 
																	  FROM dc.dataentity 
																	  WHERE Dataentityid = @SourceDataEntityID 
																	  )
										)


IF @DataEntityName IS NULL
INSERT INTO [DC].[DataEntity]
           ([DataEntityName]
           ,[SchemaID]
		   ,CreatedDT
		   )


		   --FS Added logging output
(SELECT DISTINCT de.DataEntityName
				,@TargetSchemaID AS TargetSchemaID 
				,GETDATE() AS CreatedDT
FROM DC.DataEntity de
INNER JOIN DC.[Schema] s ON
	s.SchemaID = de.SchemaID
INNER JOIN DC.[Database] db ON
	db.DatabaseID = s.DatabaseID
WHERE de.dataentityid = @SourceDataEntityID
)
IF @DataEntityName IS NULL
BEGIN
SET @TargetDataEntityID = @@IDENTITY
SET @LogOutputID = 1
END
ELSE
BEGIN 
SET @TargetDataEntityID =  (SELECT TOP 1 de.DataEntityID 
							FROM dc.[schema] s 
							JOIN dc.dataentity de ON
								s.schemaid = de.schemaid
							WHERE s.schemaid = @TargetSchemaID
								AND de.dataentityname = @DataEntityName
							)
SET @LogOutputID = 0
END
SET @NewDataEntityID = @TargetDataEntityID
/**********************************************************************************************************************
--Create fields IF not exists (copy from source table's fields) - must be a "clean" table (no PK, no FK, etc.)
--do an IF not exists in target db from DC, already clean table? , no need to use is primary key etc
**********************************************************************************************************************/

SELECT f.FieldName INTO #TempFieldList1
FROM dc.field f
JOIN dc.dataentity de ON
	 de.dataentityid = f.dataentityid
JOIN dc.[schema] s ON
	 s.schemaid = de.schemaid
WHERE de.dataentityid = @TargetDataEntityID
  AND s.schemaid = @TargetSchemaID

DECLARE @Count INT = (SELECT count(f.fieldname)
					  FROM dc.field f
				      JOIN dc.dataentity de ON
						de.dataentityid = f.dataentityid
					  JOIN dc.[schema] s ON 
						s.schemaid = de.schemaid
					  LEFT JOIN #TempFieldList1 tfl ON
						f.FieldName = tfl.FieldName 
					  WHERE de.dataentityid = @SourceDataEntityID
					  AND tfl.FieldName IS NULL
					  )
IF @Count != 0
INSERT INTO [DC].[Field]
           ([FieldName]
           ,[DataType]
		   ,[MAXLENGTH]
		   ,[Precision] 
		   ,[Scale]
           ,[DataEntityID]
           ,[DBColumnID]
		   ,CreatedDT
		   ,DataEntitySize
		   ,DatabaseSize)
(SELECT  f.FieldName
		,f.DataType
	    ,f.[maxlength]
	    ,f.[precision]
	    ,f.[scale]
	    ,@TargetDataEntityID as TargetDataEntityID
	    ,null
	    ,GETDATE()
	    ,null
	    ,null 
FROM DC.Field f
INNER JOIN dc.dataentity de ON
	de.dataentityid = f.dataentityid
INNER JOIN dc.[schema] s ON
	s.schemaid = de.schemaid
LEFT JOIN #TempFieldList1 tfl ON
	f.Fieldname = tfl.Fieldname
WHERE tfl.FieldName IS NULL
	AND de.dataentityid = @SourceDataEntityID
)
drop table #TempFieldList1

--====================================================================================================
--	Insert the entries into the DC.FieldRelation table (type = 2) for the History Data Entity
--
--  TO DO:  Check for existing entries
--====================================================================================================

INSERT INTO [DC].[FieldRelation]
			([SourceFieldID]
			,[TargetFieldID]
			,[FieldRelationTypeID]
			,[CreatedDT]
			,IsActive
			 )
SELECT s.fieldid
	  ,t.fieldid
	  ,2
	  ,GETDATE()
	  ,1
FROM DC.Field s, DC.Field t
WHERE s.DataEntityID = @SourceDataEntityID
	AND t.DataEntityID = @TargetDataEntityID
	AND s.FieldName = t.FieldName
	AND s.FieldID != t.FieldID
	AND s.fieldid+' '+t.fieldid+' '+2 NOT IN (SELECT SourceFieldID+' '+TargetFieldID+' '+2
											  FROM [DC].[FieldRelation]
											  )






--RETURN @NewDataEntityID

GO
