SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



-- ====================================================================================================
-- Author:      Francois Senekal
-- Create Date: 24 January 2019
-- Description: Creates PKFKLink tables in DC and auto-creates relationships to Source/PKFKLink
-- ====================================================================================================
CREATE PROCEDURE [DC].[sp_CreatePKFKLinkTableInDC_Backup20190917]
		@ChildHubID INT,
		@TargetDatabaseID INT 
AS

/*====================================================================================================
TEST Case 1: 
1.Check what the variables are
SELECT * FROM [DMOD].[PKFKLink_Working] WHERE PKFKLinkID = 1

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
select * from dc.[database]
--====================================================================================================*/
--====================================================================================================
--TEST Variables
--====================================================================================================*/

--DECLARE	@ChildHubID INT = 4
--DECLARE	@TargetDatabaseID INT = 12

/*====================================================================================================
Insert Into Temp Table
====================================================================================================*/

IF OBJECT_ID('tempdb..#PKFKTemp') IS NOT NULL
DROP TABLE #PKFKTemp
CREATE TABLE #PKFKTemp 
		(LinkName varchar(100)
		,LinkHKName varchar(100)
		,ParentHubID int
		,ParentHubName varchar(100)
		,ParentSourceName varchar(100)
		,ParentHubVariationName varchar(100)
		,ParentBK varchar(100)
		,ChildHubID int
		,ChildHubName varchar(100)
		,ChildSourceName varchar(100)
		,ChildBK varchar(100)
		,PrimaryKeyFieldID int
		,PrimaryKeyFieldName varchar(100)
		,ForeignKeyFieldID int
		,ForeignKeyFieldName varchar(100)
		,LinkDataEntityID int
		,FieldSortOrder int
	     )

INSERT INTO #PKFKTemp
SELECT DISTINCT  l.LinkName
			    ,REPLACE(l.LinkName,'LINK_','LINKHK_')
				,l.ParentHubID
				,hparent.HubName
				,RIGHT(hparent.HubName,LEN(hparent.HubName)-4) AS ParentSourceDataEntityName
				,l.ParentHubNameVariation
				,hbkfparent.fieldid
				,l.ChildHubID
				,hchild.HubName
				,RIGHT(hchild.HubName,LEN(hchild.HubName)-4) AS ChildSourceDataEntityName
				,hbkfchild.fieldid
				,lf.PrimaryKeyFieldID
				,fprimary.FieldName
				,lf.ForeignKeyFieldID
				,fforeign.FieldName
				,LinkDataEntityID = NULL
				,fforeign.FieldSortOrder
from DMOD.PKFKLink l
	INNER JOIN DMOD.PKFKLinkField lf 
		ON l.PKFKLinkID = lf.PKFKLinkID
	INNER JOIN DMOD.HUB hparent 
		ON hparent.HubID = l.ParentHubID
	INNER JOIN DMOD.HUB hchild
		ON hchild.HubID = l.ChildHubID
	INNER JOIN DC.Field fprimary 
		ON fprimary.FieldID = PrimaryKeyFieldID
	INNER JOIN DC.Field fforeign 
		ON fforeign.FieldID = foreignkeyfieldid
	INNER JOIN dmod.Hubbusinesskey parenthbk 
		ON parenthbk.hubid = hparent.HubID
	INNER JOIN DMOD.HubBusinessKeyField hbkfparent 
		ON hbkfparent.HubBusinessKeyID = parenthbk.HubBusinessKeyID
	INNER JOIN dmod.Hubbusinesskey childhbk 
		ON childhbk.hubid = hchild.HubID
	INNER JOIN DMOD.HubBusinessKeyField hbkfchild 
		ON hbkfchild.HubBusinessKeyID = childhbk.HubBusinessKeyID
WHERE hchild.HubID = @ChildHubID --@ChildHubID
	-- Is the link records active?
	and l.IsActive <> 0
	and lf.IsActive <> 0

	-- Is the hub records active?
	and hchild.IsActive <> 0
		and childhbk.IsActive <> 0
		and hbkfchild.IsActive <> 0
	and hparent.IsActive <> 0
		and parenthbk.IsActive <> 0
		and hbkfparent.IsActive <> 0

--HERE l.PKFKLinkID = @PKFKLinkID
--AND 


--select	*
--from	#PKFKTemp

/*====================================================================================================
Declare all variables here
====================================================================================================*/
--DECLARE @TargetSchemaName varchar(20) = 'raw'

