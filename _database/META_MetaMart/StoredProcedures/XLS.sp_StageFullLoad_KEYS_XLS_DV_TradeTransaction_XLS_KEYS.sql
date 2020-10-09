SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

--===============================================================================================================================
--Stored Proc Template Version Control --TODO: Ensure this section gets updated when generating a load template
--===============================================================================================================================
--!~ LoadTypeInfo
/*
	Template Version No.:                       |   V 2.00
	Template last update date:                  |   2019-09-15T17:28:22.6866667
	Template load Type code:                    |   StageFullLoad_KEYS
	Template load Type description:             |   Standard
	Template Author:                            |   Thuto Sephaphati
	Stored Proc Create Date:                    |   2019-09-19T17:28:34.957
*/
-- End of LoadTypeInfo ~!

--===============================================================================================================================
--Logging conventions - NOTES TO THE DEVELOPER!
--===============================================================================================================================
--!~ Logging Convention Notes /*  */ -- End of Logging Convention Notes ~!

/*
	TRUNCATE TABLE [XLS].[DV_TradeTransaction_XLS_KEYS]
	TRUNCATE TABLE [XLS].[DV_TradeTransaction_XLS_KEYS_Hist]

	DECLARE @Today DATETIME2(7) = (SELECT GETDATE())
	DECLARE @IsInitialLoad BIT = 1
	DECLARE @IsTest BIT = 0

	EXEC [XLS].[sp_StageFullLoad_KEYS_XLS_DV_TradeTransaction_XLS_KEYS] @Today, @IsInitialLoad, @IsTest
*/
CREATE   PROCEDURE [XLS].[sp_StageFullLoad_KEYS_XLS_DV_TradeTransaction_XLS_KEYS]
    @Today DATETIME2(7),
    @IsInitialLoad BIT = 0,
    @IsTest BIT = 0
AS

BEGIN TRY  

/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
--Stored Proc Management
--===============================================================================================================================
--Variable workbench
--===============================================================================================================================
--Stored Proc Variabled	

--Log Variables
DECLARE		  @ExecutionLogID INT
			, @StepStartDT DATETIME2(7)
			, @StepFinishDT DATETIME2(7)
			, @StepDuration INT
			, @StepAffectedRowCount INT 
			, @DatabaseName VARCHAR(100)
			, @SchemaName VARCHAR(100)
--!~ LoadConfigID
			, @LoadConfigID int = 14
-- End of LoadConfigID ~!
			, @StartDate DATETIME2(7) = GETDATE()
			, @DataEntityName VARCHAR(100) = '[vw_dmod_TradeTransaction]' --Target Data Entity
			, @SourceRowCount INT
			, @SourceSizeBytes INT
			, @PreLoadTargetRowCount INT
			, @PreLoadTargetSizeBytes INT						
			, @PostLoadTargetRowCount INT	
	        , @PostLoadTargetSizeBytes INT

--========================= USED TO GET TABLE SIZE
DECLARE @sql AS NVARCHAR(MAX)

DECLARE @SpaceUsed TABLE (
    [name] varchar(255), 
    [rows] int, 
    [reserved] int)

--*******************************************************************************************************************************
--ETL Logging - Start Execution
--*******************************************************************************************************************************
--Start the logging process for this stored proc
SELECT		  @DatabaseName = QUOTENAME(DB_NAME())
			, @SchemaName = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID))

			--Start the logging process for this stored proc
			EXEC [DataManager].[ETL].[sp_insert_ExecutionLog]
							  @DatabaseName = @DatabaseName
							, @SchemaName = @SchemaName
			/*User Input*/	, @swStart_FinishLogEntry = 1
							, @ExecutionLogID_In = NULL
							, @ExecutionLogID_Out = @ExecutionLogID OUTPUT
							, @LoadConfigID = @LoadConfigID
							, @QueuedForProcessingDT = @StartDate
							, @LastProcessingKeyValue = NULL
							, @IsReload = NULL
							, @ErrorMessage = NULL
							, @DataEntityName = @DataEntityName

							
/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

--===============================================================================================================================
--Get MAX(LoadDT) FROM Sat - simulate
--===============================================================================================================================

--************** LOGGING **************--
SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
--************** LOGGING **************--

DECLARE @DV_LastLoadDT DATETIME2(7) = 
(
	SELECT MAX(A.[MaxDate])
	FROM 
	(
			SELECT ISNULL(MAX(CONVERT(DATETIME2(7), [LoadDT])),'1900-01-01 00:00:00.0000000') AS MaxDate 
				FROM [DEV_DataVault].[raw].[HUB_TradeTransaction] --TODO: Doc : DC must be correct and how to check that (include query)
			UNION ALL
			SELECT ISNULL(MAX(CONVERT(DATETIME2(7), [LoadDT])),'1900-01-01 00:00:00.0000000') AS MaxDate 
				FROM [XLS].[DV_TradeTransaction_XLS_KEYS_Hist] --TODO: Doc : DC must be correct and how to check that (include query) step by step troubleshooting
	) A
)

--************** LOGGING **************--

SET		@StepAffectedRowCount = @@ROWCOUNT
SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

-- Source Counts (ODS)
SET @sql = (SELECT [DataManager].[DC].[udf_get_TableSpaceAndRows]('[DEV_ODS_CSV]', PARSENAME('[DV]',1), PARSENAME('[vw_dmod_TradeTransaction]',1)))
INSERT INTO @SpaceUsed
EXEC sp_executesql @sql

SET @SourceRowCount = (SELECT [rows] FROM @SpaceUsed)
SET @SourceSizeBytes = (SELECT [reserved] FROM @SpaceUsed)

DELETE FROM @SpaceUsed

-- Destination Counts (Stage)
SET @sql = (SELECT [DataManager].[DC].[udf_get_TableSpaceAndRows]('[DEV_Stage]', PARSENAME('[XLS]',1), PARSENAME('[DV_TradeTransaction_XLS_KEYS]',1)))
INSERT INTO @SpaceUsed
EXEC sp_executesql @sql

