SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- ====================================================================================================
-- Author:      Francois Senekal
-- Create Date: 6 February 2019
-- Description: Creates HLink tables in DC and auto-creates relationships to Source/SAL
-- ==============================================================

CREATE PROCEDURE [DC].[sp_CreateHierarchicalLinkTableInDC] 
AS

/*--====================================================================================================
Test Case 1:

--====================================================================================================*/
--====================================================================================================
--TempTable CreatedHere
--====================================================================================================
DECLARE @HubID INT
SET @HubID = 14

DECLARE @HLinkTemp TABLE
						(HubName VARCHAR(100)
						,InitialSourceDataEntityName VARCHAR(100)
						,HierarchicalLinkName VARCHAR(100)
						,PrimaryKeyID int
						,PrimaryKeyFieldName varchar(100)
						,ParentFieldID int
						,FieldName VARCHAR(100)
						,DataType VARCHAR(100)
						,MaxLength int
						,Precision INT
						,Scale INT
						,TargetDataEntityID INT
						)
INSERT INTO @HLinkTemp
SELECT  HubName
	   ,RIGHT(HubName, LEN(HubName) - 4) AS InitialSourceDataEntityName
	   ,HierarchicalLinkName
	   ,PKFieldID AS PrimaryKeyID
	   ,pkfield.FieldName PrimaryKeYFieldName
	   ,ParentFieldID
	   ,parentField.FieldName As ParentFieldName
	   ,pkfield.DataType
	   ,pkfield.MaxLength
	   ,pkfield.Precision
	   ,pkfield.Scale
	   ,NULL
FROM DMOD.Hub h 
INNER JOIN DMOD.HierarchicalLink hl ON
hl.HubID = h.HubID
INNER JOIN DC.Field pkfield ON
pkfield.FieldID = hl.PKFieldID
INNER JOIN DC.Field parentField ON
parentField.FieldID = hl.ParentFieldID
WHERE h.HubID = @HubID

--====================================================================================================
--	All Variables Declared Here
--====================================================================================================


DECLARE @TargetSchemaID INT
	--TODO :Replace with dynamic SQL
SET @TargetSchemaID = 3
		--(select distinct de.schemaid 
		-- from dc.[schema] s 
		-- join dc.dataentity de on 
		-- de.schemaid = de.schemaid 
		-- where dataentityname = @SATname )
DECLARE @TargetHLinkDatabaseID INT
SET @TargetHLinkDatabaseID = 15
DECLARE @TargetSchemaName VARCHAR(20)
SET @TargetSchemaName = (SELECT UPPER(SchemaName) from DC.[Schema] where schemaid = @TargetSchemaID)
--====================================================================================================
--	Insert the Target Schema in DC (if it does not exist) - the M2MLink db schema is equal to the source system abbreviation,
--	accoarding to the naming convention
--====================================================================================================

SET @TargetSchemaID =
						(
						SELECT	TOP 1 sc.SchemaID
						FROM	DC.[Schema] sc
						WHERE	DatabaseID = @TargetHLinkDatabaseID
							and SchemaName = @TargetSchemaName
						)
