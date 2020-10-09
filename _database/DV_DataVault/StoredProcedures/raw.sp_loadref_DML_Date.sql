SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
--===============================================================================================================================
--Stored Proc Template Version Control --TODO: Ensure this section gets updated when generating a load template
--===============================================================================================================================
--!~ LoadTypeInfo
/*
	Template Version No.:                       |   V 1.20
	Template last update date:                  |   2019-10-01T10:25:55.5633333
	Template load Type code:                    |   DEV_DataVaultFullLoad_REF
	Template load Type description:             |   Full Load of Ref Table
	Template Author:                            |   Thuto Sephaphati
	Stored Proc Create Date:                    |   2019-10-01T12:03:10.157
*/
-- End of LoadTypeInfo ~!

--===============================================================================================================================
--Logging conventions - NOTES TO THE DEVELOPER!
--===============================================================================================================================
--!~ Logging Convention Notes
 /*
 
 */
 -- End of Logging Convention Notes ~!


--Dimensional REF Load
--TODO Add FieldTypeField inserts when creating REF table in DC
--TODO Populate the FieldSortOrder when creating REF table in DC
--TODO Populate REFBKFieldID in DMOD.REFBusinessKey_Working when creating REF table in DC

--Static Replacements int the template
--	1) ProcedureName of [sp_loadref_DM_Date] --> [sp_loadREF_@System_@REFName]
--	2) DataEntityName of [DateDimension] --> [@DataEntityName]
--  3) SourceDatabaseName of [StageArea]
--  4) SourceSchemaNem of [DM]
--  5) SOurceDataTable or View [MASTER_REF_Date_DM_KEYS] 

-- Dynamic Replacements 
--  1) BusinessKeys !~ Business Key Insert Columns -- End of Business Key Insert Columns ~!

/*
	DECLARE @Today DATETIME2(7) = GETDATE()
	DECLARE @IsTest BIT = 0
	EXEC [raw].[sp_loadref_DML_Date] @Today, @IsTest
*/
CREATE     PROCEDURE [raw].[sp_loadref_DML_Date]
    @Today DATETIME2(7)
,	@IsTest BIT
AS

BEGIN TRY 

	--===============================================================================================================================
	--Variable workbench
	--===============================================================================================================================
	--Log Variables
	DECLARE		  @ExecutionLogID INT
				, @StepStartDT DATETIME2(7)
				, @StepFinishDT DATETIME2(7)
				, @StepDuration INT
				, @StepAffectedRowCount INT 
				, @DatabaseName VARCHAR(100)
				, @SchemaName VARCHAR(100)
	--!~ LoadConfigID
			, @LoadConfigID int = 3806
-- End of LoadConfigID ~!
				, @StartDate DATETIME2(7) = GETDATE()
				, @DataEntityName VARCHAR(100) = '[DateDimension]' --Target Data Entity
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

	--================================================================================================================================
	--ETL Logging - Start Execution
	--================================================================================================================================
	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())

	--Start the logging process for this stored proc
	SELECT		  @DatabaseName = QUOTENAME(DB_NAME())
				, @SchemaName = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID))

	--Start the logging process for this stored proc
	EXEC [DataManager_Local].[ETL].[sp_insert_ExecutionLog]
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

	--************** LOGGING **************--
	-- Destination Counts Pre Load (Data Vault)
	SET @sql = (SELECT [DataManager_Local].[ETL].[udf_get_TableSpaceAndRows]('[DEV_DataVault]', PARSENAME('[raw]',1), PARSENAME('[REF_Date]',1)))
	INSERT INTO @SpaceUsed
	EXEC sp_executesql @sql

	SET @PreLoadTargetRowCount = (SELECT [rows] FROM @SpaceUsed)
	SET @PreLoadTargetSizeBytes = (SELECT [reserved] FROM @SpaceUsed)

	DELETE FROM @SpaceUsed
	
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	EXEC [DataManager_Local].[ETL].[sp_insert_ExecutionLogSteps]
				 @ExecutionLogID = @ExecutionLogID
/*User Input*/	,@StepDescription = 'Gets the PreLoad Taget Row Count and PreLoad Target Size [raw].[REF_Date]'
/*User Input*/	,@AffectedDatabaseName = '[DEV_DataVault]'
/*User Input*/	,@AffectedSchemaName = '[raw]'
/*User Input*/	,@AffectedDataEntityName = '[REF_Date]'
/*User Input*/	,@ActionPerformed = 'SELECT'
				,@StartDT = @StepStartDT
				,@FinishDT = @StepFinishDT
				,@DurationSeconds = @StepDuration
				,@AffectedRecordCount = @PreLoadTargetRowCount
				,@ExecutionStepNo = 1

	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--


/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