SET @PreLoadTargetRowCount = (SELECT [rows] FROM @SpaceUsed)
SET @PreLoadTargetSizeBytes = (SELECT [reserved] FROM @SpaceUsed)

DELETE FROM @SpaceUsed

EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps]
				 @ExecutionLogID = @ExecutionLogID
/*User Input*/	,@StepDescription = 'Get last load date from [DEV_DataVault].[raw].[HUB_TradeTransaction] and [XLS].[DV_TradeTransaction_XLS_KEYS_Hist]'
/*User Input*/	,@AffectedDatabaseName = '[DEV_DataVault] & [DEV_Stage]'
/*User Input*/	,@AffectedSchemaName = '[raw] & [XLS]'
/*User Input*/	,@AffectedDataEntityName = '[HUB_TradeTransaction] & [DV_TradeTransaction_XLS_KEYS_Hist]'
/*User Input*/	,@ActionPerformed = 'SELECT'
				,@StartDT = @StepStartDT
				,@FinishDT = @StepFinishDT
				,@DurationSeconds = @StepDuration
				,@AffectedRecordCount = @StepAffectedRowCount
				,@ExecutionStepNo = 1

-- Set the start time of the following step 
SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
--************** LOGGING **************--
	
-- EF Checks if temp tables exists and drops them if they do
DROP TABLE IF EXISTS [#LoadSetsXLS_DV_TradeTransaction_XLS_KEYS]
DROP TABLE IF EXISTS [#LoadComparison_XLS_DV_TradeTransaction_XLS_KEYS]
DROP TABLE IF EXISTS [#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS]

--===============================================================================================================================
--Truncate [DEV_Stage] table for new stage load
--===============================================================================================================================

TRUNCATE TABLE [XLS].[DV_TradeTransaction_XLS_KEYS]

--************** LOGGING **************--
SET		@StepAffectedRowCount = @@ROWCOUNT
SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps]
				 @ExecutionLogID = @ExecutionLogID
/*User Input*/	,@StepDescription = 'Truncate table - [XLS].[DV_TradeTransaction_XLS_KEYS]'
/*User Input*/	,@AffectedDatabaseName = '[DEV_Stage]'
/*User Input*/	,@AffectedSchemaName = '[XLS]'
/*User Input*/	,@AffectedDataEntityName = '[DV_TradeTransaction_XLS_KEYS]'
/*User Input*/	,@ActionPerformed = 'TRUNCATE'
				,@StartDT = @StepStartDT
				,@FinishDT = @StepFinishDT
				,@DurationSeconds = @StepDuration
				,@AffectedRecordCount = @StepAffectedRowCount
				,@ExecutionStepNo = 1000 -- Functionality of increment built INTo step, 1000 only there to fill the variable
	
-- Set the start time of the following step 
SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
--************** LOGGING **************--

--===============================================================================================================================
--Get load sets AND last successfull load that went INTO the table
--===============================================================================================================================

SELECT 
    LoadDT, ROW_NUMBER() OVER (ORDER BY LoadDT) AS RowID
INTO	
    [#LoadSetsXLS_DV_TradeTransaction_XLS_KEYS]
FROM 
    [XLS].[DV_TradeTransaction_XLS_KEYS_Hist]
WHERE	
    [LoadDT] >= (
				SELECT
					MAX(LoadDT)
				FROM 
					[XLS].[DV_TradeTransaction_XLS_KEYS_Hist]
				WHERE 
				    [LoadDT] <= @DV_LastLoadDT
				)
GROUP BY 
    [LoadDT]

	--TODO: Create Standard Index for temptable LoadSets

--************** LOGGING **************--
SET		@StepAffectedRowCount = @@ROWCOUNT
SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps] 
				@ExecutionLogID = @ExecutionLogID
/*User Input*/	,@StepDescription = 'Get load sets AND last successfull load that went INTO the table'
/*User Input*/	,@AffectedDatabaseName = '[tempdb]'
/*User Input*/	,@AffectedSchemaName = '[dbo]'
/*User Input*/	,@AffectedDataEntityName = '[#LoadSetsXLS_DV_TradeTransaction_XLS_KEYS]'
/*User Input*/	,@ActionPerformed = 'SELECT'
				,@StartDT = @StepStartDT
				,@FinishDT = @StepFinishDT
				,@DurationSeconds = @StepDuration
				,@AffectedRecordCount = @StepAffectedRowCount
				,@ExecutionStepNo = 1000

-- Set the start time of the following step 
SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
--************** LOGGING **************--

--===============================================================================================================================
--Create compare Load sets temp table
--===============================================================================================================================

SELECT 
    loadsets.[LoadDT] AS LoadSetDate
	, loadsets.[RowID] AS LoadSetRowID
	, compareset.[LoadDT] AS CompareSetDate
	, compareset.[RowID] AS CompareSetRowID
INTO	
    [#LoadComparison_XLS_DV_TradeTransaction_XLS_KEYS]
FROM 
    [#LoadSetsXLS_DV_TradeTransaction_XLS_KEYS] loadsets
LEFT JOIN 
    [#LoadSetsXLS_DV_TradeTransaction_XLS_KEYS] compareset 
    ON loadsets.[RowID] = compareset.[RowID] + 1
WHERE	
    1=1

--************** LOGGING **************--
SET		@StepAffectedRowCount = @@ROWCOUNT
SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps] 
				@ExecutionLogID = @ExecutionLogID
/*User Input*/	,@StepDescription = 'Create compare Load sets temp table'
/*User Input*/	,@AffectedDatabaseName = '[tempdb]'
/*User Input*/	,@AffectedSchemaName = '[dbo]'
/*User Input*/	,@AffectedDataEntityName = '[#LoadComparison_XLS_DV_TradeTransaction_XLS_KEYS]'
/*User Input*/	,@ActionPerformed = 'SELECT'
				,@StartDT = @StepStartDT
				,@FinishDT = @StepFinishDT
				,@DurationSeconds = @StepDuration
				,@AffectedRecordCount = @StepAffectedRowCount
				,@ExecutionStepNo = 1000
	
 --Set the start time of the following step 
SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
--************** LOGGING **************--

--===============================================================================================================================
--Union/Insert the current load FROM ODS with the history load set dates
--===============================================================================================================================

INSERT INTO [#LoadComparison_XLS_DV_TradeTransaction_XLS_KEYS]
(
      LoadSetDate
    , LoadSetRowID
    , CompareSetDate
    , CompareSetRowID
)
SELECT 
    CASE WHEN @IsInitialLoad = 1 THEN '1900/01/01 00:00:00' ELSE @Today END AS LoadSetDate
    , MAX([LoadSetRowID]) + 1 AS LoadSetRowID
    , MAX([LoadSetDate]) AS CompareSetDate
    , MAX([LoadSetRowID]) AS CompareSetRowID
FROM 
    [#LoadComparison_XLS_DV_TradeTransaction_XLS_KEYS]


	--TODO Create Standard Index for temptable LoadComparison

	--************** LOGGING **************--
	SET		@StepAffectedRowCount = @@ROWCOUNT
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps]
					@ExecutionLogID = @ExecutionLogID
	/*User Input*/	,@StepDescription = 'Union/Insert the current load FROM ODS with the history load set dates'
	/*User Input*/	,@AffectedDatabaseName = '[tempdb]'
	/*User Input*/	,@AffectedSchemaName = '[dbo]'
	/*User Input*/	,@AffectedDataEntityName = '[#LoadComparison_XLS_DV_TradeTransaction_XLS_KEYS]'
	/*User Input*/	,@ActionPerformed = 'INSERT'
					,@StartDT = @StepStartDT
					,@FinishDT = @StepFinishDT
					,@DurationSeconds = @StepDuration
					,@AffectedRecordCount = @StepAffectedRowCount
					,@ExecutionStepNo = 1000
	
	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--

--===============================================================================================================================
--Get source data (UNION Current ODS with History Load Sets)
--===============================================================================================================================

--TODO: Replace with in memory table
CREATE TABLE [#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS]
(
    [BKHash] [VARCHAR](40) NOT NULL,
    [LoadDT] [DATETIME2](7) NOT NULL,
    [RecSrcDataEntityID] [INT] NULL,
--!~ Field list for CREATE TABLE - Stage
			[Id] [int],
			[Trade Partner] [varchar](250),
			[Port of Entry] [varchar](250),
			[Trade Type] [varchar](10),
			[Tariff Code] [varchar](50),
			[Purpose Code] [varchar](250),
			[Date] [datetime],
			[HK_TradePartner] [varchar](40),
			[LINKHK_TradePartner_TradeTransaction] [varchar](40),
			[HK_TradePortOfEntry] [varchar](40),
			[LINKHK_TradePortOfEntry_TradeTransaction] [varchar](40),
			[HK_TradeType] [varchar](40),
			[LINKHK_TradeType_TradeTransaction] [varchar](40),
			[HK_TradeProduct] [varchar](40),
			[LINKHK_TradeProduct_TradeTransaction] [varchar](40),
			[HK_TradePurposeCode] [varchar](40),
			[LINKHK_TradePurposeCode_TradeTransaction] [varchar](40)
-- End of Field List for CREATE TABLE Stage ~!
)

--INSERT data INTO the Temp Variable table
INSERT INTO [#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS]
    (
      [BKHash]
    , [LoadDT]
    , [RecSrcDataEntityID]
    ,
 --!~ Field List with no alias - Stage				[Id],				[Trade Partner],				[Port of Entry],				[Trade Type],				[Tariff Code],				[Purpose Code],				[Date],				[HK_TradePartner],				[LINKHK_TradePartner_TradeTransaction],				[HK_TradePortOfEntry],				[LINKHK_TradePortOfEntry_TradeTransaction],				[HK_TradeType],				[LINKHK_TradeType_TradeTransaction],				[HK_TradeProduct],				[LINKHK_TradeProduct_TradeTransaction],				[HK_TradePurposeCode],				[LINKHK_TradePurposeCode_TradeTransaction]-- End of Field List with no alias - Stage ~!
    )
--Get all history loads
    SELECT 
		  [StandardAlias1].[BKHash]
		, [StandardAlias1].[LoadDT]
		, [StandardAlias1].[RecSrcDataEntityID], --TODO: Discuss how this ID works and needs to be generated 
--!~ Field List with alias - Stage				[StandardAlias1].[Id],				[StandardAlias1].[Trade Partner],				[StandardAlias1].[Port of Entry],				[StandardAlias1].[Trade Type],				[StandardAlias1].[Tariff Code],				[StandardAlias1].[Purpose Code],				[StandardAlias1].[Date],				[StandardAlias1].[HK_TradePartner],				[StandardAlias1].[LINKHK_TradePartner_TradeTransaction],				[StandardAlias1].[HK_TradePortOfEntry],				[StandardAlias1].[LINKHK_TradePortOfEntry_TradeTransaction],				[StandardAlias1].[HK_TradeType],				[StandardAlias1].[LINKHK_TradeType_TradeTransaction],				[StandardAlias1].[HK_TradeProduct],				[StandardAlias1].[LINKHK_TradeProduct_TradeTransaction],				[StandardAlias1].[HK_TradePurposeCode],				[StandardAlias1].[LINKHK_TradePurposeCode_TradeTransaction]-- End of Field List with alias - Stage ~!
    FROM 
		[XLS].[DV_TradeTransaction_XLS_KEYS_Hist] StandardAlias1
    WHERE	
		LoadDT >= (SELECT MIN([LoadSetDate])
    FROM 
		[#LoadComparison_XLS_DV_TradeTransaction_XLS_KEYS])

-- Quick or Test Load, when @IsTest = 1
-- If a test is run on the initial dataset (FACT tables only), first do a test on top 10000 records before full loading
IF @IsTest = 1
	SET ROWCOUNT 10000

	INSERT INTO [#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS]
    (
     [BKHash]
    ,[LoadDT]
    ,[RecSrcDataEntityID]
    ,
 --!~ Field List with no alias - Stage				[Id],				[Trade Partner],				[Port of Entry],				[Trade Type],				[Tariff Code],				[Purpose Code],				[Date],				[HK_TradePartner],				[LINKHK_TradePartner_TradeTransaction],				[HK_TradePortOfEntry],				[LINKHK_TradePortOfEntry_TradeTransaction],				[HK_TradeType],				[LINKHK_TradeType_TradeTransaction],				[HK_TradeProduct],				[LINKHK_TradeProduct_TradeTransaction],				[HK_TradePurposeCode],				[LINKHK_TradePurposeCode_TradeTransaction]-- End of Field List with no alias - Stage ~!
    )

    --Get current state of data FROM the ODS
    SELECT
--!~ StageArea BK Hash Column Calculation from ODS CONVERT(VARCHAR(40),					 HASHBYTES ('SHA1',						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Id]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Trade Partner]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Port of Entry]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Trade Type]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Tariff Code]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Purpose Code]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Date]))),''))						 )					 ,2) AS BKHash-- End of StageArea BK Hash Column Calculation from ODS ~!
		, LoadDT = CASE WHEN @IsInitialLoad = 1 THEN '1900/01/01 00:00:00' ELSE @Today END 
