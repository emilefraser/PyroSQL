SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- ====================================================================================================
-- Author:      Peet Horn
-- Create Date: 07 July 2019
-- Description: Creates Hub tables and Relationships between Stage and Hub in DC
-- ====================================================================================================
-- EXEC [DC].[sp_CreateHubTableInDC] 7, 1001

--/*

CREATE PROCEDURE [DC].[sp_CreateHubTableInDC]
	@HubID INT
	, @TargetHUBDatabaseID INT
AS
BEGIN

--*/

/*====================================================================================================
TEST Case 1: 
1.Check what the variables are
SELECT * FROM [DMOD].[Hub] WHERE HUBID = 7
SELECT * FROM DC.DataEntity WHERE DataEntityID = 9641

2.Use a @TargetHUBDatabaseID that does not exist (9999)

3.Run Proc

4.Check if a schema / dataentity / fields where created
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
--DECLARE @HubId int = 51,
--		@TargetHUBDatabaseID int = 3

	DECLARE 
		  @TargetSchemaID         INT
		, @TargetSchemaName       VARCHAR(20)
		, @HUBName                VARCHAR(50)
		--, @HubID INT = 2
		--, @TargetHUBDatabaseID INT = 12

	--SET @TargetSchemaName = (SELECT schemaname FROM dc.[schema] WHERE databaseid = @TargetHUBDatabaseID)

	SET @TargetSchemaName = 'raw';
	SET @HUBName =
	(
		SELECT 
			   h.HubName
		FROM 
			[DMOD].[Hub] AS h
		WHERE h.[hubid] = @HubID
	);

	--	SELECT 
	--		   @HUBName AS [HubName];
	--The Second Parameter is to specify that this is a KEY type table in Staging . TODO: Make this dynamic
	-- DECLARE @BKSourceFieldID INT = [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID](@BKOriginalSourceFieldID,0) 

DROP TABLE IF EXISTS #HubTemp
	CREATE TABLE #HubTemp
	(
	  [Hubname]                 VARCHAR(500)
	, [OriginalName]            VARCHAR(50)
	, [HubDataEntityID]         INT
	, [BKFriendlyName]          VARCHAR(500)
	, [FieldID]                 INT
	, [FieldName]               VARCHAR(500)
	, [DataType]                VARCHAR(50)
	, [MaxLength]               INT
	, [Precision]               INT
	, [Scale]                   INT
	, [FieldSortOrder]          INT
	, [SystemName]              VARCHAR(50)
	--, [
	, [SourceSystemID]    INT   
	  --, [ServerID]		   INT
	, [SchemaID]                INT
	, [DatabaseID]              INT
	, [DataEntityID]            INT
	);
	INSERT INTO #HubTemp
		   SELECT 
				  [HubName]
				, 'HK_' + UPPER(RIGHT([HubName], LEN([HubName]) - 4))
				, [HubDataEntityID]
				, [BKFriendlyName]
				, [f].[FieldID]
				, [f].[FieldName]
				, [DataType]
				, [MaxLength]
				, [Precision]
				, [Scale]
				, [hbk].[FieldSortOrder] + 3
				, [sy].[SystemName]
				, [sy].[SystemID] AS [SourceSystemID]
				, [s].[SchemaID] AS [SchemaID]
				, [db].[DatabaseID] AS [DatbaseID]
				, [de].[DataEntityID]
		   FROM 
				[DMOD].[Hub] AS [h]
		   INNER JOIN
			   [DMOD].[HubBusinessKey] AS [hbk]
			   ON [hbk].[HubID] = [h].[HubID]
		   INNER JOIN
			   [DMOD].[HubBusinessKeyField] AS [hbkf]
			   ON [hbk].[HubBusinessKeyID] = [hbkf].[HubBusinessKeyID]
		   INNER JOIN
			   [DC].[Field] AS [f]
			   ON [f].[FieldID] = [hbkf].[FieldID]
		   INNER JOIN
			   [dc].[DataEntity] AS [de]
			   ON [de].[DataEntityID] = [f].[DataEntityID]
		   INNER JOIN
			   [DC].[Schema] AS [s]
			   ON [s].[SchemaID] = [de].[SchemaID]
		   INNER JOIN
			   [DC].[Database] AS [db]
			   ON [db].[DatabaseID] = [s].[DatabaseID]
		   INNER JOIN
			   [DC].[System] AS [sy]
			   ON [sy].[SystemID] = [db].[SystemID]
		   WHERE [h].[HubID] = @HubID
			AND h.IsActive = 1
			AND hbk.IsActive = 1
			AND hbkf.IsActive = 1;

	--9216
	--@BKOriginalSourceFieldID
	--SELECT [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID](9216,0) 
	--SELECT * FROM DC.Field WHERE FieldID = 9216	SELECT [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID](9216,0) 
	--SELECT * FROM DC.vw_rpt_DatabaseFieldDetail WHERE FieldID = 345244
	--SELECT * FROM #HubTemp;
/*====================================================================================================
-- Update the Data Types based on Data Type Precident so that the biggist data type gets used for the BK columns
====================================================================================================*/