--===============================================================================================================================
-- Moves the Data Into the Data Vault Entity From Stage Area
--===============================================================================================================================

	-- Quick or Test Load, when @IsTest = 1
	-- If a test is run on the initial dataset (FACT tables only), first do a test on top 10000 records before full loading
	IF (@IsTest = 1)
		SET ROWCOUNT 10000
				

	INSERT INTO [raw].[REF_Date]
	   (
			[HK_Date]															
	   ,	[LoadDT]															
	   ,	[RecSrcDataEntityID]												
--!~ Field List without alias of Business Keys for DEV_DataVault
		, [CalendarDate]
-- End of Field List without alias of Business Keys for DEV_DataVault ~!
	   )
	SELECT
		[HK_Date] = stagetable.[BKHash],										
		[LoadDT] = stagetable.[LoadDT],											
		[RecSrcDataEntityID] = stagetable.[RecSrcDataEntityID], 				
--!~ Field List with no alias - ODS
		 [CalendarDate]
-- End of Field List with no alias - ODS ~!
	FROM 
		[DEV_StageArea].[DML].[MASTER_REF_Date_DML_KEYS] stagetable						
	WHERE NOT EXISTS (
						SELECT 1		
						FROM [raw].[REF_Date] AS dvtable						
						WHERE dvtable.[HK_Date] = stagetable.[BKHash]			
					  )
	ORDER BY 1

	-- RESTORE ROWCOUNT TO 0, ie all rows to get returned 
	IF (@IsTest = 1)
		SET ROWCOUNT 0

	--************** LOGGING **************--
	-- Destination Counts Post Load (Data Vault)
	SET @sql = (SELECT [DataManager].[DC].[udf_get_TableSpaceAndRows]('[DEV_DataVault]', PARSENAME('[raw]',1), PARSENAME('[REF_Date]',1)))
	INSERT INTO @SpaceUsed
	EXEC sp_executesql @sql

	SET @PostLoadTargetRowCount = (SELECT [rows] FROM @SpaceUsed)
	SET @PostLoadTargetSizeBytes = (SELECT [reserved] FROM @SpaceUsed)

	DELETE FROM @SpaceUsed

	SET		@StepAffectedRowCount = @PostLoadTargetRowCount - @PreLoadTargetRowCount
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps]
					 @ExecutionLogID = @ExecutionLogID
	/*User Input*/	,@StepDescription = 'Gets the PostLoad Taget Row Count and PoastLoad Target Size [raw].[REF_Date]'
	/*User Input*/	,@AffectedDatabaseName = '[DEV_DataVault]'
	/*User Input*/	,@AffectedSchemaName = '[raw]'
	/*User Input*/	,@AffectedDataEntityName = '[REF_Date]'
	/*User Input*/	,@ActionPerformed = 'SELECT'
					,@StartDT = @StepStartDT
					,@FinishDT = @StepFinishDT
					,@DurationSeconds = @StepDuration
					,@AffectedRecordCount = @StepAffectedRowCount
					,@ExecutionStepNo = 1000

-- Set the start time of the following step 
SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
--************** LOGGING **************--

	--================================================================================================================================
	--ETL Logging - Finish Execution
	--================================================================================================================================
	--Finish the logging process for this stored proc
	  EXEC [DataManager_Local].ETL.sp_insert_ExecutionLog
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
						, @SourceRowCount = NULL
						, @InitialTargetRowCount = @PreLoadTargetRowCount
						, @TargetRowCount = @PostLoadTargetRowCount						
						, @InitialTargetTableSizeBytes = @PreLoadTargetSizeBytes
						, @TargetTableSizeBytes = @PostLoadTargetSizeBytes

END TRY  

BEGIN CATCH

	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	SELECT  
		ERROR_NUMBER() AS ErrorNumber  
    ,	ERROR_SEVERITY() AS ErrorSeverity  
    ,	ERROR_STATE() AS ErrorState  
    ,	ERROR_PROCEDURE() AS ErrorProcedure  
    ,	ERROR_LINE() AS ErrorLine  
    ,	ERROR_MESSAGE() AS ErrorMessage;  

    DECLARE @ERROR_MESSAGE VARCHAR(MAX) = ERROR_MESSAGE() 

	--************** LOGGING **************--
	EXEC [DataManager_Local].[ETL].[sp_insert_ExecutionLogSteps] 
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

	--================================================================================================================================
	--ETL Logging - Finish Execution
	--================================================================================================================================
	
	-- ON FAILURE, Get the Post Load Counts
	SET @sql = (SELECT [DataManager_Local].[ETL].[udf_get_TableSpaceAndRows]('[DEV_DataVault]', PARSENAME('[raw]',1), PARSENAME('[REF_Date]',1)))
	INSERT INTO @SpaceUsed
	EXEC sp_executesql @sql

	SET @PostLoadTargetRowCount = (SELECT [rows] FROM @SpaceUsed)
	SET @PostLoadTargetSizeBytes = (SELECT [reserved] FROM @SpaceUsed)

	DELETE FROM @SpaceUsed

	--Finish the logging process for this stored proc
	EXEC [DataManager_Local].[ETL].[sp_insert_ExecutionLog]
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
						, @SourceTableSizeBytes = NULL
						, @InitialTargetRowCount = @PreLoadTargetRowCount
						, @InitialTargetTableSizeBytes = @PreLoadTargetSizeBytes
						, @TargetRowCount = @PostLoadTargetRowCount
						, @TargetTableSizeBytes = @PostLoadTargetSizeBytes

END CATCH  
GO