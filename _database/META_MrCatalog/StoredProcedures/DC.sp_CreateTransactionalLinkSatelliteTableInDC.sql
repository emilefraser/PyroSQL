SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- ====================================================================================================
-- Author:      Francois Senekal
-- Create Date: 27 February 2019
-- Description: Creates TLinkSat
-- ==============================================================

CREATE PROCEDURE [DC].[sp_CreateTransactionalLinkSatelliteTableInDC] AS
/*--====================================================================================================
Test Case 1:

--====================================================================================================*/

--====================================================================================================
--TempTable CreatedHere for SAL
--====================================================================================================
DECLARE @HubID INT
SET @HubID = 2
DECLARE @TLinkID INT
SET @TLinkID = 2

DECLARE @TSATTemp TABLE
	   (TransactionLinkID INT
	   ,SourceLinkDataEntityID INT
	   ,TransactionalLinkName VARCHAR(100)
	   ,TransactionalLinkSATName VARCHAR(100)
	   ,DataEntityHeaderPKFieldID INT
	   ,DataEntityDetailFKFieldID INT
	   ,TLinkSatFieldID INT
	   ,TLinkSatFieldName VARCHAR(100)
	   ,TLinkSatDataType VARCHAR(100)
	   ,TLinkSatMaxLength INT
	   ,TLinkSatPrecision INT
	   ,TLinkSatScale INT
	   ,TLinkFieldSortOrder INT
	   ,LinkTransactionLinkToHubID INT
	   ,HubLinkID INT
	   ,HubName VARCHAR(100)
	   ,BusinessKeySourceFieldID INT
	   ,BusinessKeySourceFieldName VARCHAR(100)
	   ,TargetDataEntityID INT
	   ,InitialSourceDataEntityName VARCHAR(100)
	    )
INSERT INTO @TSATTemp
SELECT tlw.TransactionLinkID
	  ,tlw.SourceDataEntityID
	  ,tlw.TransactionalLinkName
	  ,'SAT'+tlw.TransactionalLinkName
	  ,tlw.DataEntityHeaderPKFieldID
	  ,tlw.DataEntityDetailFKFieldID
	  ,tlfw.FieldID
	  ,f.FieldName
	  ,f.DataType
	  ,f.MaxLength
	  ,f.Precision
	  ,f.Scale
	  ,f.FieldSortOrder
	  ,LinkTransactionLinkToHubID
	  ,ltlh.HubID
	  ,hw.HubName
	  ,SourceFieldID
	  ,f1.FieldName
	  ,NULL
	  ,(SELECT SUBSTRING(tlw.TransactionalLinkName,CHARINDEX('_',tlw.TransactionalLinkName)+1,100))
FROM dmod.TransactionLink_Working tlw
INNER JOIN dmod.TransactionLinkField_Working tlfw ON
tlw.TransactionLinkID = tlfw.TransactionLinkID
INNER JOIN DMOD.LinkTransactionLinkToHub_Working ltlh ON
ltlh.TransactionLinkID = tlw.TransactionLinkID
INNER JOIN DMOD.HubBusinessKey_Working hkw ON
hkw.HubID = ltlh.HubID
INNER JOIN DC.Field f ON 
tlfw.FieldID = f.FieldID
INNER JOIN DC.Field f1 ON
f1.FieldID = hkw.SourceFieldID
INNER JOIN DMOD.Hub_Working hw ON
hw.HubID = hkw.HubID
WHERE tlw.TransactionLinkID = @TLinkID
select * from @TSATTemp
--====================================================================================================
--	All Variables Declared Here
--====================================================================================================


DECLARE @TargetSchemaID INT
	--TODO :Replace with dynamic SQL
		--(select distinct de.schemaid 
		-- from dc.[schema] s 
		-- join dc.dataentity de on 
		-- de.schemaid = de.schemaid 
		-- where dataentityname = @SATname )
DECLARE @TargetSATDatabaseID INT
SET @TargetSATDatabaseID = 24
DECLARE @TargetSchemaName VARCHAR(20)
SET @TargetSchemaName = 'raw'

--====================================================================================================
--	Insert the Target Schema in DC (if it does not exist) - the M2MLink db schema is equal to the source system abbreviation,
--	accoarding to the naming convention
--====================================================================================================

SET @TargetSchemaID =
						(
						SELECT	TOP 1 sc.SchemaID
						FROM	DC.[Schema] sc
						WHERE	DatabaseID = @TargetSATDatabaseID
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
		   ,@TargetSATDatabaseID
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
SELECT DISTINCT  ts.TransactionalLinkSATName
				,@TargetSchemaID
				,GETDATE()
FROM	@TSATTemp ts
WHERE NOT EXISTS
	 (SELECT 1
	  FROM	@TSATTemp ts
	  INNER JOIN DC.DataEntity de ON
	  ts.TransactionalLinkSATName = de.DataEntityName
		 AND de.SchemaID = @TargetSchemaID
	  )



--====================================================================================================
--	Updates DataEntityID
--====================================================================================================
UPDATE	sat
SET		TargetDataEntityID = de.DataEntityID
FROM	@TSATTemp sat
INNER JOIN DC.DataEntity de ON sat.TransactionalLinkSATName = de.DataEntityName
	AND de.SchemaID = @TargetSchemaID

DECLARE @StageDEID INT = (SELECT DISTINCT TargetDataEntityID FROM @TSATTemp)

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
DECLARE @InitialSourceDataEntityName VARCHAR(100) = (SELECT DISTINCT InitialSourceDataEntityName FROM @TSATTemp)
INSERT @Fields VALUES
		('HK_'+@InitialSourceDataEntityName,'varchar',40,0,0,-1, GETDATE(), 1, 1),
		('LoadDT','datetime2',8,27,7,-1, GETDATE(), 2, 1),
		('RecSrcDataEntityID','int',4,0,0,-1, GETDATE(), 3, 1)

INSERT INTO @Fields 
SELECT DISTINCT ts.TLinkSatFieldName
			   ,ts.TLinkSatDataType
			   ,ts.TLinkSatMaxLength
			   ,ts.TLinkSatPrecision
			   ,ts.TLinkSatScale
			   ,-1
			   ,GETDATE()
			   ,ts.TLinkFieldSortOrder + 3
			   ,1
FROM @TSATTemp ts	  




SELECT * FROM @FIELDS
DECLARE @TargetDEID INT
SET @TargetDEID = (SELECT DISTINCT TargetDataEntityID from @TSATTemp)
INSERT INTO [DC].[Field] 
		   ([FieldName]
		   ,[DataType]
		   ,[MAXLENGTH]
		   ,[Precision]
		   ,[Scale]
		   ,[DataEntityID]
		   ,[CreatedDT]
		   ,[IsActive]
		   ,[FieldSortOrder] )

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
	

----====================================================================================================
----	Insert the entries into the DC.FieldRelation table (type = 2) for the Data Entity
----====================================================================================================


--INSERT INTO [DC].[FieldRelation]
--		   ([SourceFieldID],
--			[TargetFieldID],
--			[FieldRelationTypeID],
--			[CreatedDT],
--			[IsActive]
--			)
--SELECT DISTINCT [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID](st.TLinkSatFieldID,1)
--	  ,NULL 
--	  ,2
--	  ,GETDATE()
--	  ,1
--FROM @TSATTemp st

GO
