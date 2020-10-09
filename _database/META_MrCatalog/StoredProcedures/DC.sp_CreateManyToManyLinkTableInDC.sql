SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- ====================================================================================================
-- Author:      Francois Senekal
-- Create Date: 24 January 2019
-- Description: Creates M2MLink tables in DC and auto-creates relationships to Source/M2MLink
-- ==============================================================

CREATE PROCEDURE [DC].[sp_CreateManyToManyLinkTableInDC] AS
/*====================================================================================================
TEST Case 1: 
1.Check what the variables are
SELECT * FROM [DMOD].[ManyToManyLink_Working] WHERE ManyToManyLinkID = 1


2.Use a @TargetHUBDatabaseID that does not exist (60)

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

--====================================================================================================
--TempTable CreatedHere
--====================================================================================================
DECLARE @M2MLinkID INT
SET @M2MLinkID = 1

DECLARE @M2MLinkTemp TABLE
(ManyToManyLinkID INT
,LinkName VARCHAR(50)
,InitialSourceDataEntityID INT
,Hubid INT
,HubName VARCHAR(50)
,ManyToManyTableFKFieldID INT
,ManyToManyTableFKFieldName VARCHAR(50)
,PKDataEntityID INT
,PKDataEntityName VARCHAR(50)
,BKFriendlyName VARCHAR(50)
,TargetDataEntityID INT
,SourceDataEntityName VARCHAR(50)
,M2MLinkFriendlyName VARCHAR(50)
,SourceSchemaID INT
,PKFieldID INT
,PKFieldName VARCHAR(50)
,DataType VARCHAR(50)
,[MaxLength] INT
,[Precision] INT
,[Scale] INT
,FieldSortOrder INT
,ForeignKeyHK VARCHAR(50)
)
INSERT INTO @M2MLinkTemp
select
@M2MLinkID
,LinkName
,ManyToManyDataEntityID
,lhmtm.hubid
,HubName
,ManyToManyTableFKFieldID
,f1.FieldName
,SourceDataEntityID
,de1.DataEntityName
,BKFriendlyName
,NULL
,de.DataEntityName
,de.FriendlyName
,de.SchemaID
,f.FieldID as PKFieldID
,f.FieldName as PKFieldName
,f.DataType as DataType
,f.MaxLength
,f.Precision
,f.Scale
,f1.FieldSortOrder
,'HK_'+f.FieldName
from [DMOD].[ManyToManyLink_Working] mtml
INNER JOIN  [DMOD].[LinkHubToManyToManyLink_Working] lhmtm ON	
	mtml.ManyToManyLinkID = lhmtm.ManyToManyLinkID
INNER JOIN [DMOD].[LinkHubToManyToManyLinkField_Working] lhmtmf ON
	lhmtmf.LinkHubToManyToManyLinkID = lhmtm.LinkHubToManyToManyLinkID
INNER JOIN [DMOD].[Hub_Working] hw ON
	hw.HubID = lhmtm.HubID
INNER JOIN [DMOD].[HubBusinessKey_Working] hbk ON
	hbk.HubID = hw.HubID
INNER JOIN DC.DataEntity de ON
	de.DataEntityID = mtml.ManyToManyDataEntityID
INNER JOIN DC.DataEntity de1 ON
	de1.DataEntityID = SourceDataEntityID
INNER JOIN DC.Field f ON
	lhmtmf.HubPKFieldID = f.FieldID
INNER JOIN DC.Field f1 ON
	lhmtmf.ManyToManyTableFKFieldID = f1.FieldID
WHERE mtml.ManyToManyLinkID = @M2MLinkID
select * from @m2mlinkTemp
--====================================================================================================
--	All Variables Declared Here
--====================================================================================================


	--Get source system abbreviation of the top level parent

DECLARE @InitialSourceDataEntityID int
SET @InitialSourceDataEntityID = (SELECT DISTINCT InitialSourceDataEntityID 
								  FROM @M2MLinkTemp
								  )
DECLARE @InitialSourceDataEntityName varchar(50)
SET @InitialSourceDataEntityName = (SELECT [DC].[udf_ConvertStringToCamelCase](DataEntityName) 
										FROM dc.dataentity 
										WHERE dataentityID = @InitialSourceDataEntityID
										)
DECLARE @TargetSchemaID INT

	--TODO :Replace with dynamic SQL
SET @TargetSchemaID = 31
		--(select distinct de.schemaid 
		-- from dc.[schema] s 
		-- join dc.dataentity de on 
		-- de.schemaid = de.schemaid 
		-- where dataentityname = @SATname )

DECLARE @TargetM2MLinkDatabaseID INT
SET @TargetM2MLinkDatabaseID = 24

DECLARE @TargetSchemaName VARCHAR(20)
SET @TargetSchemaName = 'RAW'
--====================================================================================================
--	Insert the Target Schema in DC (if it does not exist) - the M2MLink db schema is equal to the source system abbreviation,
--	accoarding to the naming convention
--====================================================================================================

SET @TargetSchemaID =
						(
						SELECT	TOP 1 sc.SchemaID
						FROM	DC.[Schema] sc
						WHERE	DatabaseID = @TargetM2MLinkDatabaseID
							and SchemaName = @TargetSchemaName
						)

if @TargetSchemaID IS NULL 
	INSERT INTO DC.[Schema] 
	(
	SchemaName
	, DatabaseID
	, DBSchemaID
	, CreatedDT
	)
	(
	SELECT @TargetSchemaName
		  ,@TargetM2MLinkDatabaseID
		  ,NULL
		  ,GETDATE()
	)

if @TargetSchemaID IS NULL
set @TargetSchemaID = @@IDENTITY

--====================================================================================================
--	Copy the structure of the Source Data Entity into DataEntity table in DC (if it does not exist)
----====================================================================================================
		
INSERT INTO DC.DataEntity
(DataEntityName
,SchemaID
,CreatedDT
)
SELECT DISTINCT  LinkName
		,@TargetSchemaID
		,GETDATE()
FROM	@M2MLinkTemp
WHERE NOT EXISTS
	 (SELECT 1
	  FROM	@M2MLinkTemp m2m
	  INNER JOIN DC.DataEntity de ON
		 m2m.LinkName = de.DataEntityName
		 AND de.SchemaID = @TargetSchemaID
	  )

--====================================================================================================
--	Updates DataEntityID
--====================================================================================================
UPDATE	m2m
SET		TargetDataEntityID = de.DataEntityID
FROM	@M2MLinkTemp m2m
INNER JOIN DC.DataEntity de ON m2m.LinkName = de.DataEntityName
	AND de.SchemaID = @TargetSchemaID

--====================================================================================================
--Inserts HK LoadDT Resource fields
--====================================================================================================
	
DECLARE @Fields TABLE
		(
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

	INSERT @Fields VALUES
		  ('HK_'+@InitialSourceDataEntityName,'varchar',40,0,0,-1, GETDATE(), 1, 1),
		  ('LoadDT','datetime2',8,27,7,-1, GETDATE(), 2, 1),
		  ('RecSrcDataEntityID','int',4,0,0,-1, GETDATE(), 3, 1)

DECLARE @TargetDEID int
SET @TargetDEID = (Select distinct TargetDataEntityID from @M2MLinkTemp)


INSERT INTO [DC].[Field] 
	       ([FieldName],[DataType],[MAXLENGTH],[Precision],[Scale],[DataEntityID],[CreatedDT],[IsActive],[FieldSortOrder] )

SELECT	   f.FieldName
		  ,f.DataType
		  ,f.[MAXLENGTH]
		  ,f.[Precision]
		  ,f.[Scale]
		  ,@TargetDEID
		  ,GETDATE()
		  ,[IsActive]
		  ,f.[FieldSortOrder]		
FROM @Fields f
WHERE NOT EXISTS (SELECT 1
				  FROM DC.FIELD f1
				  WHERE f1.FieldName = f.FieldName
					AND @TargetDEID = f1.DataEntityID		  
				  )

--====================================================================================================
--Inserts Business Key HK Fields
--====================================================================================================
INSERT INTO [DC].[Field] 
			([FieldName],[DataType],[MAXLENGTH],[Precision],[Scale],[DataEntityID],[CreatedDT],[IsActive],[FieldSortOrder] )

SELECT	 m2m.ForeignKeyHK
		,'varchar'
		,40
		,0
		,0
		,@TargetDEID
		,GETDATE()
		,1
		,m2m.FieldSortOrder+3

FROM	@M2MLinkTemp m2m
INNER JOIN DC.Field f ON 
		 f.FieldID = m2m.PKFieldID
WHERE NOT EXISTS (SELECT 1
				  FROM DC.FIELD f1
				  WHERE m2m.ForeignKeyHK = f1.FieldName
					AND m2m.TargetDataEntityID = f1.DataEntityID		  
				  )






	

----====================================================================================================
----	Insert the entries into the DC.FieldRelation table (type = 2) for the Data Entity
----====================================================================================================


DECLARE @TempLeft TABLE 
(FieldID INT,FieldName VARCHAR(100))
INSERT INTO @TempLeft
SELECT FieldID
	  ,LEFT(FieldName,8)
FROM DC.field 
WHERE dataentityid = @TargetDEID
	AND FieldName like '%HK%'

INSERT INTO [DC].[FieldRelation]
([SourceFieldID],
 [TargetFieldID],
 [FieldRelationTypeID],
 [CreatedDT],
 [IsActive]
 )

SELECT F1.SFieldID 
	  ,FieldID 
	  ,2
	  ,GETDATE()
	  ,1
FROM @TempLeft tl
INNER JOIN (SELECT LEFT(fieldname,8) AS SFieldName
				  ,FieldID AS SFieldID
			FROM dc.field
			WHERE dataentityid = 9892
			AND FieldName like '%HK%'
			) F1 ON
F1.SFieldName = tl.FieldName
WHERE NOT EXISTS (SELECT 1 
				  FROM DC.FieldRelation fr 
				  INNER JOIN @TempLeft tl ON
				  F1.SfieldID = fr.SourceFieldID
				  AND tl.FieldId = TargetFieldID				  
				   )

GO