--====================================================================================================
--	Insert the Target Schema in DC (if it does not exist) - the M2MLink db schema is equal to the source system abbreviation,
--	accoarding to the naming convention
--====================================================================================================
--TODO : Make this dynamic
DECLARE @TargetSchemaName VARCHAR(20) = 'raw'
				
DECLARE @TargetSchemaID INT =
						(
							SELECT s.SchemaID 
										FROM 
										[DC].[Schema] s
										INNER JOIN [DC].[Database] db
										ON s.databaseid = db.databaseid
										WHERE db.DatabaseID = @TargetDatabaseID
										AND s.SchemaName = @TargetSchemaName
						)

if @TargetSchemaID IS NULL
BEGIN
	INSERT INTO DC.[Schema] 
	(
	SchemaName
	, DatabaseID
	, DBSchemaID
	, CreatedDT
	)
	(
	SELECT @TargetSchemaName
		  ,@TargetDatabaseID
		  ,NULL
		  ,GETDATE()
	)

	set @TargetSchemaID = @@IDENTITY
END


--SELECT * FROM DC.[Schema] 
--WHERE SchemaID = @TargetSchemaID


--SELECT * FROM #PKFKTemp
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
SELECT DISTINCT  LinkName
				,@TargetSchemaID
				,GETDATE()
FROM	#PKFKTemp link
	 left join DC.DataEntity de
		ON de.DataEntityName = link.LinkName
			and de.SchemaID = @TargetSchemaID
WHERE de.DataEntityID IS NULL
--WHERE NOT EXISTS
--	 (SELECT *
--	  FROM	#PKFKTemp pkfk
--	  INNER JOIN DC.DataEntity de ON
--		 pkfk.LinkName = de.DataEntityName
--		 AND de.SchemaID = 24 --@TargetSchemaID
--	  )
--====================================================================================================
--	Updates DataEntityID
--====================================================================================================
UPDATE	pkfk
SET		LinkDataEntityID = de.DataEntityID
FROM	#PKFKTemp pkfk
INNER JOIN DC.DataEntity de ON pkfk.LinkName = de.DataEntityName
	AND de.SchemaID = @TargetSchemaID
	