DECLARE @Check_BigInt tinyint = 0

SET		@Check_BigInt = (
							select count(1)
							FROM	#HubTemp ht
							WHERE	ht.DataType ='bigint'
						)

--SELECT	@Check_BigInt

IF @Check_BigInt > 0
BEGIN
	UPDATE	#HubTemp
	SET		DataType = 'bigint'
			, [MaxLength] = 8
			, [Precision] = 19
			, [Scale] = 0
	WHERE	DataType = 'int'
END

DECLARE @Check_DistinctDataTypes tinyint = 0

SET	@Check_DistinctDataTypes = (select distinct count(1) FROM #HubTemp ht)

IF @Check_DistinctDataTypes > 1
BEGIN
	PRINT CHAR(13)
	PRINT CHAR(13)

	PRINT 'Not all Business Key columns have the same data type - please check this!!!'
	PRINT 'HubID = ' + Convert(varchar, @HubID)

	PRINT CHAR(13)
	PRINT CHAR(13)
END 

/*====================================================================================================
Insert the Target Schema in DC (if it does not exist) - the HUB db schema is equal to the source system abbreviation,
accoarding to the naming convention
====================================================================================================*/

	SET @TargetSchemaID =
	(
		SELECT TOP 1 
			   [sc].[SchemaID]
		FROM 
			[DC].[Schema] AS [sc]
		WHERE
					[DatabaseID] = @TargetHUBDatabaseID
					AND [SchemaName] = @TargetSchemaName
	);
	--EXPECT @TargetSchemaID = 131
	--SELECT TOP 1 sc.SchemaID FROM	DC.[Schema] sc WHERE	DatabaseID = 48 AND SchemaName = 'RAW'
	--TEST NULL INSERT BY MAKING @TargetHUBDatabaseID = 9999
	--THEN SELECT * FROM DC.[SCHEMA] WHERE DATABASEID = 9999 AFTER THE INSERT RAN
	--SELECT 
	--	   @TargetSchemaID AS [TargetSchema];

	IF @TargetSchemaID IS NULL
	BEGIN
		INSERT INTO [DC].[Schema]
		(
			   [SchemaName]
			 , [DatabaseID]
			 , [DBSchemaID]
			 , [CreatedDT]
		)
		(
			SELECT 
				   @TargetSchemaName
				 , @TargetHUBDatabaseID
				 , NULL
				 , GETDATE()
		);
	END;
	IF @TargetSchemaID IS NULL
	BEGIN
		SET @TargetSchemaID = @@IDENTITY;
	END;

	--	SELECT 
	--	   @TargetSchemaID AS [TargetSchema];
	--====================================================================================================
	--	Copy the structure of the Source Data Entity into DataEntity table in DC (if it does not exist)
	--====================================================================================================

	--DECLARE 
	--	   @ID TABLE
	--(
	--  [ID]    INT
	--);

	INSERT INTO [DC].[DataEntity]
	(
		   [DataEntityName]
		 , [SchemaID]
		 , [CreatedDT]
		 , [DataEntityTypeID]
	)
	select	distinct  Hubname
					, @TargetSchemaID
					, GETDATE()
					, [DataEntityTypeID] = 
						CASE WHEN Hubname like 'REF%'
							THEN [DC].[udf_get_DataEntityTypeID]('REF')
							ELSE [DC].[udf_get_DataEntityTypeID]('HUB')
						END 
	from	#HubTemp
	WHERE NOT EXISTS 
	(
		SELECT	1
		FROM 
				[dc].[DataEntity]
		WHERE
				[DataEntityName] = @Hubname
				AND [SchemaID] = @TargetSchemaID
	)
	
	
	-- Get newly inserted SchemaID
	DECLARE @NewDataEntityID INT
	SET @NewDataEntityID = @@IDENTITY

	--2019-08-03 21:40: Commented out by FG, because of performance issues
	--OUTPUT 
	--	   [inserted].[DataEntityID]
	--	   INTO @ID

	--	   SELECT TOP 1 
	--			  @Hubname
	--			, @TargetSchemaID
	--			, GETDATE()
	--	   FROM 
	--		   [DC].[DataEntity]
	--	   WHERE NOT EXISTS
	--	   (
	--		   SELECT 1
	--		   FROM 
	--			   [dc].[DataEntity]
	--		   WHERE
	--					   [DataEntityName] = @Hubname
	--					   AND [SchemaID] = @TargetSchemaID
	--	   );
	
	--DECLARE 
	--	   @NewDataEntityID    INT =
	--(
	--	SELECT TOP 1 
	--		   [ID] FROM 
	--		@ID
	--);
	
	IF @NewDataEntityID IS NULL
	BEGIN
		SELECT 
			   @NewDataEntityID = [DataEntityID]
		FROM 
			[dc].[DataEntity]
		WHERE
					[DataEntityName] = @HubName
					AND [SchemaID] = @TargetSchemaID;
	END;

	--	SELECT 
	--		   @NewDataEntityID AS [NewDataEntityID];
	--SELECT * FROM  [DC].[DataEntity] WHERE DataEntityID = @NewDataEntityID
	--====================================================================================================
	--	Copy the structure of the Source Data Entity into Fields table in DC (if it does not exist) and
	--	insert the additional HUB Fields (if it does not exist) 
	--====================================================================================================
	DECLARE 
		   @BusinessKeyFriendlyName    VARCHAR(50);
	SET @BusinessKeyFriendlyName =
	(
		SELECT TOP 1 
			   [BKFriendlyname]
		FROM 
			#HubTemp
	);

	--	SELECT 
	--		   @BusinessKeyFriendlyName AS [BusinessKeyFriendlyName];
	--Insert standard staging fields (use sort orders 1 to 5)							
	
	drop table if exists [#HubFields]
	CREATE TABLE [#HubFields]
	(
	  [FieldName]         VARCHAR(1000)
	, [DataType]          VARCHAR(500)
	, [MAXLENGTH]         INT
	, [Precision]         INT
	, [Scale]             INT
	, [DataEntityID]      INT
	, [CreatedDt]         DATETIME2(7)
	, [FieldSortOrder]    INT
	, [IsActive]          INT
	);
	DECLARE 
		   @OriginalName    VARCHAR(1000) =
	(
		SELECT TOP 1 
			   [OriginalName]
		FROM 
			#HubTemp
	);
	INSERT INTO [#HubFields]
	(
		   [FieldName]
		 , [DataType]
		 , [MAXLENGTH]
		 , [Precision]
		 , [Scale]
		 , [DataEntityID]
		 , [CreatedDt]
		 , [FieldSortOrder]
		 , [IsActive]
	)
	VALUES
	(
		   @OriginalName
		 , 'varchar'
		 , 40
		 , 0
		 , 0
		 , @NewDataEntityID
		 , GETDATE()
		 , 1
		 , 1
	),
	(
		   'LoadDT'
		 , 'datetime2'
		 , 8
		 , 27
		 , 7
		 , @NewDataEntityID
		 , GETDATE()
		 , 2
		 , 1
	),
	(
		   'RecSrcDataEntityID'
		 , 'int'
		 , 4
		 , 0
		 , 0
		 , @NewDataEntityID
		 , GETDATE()
		 , 3
		 , 1
	);

	--	Add Business Key Fields to #HubFields

	INSERT INTO [#HubFields]
	SELECT 
		  [ht].[BKFriendlyName]
		, MAX([DataType]) AS [DataType]
		, MAX([MaxLength]) AS [MaxLength]
		, MAX([Precision]) AS [Precision]
		, MAX([Scale]) AS [Scale]
		, @NewDataEntityID
		, GETDATE()
		, [FieldSortOrder]
		, 1
	FROM 
		#HubTemp AS [ht]
	GROUP BY
		[ht].[BKFriendlyName]
		, [FieldSortOrder];


	INSERT INTO [#HubFields]
	VALUES
	(
		   'LastSeenDT'
		 , 'datetime2'
		 , 8
		 , 27
		 , 7
		 , @NewDataEntityID
		 , GETDATE()
		 ,
	(
		SELECT 
			   MAX([FieldSortOrder]) + 1
		FROM 
			#HubTemp
	)
		 , 1
	);

	--SELECT @NewDataEntityID

	--SELECT * FROM [#HubFields]

	----====================================================================================================
	----	Insert the entries into the DC.Field table for the Data Entity
	----====================================================================================================

	INSERT INTO [DC].[Field]
	(
		   [FieldName]
		 , [DataType]
		 , [MAXLENGTH]
		 , [Precision]
		 , [Scale]
		 , [DataEntityID]
		 , [CreatedDT]
		 , [IsActive]
		 , [FieldSortOrder]
	)
		   SELECT 
				  [FieldName]
				, [DataType]
				, [MAXLENGTH]
				, [Precision]
				, [Scale]
				, @NewDataEntityID
				, GETDATE()
				, 1
				, [FieldSortOrder]
		   FROM 
			   [#HUBFields]
		   WHERE [FieldName] NOT IN
		   (
			   SELECT 
					  [FieldName]
			   FROM 
				   [DC].[Field]
			   WHERE [DataEntityID] = @NewDataEntityID
		   );




	----====================================================================================================
	----	Insert the entries into the DC.FieldRelation table (type = 2) for the Data Entity
	----====================================================================================================

	INSERT INTO [DC].[FieldRelation] ([SourceFieldID], [TargetFieldID], [FieldRelationTypeID], [CreatedDT], [IsActive])
	SELECT DISTINCT
		sf.FieldID AS StageFieldID
		, vbkf.FieldID AS VaultFieldID
		, 2
		, GetDate()
		, 1
	FROM
		#HubTemp ht
			INNER JOIN DC.Field sf ON DC.udf_get_StageLevelBKFieldID_FromSourceBKFieldID (ht.FieldID, 0) = sf.FieldID
			INNER JOIN DC.Field vbkf ON ht.BKFriendlyName = vbkf.FieldName
			LEFT OUTER JOIN DC.FieldRelation fr ON sf.FieldID = fr.SourceFieldID AND vbkf.FieldID = fr.TargetFieldID
	WHERE
		vbkf.DataEntityID = @NewDataEntityID
		AND fr.SourceFieldID IS NULL
	UNION ALL
	SELECT DISTINCT
		sf.FieldID AS StageFieldID
		, vhkf.FieldID AS VaultFieldID
		, 2
		, GetDate()
		, 1
	FROM
		#HubTemp ht
			INNER JOIN DC.Field sf ON DC.udf_get_StageLevelBKHashFieldID_FromSourceFieldID (ht.FieldID, 0) = sf.FieldID
			INNER JOIN DC.Field vhkf ON ht.OriginalName = vhkf.FieldName
			LEFT OUTER JOIN DC.FieldRelation fr ON sf.FieldID = fr.SourceFieldID AND vhkf.FieldID = fr.TargetFieldID
	WHERE
		vhkf.DataEntityID = @NewDataEntityID
		AND fr.SourceFieldID IS NULL


	--DROP TABLE [#HUBFields];


END;

GO