--!~ RecSrcDataEntityID				 , 706 AS [RecSrcDataEntityID] , -- End of RecSrcDataEntityID ~!
--!~ Field List with alias - ODS [StandardAlias1].[Id], [StandardAlias1].[Trade Partner], [StandardAlias1].[Port of Entry], [StandardAlias1].[Trade Type], [StandardAlias1].[Tariff Code], [StandardAlias1].[Purpose Code], [StandardAlias1].[Date]-- End of Field List with alias - ODS ~!
--!~ Hub & Link Hash Key Columns for ODS Select, CONVERT(VARCHAR(40),					 HASHBYTES ('SHA1',						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias2].[Trade Partner]))),'NA')) 						 )					 ,2) AS [HK_TradePartner], CONVERT(VARCHAR(40),					 HASHBYTES ('SHA1',						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias2].[Trade Partner]))),'NA')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Id]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Trade Partner]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Port of Entry]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Trade Type]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Tariff Code]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Purpose Code]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Date]))),''))						 )					 ,2) AS [LINKHK_TradePartner_TradeTransaction], CONVERT(VARCHAR(40),					 HASHBYTES ('SHA1',						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias3].[Port of Entry]))),'NA')) 						 )					 ,2) AS [HK_TradePortOfEntry], CONVERT(VARCHAR(40),					 HASHBYTES ('SHA1',						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias3].[Port of Entry]))),'NA')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Id]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Trade Partner]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Port of Entry]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Trade Type]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Tariff Code]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Purpose Code]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Date]))),''))						 )					 ,2) AS [LINKHK_TradePortOfEntry_TradeTransaction], CONVERT(VARCHAR(40),					 HASHBYTES ('SHA1',						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias4].[Trade Type]))),'NA')) 						 )					 ,2) AS [HK_TradeType], CONVERT(VARCHAR(40),					 HASHBYTES ('SHA1',						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias4].[Trade Type]))),'NA')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Id]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Trade Partner]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Port of Entry]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Trade Type]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Tariff Code]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Purpose Code]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Date]))),''))						 )					 ,2) AS [LINKHK_TradeType_TradeTransaction], CONVERT(VARCHAR(40),					 HASHBYTES ('SHA1',						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias5].[Tariff Code]))),'NA'))  + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias5].[Product Name]))),'NA')) 						 )					 ,2) AS [HK_TradeProduct], CONVERT(VARCHAR(40),					 HASHBYTES ('SHA1',						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias5].[Tariff Code]))),'NA')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias5].[Product Name]))),'NA')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Id]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Trade Partner]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Port of Entry]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Trade Type]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Tariff Code]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Purpose Code]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Date]))),''))						 )					 ,2) AS [LINKHK_TradeProduct_TradeTransaction], CONVERT(VARCHAR(40),					 HASHBYTES ('SHA1',						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias6].[Purpose Code]))),'NA')) 						 )					 ,2) AS [HK_TradePurposeCode], CONVERT(VARCHAR(40),					 HASHBYTES ('SHA1',						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias6].[Purpose Code]))),'NA')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Id]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Trade Partner]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Port of Entry]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Trade Type]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Tariff Code]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Purpose Code]))),'')) + '|' +						  CONVERT	(VARCHAR(MAX),							  COALESCE(UPPER(LTRIM(RTRIM([StandardAlias1].[Date]))),''))						 )					 ,2) AS [LINKHK_TradePurposeCode_TradeTransaction]-- End of Hub & Link Hash Key Columns for ODS Select ~!
    FROM 
		[DEV_ODS_CSV].[DV].[vw_dmod_TradeTransaction] AS [StandardAlias1]
			--!~ Hub & Link table joins for ODS Select
			 LEFT JOIN [DEV_ODS_CSV].[DV].[vw_dmod_TradePartner] AS StandardAlias2
				 ON StandardAlias2.[Trade Partner] = StandardAlias1.[Trade Partner]
			 LEFT JOIN [DEV_ODS_CSV].[DV].[vw_dmod_TradePortOfEntry] AS StandardAlias3
				 ON StandardAlias3.[Port of Entry] = StandardAlias1.[Port of Entry]
			 LEFT JOIN [DEV_ODS_CSV].[DV].[vw_dmod_TradeType] AS StandardAlias4
				 ON StandardAlias4.[Trade Type] = StandardAlias1.[Trade Type]
			 LEFT JOIN [DEV_ODS_CSV].[DV].[vw_dmod_TradeProduct] AS StandardAlias5
				 ON StandardAlias5.[Tariff Code] = StandardAlias1.[Tariff Code]
				 AND StandardAlias5.[Product Name] = StandardAlias1.[Product Name]
			 LEFT JOIN [DEV_ODS_CSV].[DV].[vw_dmod_TradePurposeCode] AS StandardAlias6
				 ON StandardAlias6.[Purpose Code] = StandardAlias1.[Purpose Code]
			-- End of Hub & Link table joins for ODS Select ~!
	ORDER BY 1