select @TargetSchemaID
if @TargetSchemaID IS NULL 
	INSERT INTO DC.[Schema] 
	(SchemaName
	,DatabaseID
	,DBSchemaID
	,CreatedDT
	)
	(SELECT @TargetSchemaName
		   ,@TargetHLinkDatabaseID
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
SELECT DISTINCT  HierarchicalLinkName
				,@TargetSchemaID
				,GETDATE()
FROM	@HLinkTemp
WHERE NOT EXISTS
	 (SELECT 1
	  FROM	@HLinkTemp hl
	  INNER JOIN DC.DataEntity de ON
	  hl.HierarchicalLinkName = de.DataEntityName
		 AND de.SchemaID = @TargetSchemaID
	  )

--====================================================================================================
--	Updates DataEntityID
--====================================================================================================
UPDATE	hl
SET		TargetDataEntityID = de.DataEntityID
FROM	@HLinkTemp hl
INNER JOIN DC.DataEntity de ON hl.HierarchicalLinkName = de.DataEntityName
	AND de.SchemaID = @TargetSchemaID
--====================================================================================================
--Inserts HK LoadDT Resource fields
--====================================================================================================
	
DECLARE @Fields TABLE
		([FieldName] [varchar](1000) NOT NULL,
		 [DataType] [varchar](500) NULL,
		 [MaxLength] [int] NULL,
		 [Precision] [int] NULL,
		 [Scale] [int] NULL,
		 [DataEntityID] [int] NULL,
		 [CreatedDT] [datetime2](7) NULL,
		 [FieldSortOrder] [int] NULL,
		 [IsActive] [bit] NULL
		 )
DECLARE @InitialSourceDataEntityName VARCHAR(100) = (SELECT DISTINCT InitialSourceDataEntityName FROM @HLinkTemp)
INSERT @Fields VALUES
		  ('HK_'+@InitialSourceDataEntityName,'varchar',40,0,0,-1, GETDATE(), 1, 1),
		  ('LoadDT','datetime2',8,27,7,-1, GETDATE(), 2, 1),
		  ('RecSrcDataEntityID','int',4,0,0,-1, GETDATE(), 3, 1),
		  ('PARENT_HK_'+@InitialSourceDataEntityName,'int',4,0,0,-1, GETDATE(), 3, 1),
		  ('CHILD_HK_'+@InitialSourceDataEntityName,'int',4,0,0,-1, GETDATE(), 3, 1)


DECLARE @TargetDEID int
SET @TargetDEID = (Select distinct TargetDataEntityID from @HLinkTemp)
select * from @Fields
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




	

------====================================================================================================
------	Insert the entries into the DC.FieldRelation table (type = 2) for the HK BK
------====================================================================================================

--INSERT INTO [DC].[FieldRelation]
--		([SourceFieldID],
--		 [TargetFieldID],
--		 [FieldRelationTypeID],
--		 [CreatedDT],
--		 [IsActive]
--		 )
--SELECT  @StageBKFieldID
--		,f.fieldid
--		,2
--		,GETDATE()
--		,1				
--FROM DC.field f
--WHERE DataEntityID = @TargetDEID
--AND f.fieldname = 'HK_'+@InitialSourceDataEntityName
--AND  NOT EXISTS (SELECT *
--				 FROM DC.FieldRelation
--				 WHERE SourceFieldID = @StageBKFieldID
--				 AND TargetFieldID = (SELECT FieldID 
--									   FROM DC.Field
--									   WHERE DataEntityID = @TargetDEID
--									   AND FieldName like 'HK_'+@InitialSourceDataEntityName
--									   )	
--				 )
--------====================================================================================================
--------	Insert the entries into the DC.FieldRelation table (type = 2) for the HK BK PARENT
--------====================================================================================================
----INSERT INTO [DC].[FieldRelation]
----		([SourceFieldID],
----		 [TargetFieldID],
----		 [FieldRelationTypeID],
----		 [CreatedDT],
----		 [IsActive]
----		 )
----SELECT  @ParentBKFieldID
----		,f.fieldid
----		,2
----		,GETDATE()
----		,1				
----FROM DC.field f
----WHERE DataEntityID = @TargetDEID
----AND f.fieldname = 'HK_'+@InitialSourceDataEntityName
----AND  NOT EXISTS (SELECT 1
----				 FROM DC.FieldRelation
----				 WHERE SourceFieldID = @ParentBKFieldID
----				 AND TargetFieldID = (SELECT FieldID 
----									   FROM DC.Field
----									   WHERE DataEntityID = @TargetDEID
----									   AND FieldName like 'HK_'+@InitialSourceDataEntityName
----									   )	
----				 )

--------====================================================================================================
--------	Insert the entries into the DC.FieldRelation table (type = 2) for the BK PARENT
--------====================================================================================================
----INSERT INTO [DC].[FieldRelation]
----		([SourceFieldID],
----		 [TargetFieldID],
----		 [FieldRelationTypeID],
----		 [CreatedDT],
----		 [IsActive]
----		 )
----SELECT  @ParentBKFieldID
----		,f.fieldid
----		,2
----		,GETDATE()
----		,1				
----FROM DC.field f
----WHERE DataEntityID = @TargetDEID
----AND f.fieldname = 'HK_'+@InitialSourceDataEntityName
----AND  NOT EXISTS (SELECT 1
----				 FROM DC.FieldRelation
----				 WHERE SourceFieldID = @ParentBKFieldID
----				 AND TargetFieldID = (SELECT FieldID 
----									   FROM DC.Field
----									   WHERE DataEntityID = @TargetDEID
----									   AND FieldName like 'HK_'+@InitialSourceDataEntityName
----									   )	
----				 )

--------====================================================================================================
--------	Insert the entries into the DC.FieldRelation table (type = 2) for the BK PARENT
--------====================================================================================================
----INSERT INTO [DC].[FieldRelation]
----		([SourceFieldID],
----		 [TargetFieldID],
----		 [FieldRelationTypeID],
----		 [CreatedDT],
----		 [IsActive]
----		 )
----SELECT  @ParentBKFieldID
----		,f.fieldid
----		,2
----		,GETDATE()
----		,1				
----FROM DC.field f
----WHERE DataEntityID = @TargetDEID
----AND f.fieldname like 'PARENT_%'
----AND  NOT EXISTS (SELECT 1
----				 FROM DC.FieldRelation
----				 WHERE SourceFieldID = @ParentBKFieldID
----				 AND TargetFieldID = (SELECT FieldID 
----									   FROM DC.Field
----									   WHERE DataEntityID = @TargetDEID
----									   AND FieldName like 'PARENT_%'
----									   )	
----				 )
--------====================================================================================================
--------	Insert the entries into the DC.FieldRelation table (type = 2) for the BK CHILD
--------====================================================================================================
----INSERT INTO [DC].[FieldRelation]
----		([SourceFieldID],
----		 [TargetFieldID],
----		 [FieldRelationTypeID],
----		 [CreatedDT],
----		 [IsActive]
----		 )
----SELECT  @StageBKFieldID
----		,f.fieldid
----		,2
----		,GETDATE()
----		,1				
----FROM DC.field f
----WHERE DataEntityID = @TargetDEID
----AND f.fieldname like 'CHILD_%'
----AND  NOT EXISTS (SELECT 1
----				 FROM DC.FieldRelation
----				 WHERE SourceFieldID = @StageBKFieldID
----				 AND TargetFieldID = (SELECT FieldID 
----									   FROM DC.Field
----									   WHERE DataEntityID = @TargetDEID
----									   AND FieldName like 'CHILD_%'
----									   )	
----				 )

GO