--====================================================================================================
--Inserts HK LoadDT Resource fields
--====================================================================================================
IF OBJECT_ID('tempdb..#Fields') IS NOT NULL
DROP TABLE #Fields
CREATE TABLE #Fields		
           (OriginalFieldID int NULL,
			LinkFieldID int NULL,
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

INSERT INTO #Fields
SELECT DISTINCT NULL
			   ,NULL
			   ,REPLACE(LinkHKName,'LINKHK_','HK_')
		       ,'varchar'
			   ,40
			   ,0
			   ,0
			   ,LinkDataEntityID
			   ,GETDATE()
			   ,1
			   ,1
FROM #PKFKTemp

INSERT INTO #Fields
SELECT DISTINCT NULL
			   ,NULL
			   ,'LoadDT'
		       ,'datetime2'
			   ,8
			   ,27
			   ,7	
			   ,LinkDataEntityID
			   ,GETDATE()
			   ,2
			   ,1
FROM #PKFKTemp

INSERT INTO #Fields
SELECT DISTINCT NULL
			   ,NULL
			   ,'RecSrcDataEntityID'
		       ,'int'
			   ,4
			   ,10
			   ,0
			   ,LinkDataEntityID
			   ,GETDATE()
			   ,3
			   ,1
FROM #PKFKTemp

INSERT INTO #Fields
SELECT DISTINCT NULL
			   ,NULL
			   ,'HK_'+ChildSourceName
		       ,'varchar'
			   ,40
			   ,0
			   ,0
			   ,LinkDataEntityID
			   ,GETDATE()
			   ,4
			   ,1
FROM #PKFKTemp

INSERT INTO #Fields
SELECT DISTINCT NULL
			   ,NULL
			   ,'HK_'+ISNULL(ParentHubVariationName,ParentSourceName)
		       ,'varchar'
			   ,40
			   ,0
			   ,0
			   ,LinkDataEntityID
			   ,GETDATE()
			   ,5
			   ,1
FROM #PKFKTemp

INSERT INTO [DC].[Field] ([FieldName],[DataType],[MAXLENGTH],[Precision],[Scale],[DataEntityID],[CreatedDT],[IsActive],[FieldSortOrder] )
SELECT	   f.FieldName
		  ,f.DataType
		  ,f.[MAXLENGTH]
		  ,f.[Precision]
		  ,f.[Scale]
		  ,DataEntityID
		  ,GETDATE()
		  ,[IsActive]
		  ,f.[FieldSortOrder]		
FROM #Fields f
WHERE NOT EXISTS (
					SELECT 
						1
					FROM 
						DC.[Field] f1
					WHERE 
						f1.FieldName = f.FieldName
					AND 
						f.DataEntityID = f1.DataEntityID		  
				  )
ORDER BY DATAEntityID , FieldSortOrder

update f
SET f.LinkFieldID = f1.FieldID
FROM #Fields f
	INNER JOIN DC.DataEntity de ON
	de.DataEntityID = f.DataEntityID
	INNER JOIN dc.Field f1 ON 
	f1.FieldName = f.FieldName
	AND f.DataEntityID = f1.DataEntityID
WHERE f.FieldName like 'HK_%'

--select	*
--from	DC.vw_rpt_DatabaseFieldDetail
--where	DatabaseID = 8
--	and DataEntityName like'LINK%'

--====================================================================================================
--	Insert the entries into the DC.FieldRelation table (type = 2) for the BKHash
--====================================================================================================
--/*

IF OBJECT_ID('tempdb..#FieldRelation') IS NOT NULL
DROP TABLE #FieldRelation
CREATE TABLE #FieldRelation
	(
		SourceFieldID int
		,TargetFieldID int
		,FieldRelationTypeID int
		,CreatedDT datetime2(7)
		,IsActive int
	)

INSERT INTO #FieldRelation
--FieldRelation for the LINKHK
SELECT DISTINCT 
				--[DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID_PKFK_HKLink](temp.ParentBK,2,'%'+BaseName+'%')
			   [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID_PKFK_HKLink](temp.ParentBK) as StageFieldID
			   ,
			   f.FIELDID
			   --,f.FieldName
			   ,2
			   ,GETDATE()
			   ,1
--select	*
FROM DC.Field f
	INNER JOIN #Fields f1 ON f1.LinkFieldID = f.FieldID
	INNER JOIN (SELECT DISTINCT ParentBK,REPLACE(LinkName,'LINK_','HK_') AS HK,REPLACE(LinkName,'LINK_','') AS BaseName,LinkHKName FROM #PKFKTemp) temp ON f1.FieldName = temp.HK

UNION ALL

--FieldRelation for the PK
SELECT DISTINCT 
--DMOD.udf_GetStageFieldIDFromSourceBKFieldIDForPKFKLink(temp.ParentBK,temp.LinkHKName)
--			   ,
				[DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID_PKFK_HK_PK](temp.ParentBK)

			   ,f.FIELDID
			   --,f.FieldName
			   ,2
			   ,GETDATE()
			   ,1
FROM DC.Field f
INNER JOIN #Fields f1 
	ON f1.LinkFieldID = f.FieldID
INNER JOIN (SELECT DISTINCT ParentBK,'HK_'+ParentSourceName AS HK FROM #PKFKTemp) temp 
	ON f1.FieldName = temp.HK

UNION ALL

--FieldRelation for the FK
SELECT	DISTINCT [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID_PKFK_HK_FK](temp.ChildBK)
		,f.FIELDID
		--,f.FieldName
		,2
		,GETDATE() 
		,1
--select	*
FROM DC.Field f
	--INNER JOIN DC.DataEntity de ON de.DataEntityID = f.DataEntityID
	INNER JOIN #Fields f1 ON f.FieldID = f1.LinkFieldID
	INNER JOIN (SELECT DISTINCT ChildBK,'HK_'+ChildSourceName AS HK FROM #PKFKTemp) temp ON f1.FieldName = temp.HK
--WHERE f.FieldName Like 'FK_%'

INSERT INTO DC.FieldRelation
(SourceFieldID,TargetFieldID,FieldRelationTypeID,CreatedDT,IsActive)
SELECT 
SourceFieldID,TargetFieldID,FieldRelationTypeID,CreatedDT,IsActive
FROM #FieldRelation frtemp
WHERE NOT EXISTS (SELECT 1 
				  FROM DC.FieldRelation fr
				  WHERE fr.SourceFieldID = frtemp.SourceFieldID
				  AND	fr.TargetFieldID = frtemp.TargetFieldID
				  AND fr.FieldRelationTypeID = frtemp.FieldRelationTypeID
				  )


--*/

GO