-- RESTORE ROWCOUNT TO 0, ie all rows to get returned 
IF @IsTest = 1
	SET ROWCOUNT 0

--************** LOGGING **************--
	SET		@StepAffectedRowCount = @@ROWCOUNT
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)


	EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps]
					@ExecutionLogID = @ExecutionLogID
	/*User Input*/	,@StepDescription = 'Get source data (UNION Current ODS with History Load Sets)'
	/*User Input*/	,@AffectedDatabaseName = '[tempdb]'
	/*User Input*/	,@AffectedSchemaName = '[dbo]'
	/*User Input*/	,@AffectedDataEntityName = '[#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS]'
	/*User Input*/	,@ActionPerformed = 'INSERT'
					,@StartDT = @StepStartDT
					,@FinishDT = @StepFinishDT
					,@DurationSeconds = @StepDuration
					,@AffectedRecordCount = @StepAffectedRowCount
					,@ExecutionStepNo = 1000
	
	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--

	--Create indexes on temp table as a standard
	ALTER TABLE [#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS] ADD CONSTRAINT [PK_XLS_DV_TradeTransaction_XLS_KEYS] 
	PRIMARY KEY CLUSTERED 
	(
		[BKHash] ASC,
		[LoadDT] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
	ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [ncidx_XLS_DV_TradeTransaction_XLS_KEYS] 
	ON [#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS]
	(
		[LoadDT] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
	ON [PRIMARY]

	
	--************** LOGGING **************--
	SET		@StepAffectedRowCount = @@ROWCOUNT
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps]
					@ExecutionLogID = @ExecutionLogID
	/*User Input*/	,@StepDescription = 'Create Index on [#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS])'
	/*User Input*/	,@AffectedDatabaseName = '[tempdb]'
	/*User Input*/	,@AffectedSchemaName = '[dbo]'
	/*User Input*/	,@AffectedDataEntityName = '[#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS]'
	/*User Input*/	,@ActionPerformed = 'INDEX CREATE'
					,@StartDT = @StepStartDT
					,@FinishDT = @StepFinishDT
					,@DurationSeconds = @StepDuration
					,@AffectedRecordCount = @StepAffectedRowCount
					,@ExecutionStepNo = 1000
	
	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--

--===============================================================================================================================
--Check for information that was added OR updated by comparing the load sets to each other via the staggered [#LoadComparison_XLS_DV_TradeTransaction_XLS_KEYS] table
--===============================================================================================================================
--If this is the 1st load of the table - then load straight INTo stage table, do not compare
--Get the row count of the history table to determine fif this is the 1st load

--===============================================================================================================================
--Get row count from [XLS].[DV_TradeTransaction_XLS_KEYS_Hist] to determine further logic
--===============================================================================================================================

DECLARE @HistoryRowCount AS INT
DECLARE @CurrentLoadHasRecords AS BIT

SELECT 
    @HistoryRowCount = COUNT(1)
FROM 
    [XLS].[DV_TradeTransaction_XLS_KEYS_Hist]

--************** LOGGING **************--
SET		@StepAffectedRowCount = @@ROWCOUNT
SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT) --TODO: Move to the logging proc

EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps]
				@ExecutionLogID = @ExecutionLogID
/*User Input*/	,@StepDescription = 'Get row count from [XLS].[DV_TradeTransaction_XLS_KEYS_Hist] to determine further logic'
/*User Input*/	,@AffectedDatabaseName = '[StageArea]'
/*User Input*/	,@AffectedSchemaName = '[XLS]'
/*User Input*/	,@AffectedDataEntityName = '[DV_TradeTransaction_XLS_KEYS_Hist]'
/*User Input*/	,@ActionPerformed = 'COUNT'
				,@StartDT = @StepStartDT
				,@FinishDT = @StepFinishDT
				,@DurationSeconds = @StepDuration
				,@AffectedRecordCount = @StepAffectedRowCount
				,@ExecutionStepNo = 1000
	
-- Set the start time of the following step 
SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--

--===============================================================================================================================
--Determine if the current load from ODS has record
--===============================================================================================================================

SET	@CurrentLoadHasRecords = 
(
	CASE 
		WHEN	(	
					SELECT 
						COUNT(1)
					FROM 
						[#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS]
					WHERE	
						[LoadDT] =   CASE WHEN @IsInitialLoad = 1 
											THEN '1900/01/01 00:00:00' 
											ELSE @Today 
									END
				) > 0
		THEN 1
		ELSE 0
	END
)

	--************** LOGGING **************--
	SET		@StepAffectedRowCount = @@ROWCOUNT
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps] 
					@ExecutionLogID = @ExecutionLogID
	/*User Input*/	,@StepDescription = 'Determine if the current load from ODS has record'
	/*User Input*/	,@AffectedDatabaseName = '[tempdb]'
	/*User Input*/	,@AffectedSchemaName = '[dbo]'
	/*User Input*/	,@AffectedDataEntityName = '[#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS]'
	/*User Input*/	,@ActionPerformed = 'INSERT'
					,@StartDT = @StepStartDT
					,@FinishDT = @StepFinishDT
					,@DurationSeconds = @StepDuration
					,@AffectedRecordCount = @StepAffectedRowCount
					,@ExecutionStepNo = 1000
	
	---- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--

--===============================================================================================================================
--If the current load does not have records, then delete the LoadSetDT from the [#LoadComparison_XLS_DV_TradeTransaction_XLS_KEYS] table because there is no data to compare to
--===============================================================================================================================

IF @CurrentLoadHasRecords = 0
BEGIN

    DELETE FROM 
        [#LoadComparison_XLS_DV_TradeTransaction_XLS_KEYS]
	WHERE 
        [LoadSetDate] =	CASE WHEN @IsInitialLoad = 1 
								THEN '1900/01/01 00:00:00' 
								ELSE @Today 
						END

	--************** LOGGING **************--
	SET		@StepAffectedRowCount = @@ROWCOUNT
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps]
					@ExecutionLogID = @ExecutionLogID
	/*User Input*/	,@StepDescription = 'If the current load does not have records, then delete the LoadSetDT from the [#LoadComparison_XLS_DV_TradeTransaction_XLS_KEYS] table because there is no data to compare to'
	/*User Input*/	,@AffectedDatabaseName = '[tempdb]'
	/*User Input*/	,@AffectedSchemaName = '[dbo]'
	/*User Input*/	,@AffectedDataEntityName = '[#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS]'
	/*User Input*/	,@ActionPerformed = 'DELETE'
					,@StartDT = @StepStartDT
					,@FinishDT = @StepFinishDT
					,@DurationSeconds = @StepDuration
					,@AffectedRecordCount = @StepAffectedRowCount
					,@ExecutionStepNo = 1000
			
	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--
		
END

--===============================================================================================================================
--Load the staging table with the relevant records
--===============================================================================================================================

-- If the history table is empty, load the whole table variable, do not compare hashes
IF @HistoryRowCount > 0 OR @DV_LastLoadDT <> '1900-01-01 00:00:00.0000000'
BEGIN

    INSERT INTO 
		[XLS].[DV_TradeTransaction_XLS_KEYS]
    SELECT
		  [StandardAlias1].[BKHash]
		, [StandardAlias1].LoadDT
		, [StandardAlias1].[RecSrcDataEntityID],
--!~ Field List with alias - Stage				[StandardAlias1].[Id],				[StandardAlias1].[Trade Partner],				[StandardAlias1].[Port of Entry],				[StandardAlias1].[Trade Type],				[StandardAlias1].[Tariff Code],				[StandardAlias1].[Purpose Code],				[StandardAlias1].[Date],				[StandardAlias1].[HK_TradePartner],				[StandardAlias1].[LINKHK_TradePartner_TradeTransaction],				[StandardAlias1].[HK_TradePortOfEntry],				[StandardAlias1].[LINKHK_TradePortOfEntry_TradeTransaction],				[StandardAlias1].[HK_TradeType],				[StandardAlias1].[LINKHK_TradeType_TradeTransaction],				[StandardAlias1].[HK_TradeProduct],				[StandardAlias1].[LINKHK_TradeProduct_TradeTransaction],				[StandardAlias1].[HK_TradePurposeCode],				[StandardAlias1].[LINKHK_TradePurposeCode_TradeTransaction]-- End of Field List with alias - Stage ~!
    FROM 
		[#LoadComparison_XLS_DV_TradeTransaction_XLS_KEYS] [loadcomp]
    LEFT JOIN 
		[#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS] [StandardAlias1] 
		ON [loadcomp].[LoadSetDate] = [StandardAlias1].[LoadDT] --History AND ODS
    LEFT JOIN 
		[#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS] [CompareHist]
		ON [loadcomp].[CompareSetDate] = [CompareHist].[LoadDT] --History AND ODS Offset 
            AND [StandardAlias1].[BKHash] = [CompareHist].[BKHash]
    WHERE	
		1=1
    AND
        (
			[StandardAlias1].[BKHash] <> [CompareHist].[BKHash]
			OR [CompareHist].[BKHash] IS NULL
		)
	AND 
		[loadcomp].[LoadSetRowID] <> 1

	--************** LOGGING **************--
	SET		@StepAffectedRowCount = @@ROWCOUNT
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	-- Destination Counts - Post Load (Stage)
	SET @sql = (SELECT [DataManager].[DC].[udf_get_TableSpaceAndRows]('[DEV_Stage]', PARSENAME('[XLS]',1), PARSENAME('[DV_TradeTransaction_XLS_KEYS]',1)))
	INSERT INTO @SpaceUsed
	EXEC sp_executesql @sql

	SET @PostLoadTargetRowCount = (SELECT [rows] FROM @SpaceUsed)
	SET @PostLoadTargetSizeBytes = (SELECT [reserved] FROM @SpaceUsed)

	DELETE FROM @SpaceUsed

	EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps]
					@ExecutionLogID = @ExecutionLogID
	/*User Input*/	,@StepDescription = 'IF THEN - Compare load sets from history that have not loaded INTo the DataVault and load the stage table with the relevant records'
	/*User Input*/	,@AffectedDatabaseName = '[DEV_Stage]'
	/*User Input*/	,@AffectedSchemaName = '[XLS]'
	/*User Input*/	,@AffectedDataEntityName = '[DV_TradeTransaction_XLS_KEYS]'
	/*User Input*/	,@ActionPerformed = 'INSERT'
					,@StartDT = @StepStartDT
					,@FinishDT = @StepFinishDT
					,@DurationSeconds = @StepDuration
					,@AffectedRecordCount = @StepAffectedRowCount
					,@ExecutionStepNo = 1000
			
	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--

END --End IF
	
ELSE
BEGIN

    INSERT INTO 
		[XLS].[DV_TradeTransaction_XLS_KEYS]
    SELECT
          [StandardAlias1].[BKHash]
		, [StandardAlias1].[LoadDT]
		, [StandardAlias1].[RecSrcDataEntityID],
--!~ Field List with alias - Stage				[StandardAlias1].[Id],				[StandardAlias1].[Trade Partner],				[StandardAlias1].[Port of Entry],				[StandardAlias1].[Trade Type],				[StandardAlias1].[Tariff Code],				[StandardAlias1].[Purpose Code],				[StandardAlias1].[Date],				[StandardAlias1].[HK_TradePartner],				[StandardAlias1].[LINKHK_TradePartner_TradeTransaction],				[StandardAlias1].[HK_TradePortOfEntry],				[StandardAlias1].[LINKHK_TradePortOfEntry_TradeTransaction],				[StandardAlias1].[HK_TradeType],				[StandardAlias1].[LINKHK_TradeType_TradeTransaction],				[StandardAlias1].[HK_TradeProduct],				[StandardAlias1].[LINKHK_TradeProduct_TradeTransaction],				[StandardAlias1].[HK_TradePurposeCode],				[StandardAlias1].[LINKHK_TradePurposeCode_TradeTransaction]-- End of Field List with alias - Stage ~!
    FROM 
		[#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS] [StandardAlias1]
    WHERE	
		1=1
	
	--************** LOGGING **************--
	SET		@StepAffectedRowCount = @@ROWCOUNT
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	-- Destination Counts - Post Load (Stage)
	SET @sql = (SELECT [DataManager].[DC].[udf_get_TableSpaceAndRows]('[DEV_Stage]', PARSENAME('[XLS]',1), PARSENAME('[DV_TradeTransaction_XLS_KEYS]',1)))
	INSERT INTO @SpaceUsed
	EXEC sp_executesql @sql

	SET @PostLoadTargetRowCount = (SELECT [rows] FROM @SpaceUsed)
	SET @PostLoadTargetSizeBytes = (SELECT [reserved] FROM @SpaceUsed)

	DELETE FROM @SpaceUsed

	EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps]
					@ExecutionLogID = @ExecutionLogID
	/*User Input*/	,@StepDescription = 'IF ELSE - If the history table is empty, load the whole table variable, do not compare hashes - and insert all records INTO the staging table'
	/*User Input*/	,@AffectedDatabaseName = '[DEV_Stage]'
	/*User Input*/	,@AffectedSchemaName = '[XLS]'
	/*User Input*/	,@AffectedDataEntityName = '[DV_TradeTransaction_XLS_KEYS]'
	/*User Input*/	,@ActionPerformed = 'INSERT'
					,@StartDT = @StepStartDT
					,@FinishDT = @StepFinishDT
					,@DurationSeconds = @StepDuration
					,@AffectedRecordCount = @StepAffectedRowCount
					,@ExecutionStepNo = 1000
			
	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--
		 

END --End ELSE


--===============================================================================================================================
--INSERT current ODS data INTO the history table for load retention
--===============================================================================================================================
--!~
IF @CurrentLoadHasRecords = 1
BEGIN

    INSERT INTO 
		[XLS].[DV_TradeTransaction_XLS_KEYS_Hist]
    SELECT
          [StandardAlias1].[BKHash]
		, [StandardAlias1].[LoadDT]
		, [StandardAlias1].[RecSrcDataEntityID],
--!~ Field List with alias - Stage				[StandardAlias1].[Id],				[StandardAlias1].[Trade Partner],				[StandardAlias1].[Port of Entry],				[StandardAlias1].[Trade Type],				[StandardAlias1].[Tariff Code],				[StandardAlias1].[Purpose Code],				[StandardAlias1].[Date],				[StandardAlias1].[HK_TradePartner],				[StandardAlias1].[LINKHK_TradePartner_TradeTransaction],				[StandardAlias1].[HK_TradePortOfEntry],				[StandardAlias1].[LINKHK_TradePortOfEntry_TradeTransaction],				[StandardAlias1].[HK_TradeType],				[StandardAlias1].[LINKHK_TradeType_TradeTransaction],				[StandardAlias1].[HK_TradeProduct],				[StandardAlias1].[LINKHK_TradeProduct_TradeTransaction],				[StandardAlias1].[HK_TradePurposeCode],				[StandardAlias1].[LINKHK_TradePurposeCode_TradeTransaction]-- End of Field List with alias - Stage ~!	
    FROM 
		[#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS] [StandardAlias1]
    WHERE	
		[StandardAlias1].[LoadDT] = CASE WHEN @IsInitialLoad = 1 
											THEN '1900/01/01 00:00:00' 
											ELSE @Today 
									END

		--************** LOGGING **************--
		SET		@StepAffectedRowCount = @@ROWCOUNT
		SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
		SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

		EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps] 
						@ExecutionLogID = @ExecutionLogID
		/*User Input*/	,@StepDescription = 'INSERT current ODS data INTO the history table for load retention'
		/*User Input*/	,@AffectedDatabaseName = '[DEV_Stage]'
		/*User Input*/	,@AffectedSchemaName = '[XLS]'
		/*User Input*/	,@AffectedDataEntityName = '[DV_TradeTransaction_XLS_KEYS_Hist]'
		/*User Input*/	,@ActionPerformed = 'INSERT'
						,@StartDT = @StepStartDT
						,@FinishDT = @StepFinishDT
						,@DurationSeconds = @StepDuration
						,@AffectedRecordCount = @StepAffectedRowCount
						,@ExecutionStepNo = 1000
			
		-- Set the start time of the following step 
		SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
		--************** LOGGING **************--
 
END

--===============================================================================================================================
--Delete FROM the history table, WHERE the data loads are older than the specified retention period
--===============================================================================================================================

DECLARE @MinAfter1900HistLoadDT DATETIME2(7)
SET @MinAfter1900HistLoadDT = 
(
	SELECT
		ISNULL(MIN([LoadDT]), '1900/01/01 00:00:00')
	FROM 
		[XLS].[DV_TradeTransaction_XLS_KEYS_Hist]
	WHERE 
		[LoadDT] > '1900/01/01 00:00:00'
)

IF @MinAfter1900HistLoadDT > '1900/01/01 00:00:00' AND DATEDIFF(d, @MinAfter1900HistLoadDT, @Today) > 7
BEGIN

	DELETE FROM 
		[XLS].[DV_TradeTransaction_XLS_KEYS_Hist]
	WHERE	
		[LoadDT] < @MinAfter1900HistLoadDT
		
	--************** LOGGING **************--
	SET		@StepAffectedRowCount = @@ROWCOUNT
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps]
					@ExecutionLogID = @ExecutionLogID
	/*User Input*/	,@StepDescription = 'Delete FROM the history table, WHERE the data loads are older than the specified retention period'
	/*User Input*/	,@AffectedDatabaseName = '[DEV_Stage]'
	/*User Input*/	,@AffectedSchemaName = '[XLS]'
	/*User Input*/	,@AffectedDataEntityName = '[DV_TradeTransaction_XLS_KEYS_Hist]'
	/*User Input*/	,@ActionPerformed = 'DELETE'
					,@StartDT = @StepStartDT
					,@FinishDT = @StepFinishDT
					,@DurationSeconds = @StepDuration
					,@AffectedRecordCount = @StepAffectedRowCount
					,@ExecutionStepNo = 1000
			
	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--
		

END

--===============================================================================================================================
--Cleanup AND Garbarge Collection
--===============================================================================================================================

DROP TABLE IF EXISTS [#LoadSetsXLS_DV_TradeTransaction_XLS_KEYS]
DROP TABLE IF EXISTS [#LoadComparison_XLS_DV_TradeTransaction_XLS_KEYS]
DROP TABLE IF EXISTS [#LoadEntity_XLS_DV_TradeTransaction_XLS_KEYS]

	--************** LOGGING **************--
	SET		@StepAffectedRowCount = @@ROWCOUNT
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps] 
					@ExecutionLogID = @ExecutionLogID
	/*User Input*/	,@StepDescription = 'Drop any # tables that were created and used in the stored procedure'
	/*User Input*/	,@AffectedDatabaseName = '[tempdb]'
	/*User Input*/	,@AffectedSchemaName = '[dbo]'
	/*User Input*/	,@AffectedDataEntityName = 'Mulitple'
	/*User Input*/	,@ActionPerformed = 'DROP TABLE'
					,@StartDT = @StepStartDT
					,@FinishDT = @StepFinishDT
					,@DurationSeconds = @StepDuration
					,@AffectedRecordCount = @StepAffectedRowCount
					,@ExecutionStepNo = 1000
	
	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--

	--*******************************************************************************************************************************
	--ETL Logging - Finish Execution
	--*******************************************************************************************************************************
	--Finish the logging process for this stored proc
	  EXEC DataManager.ETL.sp_insert_ExecutionLog
							@DatabaseName = @DatabaseName
							, @SchemaName = @SchemaName
			/*User Input*/	, @swStart_FinishLogEntry = 2
							, @ExecutionLogID_In = @ExecutionLogID
							, @ExecutionLogID_Out = @ExecutionLogID OUTPUT --This will return a NULL because there is no insert being performed in the stored procedure
							, @LoadConfigID = @LoadConfigID
							, @QueuedForProcessingDT = @StartDate
							, @LastProcessingKeyValue = NULL
							, @IsReload = NULL
							, @ErrorMessage = NULL
							, @DataEntityName = @DataEntityName   
							, @SourceRowCount = @SourceRowCount
							, @SourceTableSizeBytes = @SourceSizeBytes
							, @InitialTargetRowCount = @PreLoadTargetRowCount
							, @InitialTargetTableSizeBytes = @PreLoadTargetSizeBytes
			                , @TargetRowCount = @PostLoadTargetRowCount
	                        , @TargetTableSizeBytes = @PostLoadTargetSizeBytes


END TRY  

BEGIN CATCH

	SELECT  
		ERROR_NUMBER() AS ErrorNumber  
    ,	ERROR_SEVERITY() AS ErrorSeverity  
    ,	ERROR_STATE() AS ErrorState  
    ,	ERROR_PROCEDURE() AS ErrorProcedure  
    ,	ERROR_LINE() AS ErrorLine  
    ,	ERROR_MESSAGE() AS ErrorMessage;  

    DECLARE @ERROR_MESSAGE VARCHAR(MAX) = ERROR_MESSAGE() 

	--************** LOGGING **************--
	EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps] 
					@ExecutionLogID = @ExecutionLogID
	/*User Input*/	,@StepDescription = @ERROR_MESSAGE
	/*User Input*/	,@AffectedDatabaseName = @DatabaseName
	/*User Input*/	,@AffectedSchemaName = @SchemaName
	/*User Input*/	,@AffectedDataEntityName = @DataEntityName
	/*User Input*/	,@ActionPerformed = 'ERROR'
					,@StartDT = @StepStartDT
					,@FinishDT = @StepFinishDT
					,@DurationSeconds = @StepDuration
					,@AffectedRecordCount = @StepAffectedRowCount
					,@ExecutionStepNo = 1000
	
	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--


	--*******************************************************************************************************************************
	--ETL Logging - Finish Execution
	--*******************************************************************************************************************************
	-- ON FAILURE, STILL GET ROW COUNTS Destination Counts - Post Load (Stage)
	SET @sql = (SELECT [DataManager].[DC].[udf_get_TableSpaceAndRows]('[DEV_Stage]', PARSENAME('[XLS]',1), PARSENAME('[DV_TradeTransaction_XLS_KEYS]',1)))
	INSERT INTO @SpaceUsed
	EXEC sp_executesql @sql

	SET @PostLoadTargetRowCount = (SELECT [rows] FROM @SpaceUsed)
	SET @PostLoadTargetSizeBytes = (SELECT [reserved] FROM @SpaceUsed)

	DELETE FROM @SpaceUsed

	PRINT(@ERROR_MESSAGE)

	--Finish the logging process for this stored proc
	  EXEC [DataManager].[ETL].[sp_insert_ExecutionLog]
							  @DatabaseName = @DatabaseName
							, @SchemaName = @SchemaName
			/*User Input*/	, @swStart_FinishLogEntry = 2
							, @ExecutionLogID_In = @ExecutionLogID
							, @ExecutionLogID_Out = @ExecutionLogID OUTPUT --This will return a NULL because there is no insert being performed in the stored procedure
							, @LoadConfigID = @LoadConfigID
							, @QueuedForProcessingDT = @StartDate
							, @LastProcessingKeyValue = NULL
							, @IsReload = NULL
							, @IsError = 1
							, @ErrorMessage = @ERROR_MESSAGE
							, @DataEntityName = @DataEntityName   
							, @SourceRowCount = @SourceRowCount
							, @SourceTableSizeBytes = @SourceSizeBytes
							, @InitialTargetRowCount = @PreLoadTargetRowCount
							, @InitialTargetTableSizeBytes = @PreLoadTargetSizeBytes
			                , @TargetRowCount = @PostLoadTargetRowCount
	                        , @TargetTableSizeBytes = @PostLoadTargetSizeBytes

END CATCH  

GO
