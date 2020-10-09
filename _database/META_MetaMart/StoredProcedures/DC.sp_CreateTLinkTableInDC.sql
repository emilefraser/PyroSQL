SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- ====================================================================================================
-- Author:      Francois Senekal
-- Create Date: 24 January 2019
-- Description: Creates Transactional Link tables in DC and auto-creates relationships to Source/TLINK
-- ====================================================================================================

CREATE PROCEDURE [DC].[sp_CreateTLinkTableInDC] AS


--====================================================================================================
--	All Variables Declared Here
--====================================================================================================


	--Get source system abbreviation of the top level parent
	DECLARE @TLINKID INT
	SET @TLINKID = 2

	DECLARE @InitialSourceDataEntityID int
	SET @InitialSourceDataEntityID = (SELECT SourceDataEntityID 
									  FROM [DMOD].[TransactionLink_Working] 
									  WHERE TransactionLinkID =@TLINKID)
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
		-- where dataentityname = @TLINKname )

    DECLARE @TargetTLINKDatabaseID INT
	SET @TargetTLINKDatabaseID = 24

	DECLARE @TargetSchemaName VARCHAR(20)
	SET @TargetSchemaName = 'RAW'



--====================================================================================================
--	Insert the TLINK in TempTable
--====================================================================================================

DECLARE @TLINKDataEntity TABLE 
		(TransactionLinkID INT
		,TLINKDataEntityName VARCHAR(100)
		,SourceDataEntityID INT
		,SourceDataEntityName VARCHAR(100)
		,SourceFieldName VARCHAR(100)
		,SourceFieldID INT
		,DataEntityID INT
		 )

INSERT INTO @TLINKDataEntity (TransactionLinkID, TLINKDataEntityName, SourceDataEntityID, SourceDataEntityName, SourceFieldName, SourceFieldID, DataEntityID)
SELECT DISTINCT TL.TransactionLinkID
				,'TLINK_' 
				+ [DC].[udf_ConvertStringToCamelCase]([DC].[udf_GetDataEntityNameForDataEntityID](@InitialSourceDataEntityID))
				,[DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID](@InitialSourceDataEntityID,0) --The Second Parameter is to specify that this is a 
				,@InitialSourceDataEntityName
				,f.FieldName
			    ,tlf.FieldID
				,NULL
FROM [DMOD].[TransactionLink_Working] TL	
INNER JOIN [DMOD].[TransactionLinkField_Working] TLF ON
	TL.[TransactionLinkID] = TLF.[TransactionLinkID]
INNER JOIN DC.DataEntity de ON
	de.DataEntityID = TL.SourceDataEntityID
INNER JOIN DC.Field f ON
	f.FieldID = tlf.FieldID

	select * from @TLINKDataEntity
--====================================================================================================
--	Insert the Target Schema in DC (if it does not exist) - the SAT db schema is equal to the source system abbreviation,
--	accoarding to the naming convention
--====================================================================================================

SET @TargetSchemaID =
						(
						SELECT	TOP 1 sc.SchemaID
						FROM	DC.[Schema] sc
						WHERE	DatabaseID = 24
							and SchemaName = 'RAW'
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
		  ,@TargetTLINKDatabaseID
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
SELECT   TLINKDataEntityName
		,@TargetSchemaID
		,GETDATE()
FROM	@TLINKDataEntity
WHERE NOT EXISTS
	 (SELECT 1
	  FROM	@TLINKDataEntity TLINK
	  INNER JOIN DC.DataEntity de ON
		 TLINK.TLINKDataEntityName = de.DataEntityName
		 AND de.SchemaID = @TargetSchemaID
	  )

--====================================================================================================
--	Copy the structure of the Source Data Entity into Fields table in DC (if it does not exist) and
--	insert the additional SAT Fields (if it does not exist) 
--====================================================================================================
	UPDATE	TLINK
	SET		TLINK.DataEntityID = de.DataEntityID
	FROM	@TLINKDataEntity TLINK
	INNER JOIN DC.DataEntity de ON TLINK.TLINKDataEntityName = de.DataEntityName
		AND de.SchemaID = @TargetSchemaID

		select * from @TLINKDataEntity
DECLARE @TargetSatDataEntityID INT
SET @TargetSatDataEntityID = (SELECT DISTINCT DataEntityID 
						      FROM @TLINKDataEntity
							  )
	
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


INSERT INTO [DC].[Field] 
	   ([FieldName],[DataType],[MAXLENGTH],[Precision],[Scale],[DataEntityID],[CreatedDT],[IsActive],[FieldSortOrder] )
	SELECT f.FieldName
		  ,f.DataType
		  ,f.[MAXLENGTH]
		  ,f.[Precision]
		  ,f.[Scale]
		  ,@TargetSatDataEntityID
		  ,GETDATE()
		  ,[IsActive]
		  ,[FieldSortOrder]			
FROM @Fields f	
WHERE NOT EXISTS (SELECT 1
				  FROM DC.FIELD f1
				  WHERE f1.FieldName = f.FieldName
					AND  @TargetSatDataEntityID = f1.DataEntityID		  
				  )

INSERT INTO [DC].[Field] 
	   ([FieldName],[DataType],[MAXLENGTH],[Precision],[Scale],[DataEntityID],[CreatedDT],[IsActive],[FieldSortOrder] )

SELECT	 f.FieldName
		,f.DataType
		,f.MAXLENGTH
		,f.PRECISION
		,f.Scale
		,tl.DataEntityID AS DataEntityID
		,GETDATE() AS [GETDATE]
		,1 AS IsActive
		,f.FieldSortOrder+3 AS FieldSortOrder
FROM	@TLINKDataEntity tl 
INNER JOIN DC.Field f ON 
	f.FieldID = tl.SourceFieldID
WHERE NOT EXISTS (SELECT 1
				  FROM DC.FIELD f1
				  WHERE tl.SourceFieldName = f1.FieldName
					AND tl.DataEntityID = f1.DataEntityID		  
				  )


SELECT SourceFieldName
,SourceFieldID
,f.FieldID
,f.FieldName FROM DC.FIELD f
INNER JOIN @TLINKDataEntity tlde ON
tlde.SourceFieldName = f.FieldName 
WHERE f.DataEntityID = @TargetSatDataEntityID

	

----====================================================================================================
----	Insert the entries into the DC.FieldRelation table (type = 2) for the Data Entity
----  TO DO:  Check for existing entries
----			Can there be an inactive relationship (must be done in the update portion of the code)
----====================================================================================================

INSERT INTO [DC].[FieldRelation]
		([SourceFieldID],
		 [TargetFieldID],
		 [FieldRelationTypeID],
		 [CreatedDT],
		 [IsActive]
		 )
	SELECT fr.SourceFieldID
		  ,fr.TargetFieldID
		  ,2
		  ,GETDATE()
		  ,1
FROM DC.FieldRelation fr
INNER JOIN DC.Field f ON
fr.SourceFieldID = f.FieldID
INNER JOIN DC.Field f1 ON
fr.TargetFieldID = f1.FieldID
GO
