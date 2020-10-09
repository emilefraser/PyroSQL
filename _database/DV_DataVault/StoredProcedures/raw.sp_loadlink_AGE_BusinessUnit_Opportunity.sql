SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
--===============================================================================================================================
--Stored Proc Template Version Control --TODO: Ensure this section gets updated when generating a load template
--===============================================================================================================================
--!~ LoadTypeInfo
/*
	Template Version No.:                       |   V 2.10
	Template last update date:                  |   2019-09-30T14:43:33.8533333
	Template load Type code:                    |   DataVaultFullLoad_LINK
	Template load Type description:             |   Full Load of Link Table in DataVault from Standard StageArea Table
	Template Author:                            |   Emile Fraser
	Stored Proc Create Date:                    |   2020-05-20T23:17:56.247
*/
-- End of LoadTypeInfo ~!

--===============================================================================================================================
--Logging conventions - NOTES TO THE DEVELOPER!
--===============================================================================================================================
--!~ Logging Convention Notes
 /*
 
 */
 -- End of Logging Convention Notes ~!

-- Sample Execution
/*
	DECLARE @Today DATETIME2(7) = GETDATE()
	DECLARE @IsTest BIT = 0
	EXEC [raw].[sp_loadlink_AGE_BusinessUnit_Opportunity] @Today, @IsTest
*/
CREATE   PROCEDURE [raw].[sp_loadlink_AGE_BusinessUnit_Opportunity]
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
			, @LoadConfigID int = 790
-- End of LoadConfigID ~!
				, @StartDate DATETIME2(7) = GETDATE()
				, @DataEntityName VARCHAR(100) = '[LINK_BusinessUnit_Opportunity]' --Target Data Entity
				, @SourceRowCount INT
				, @SourceSizeBytes INT
				, @PreLoadTargetRowCount INT
				, @PreLoadTargetSizeBytes INT						
				, @PostLoadTargetRowCount INT	
				, @PostLoadTargetSizeBytes INT
			
	-- Table Size Variables
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

	--************** LOGGING **************--
	-- Destination PRE-Load Counts (Data Vault)
	SET @sql = (SELECT [DataManager].[DC].[udf_get_TableSpaceAndRows]('[DEV_DataVault]', PARSENAME('[raw]',1), PARSENAME('[LINK_BusinessUnit_Opportunity]',1)))
	INSERT INTO @SpaceUsed
	EXEC sp_executesql @sql

	-- Sets PRE-Load Counts to Variables (Data Vault)
	SET @PreLoadTargetRowCount = (SELECT [rows] FROM @SpaceUsed)
	SET @PreLoadTargetSizeBytes = (SELECT [reserved] FROM @SpaceUsed)

	-- Truncate the Temp Table
	DELETE FROM @SpaceUsed
	
	-- Gets Completion time of the Step (PRE-Load Data Vault Counts)
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	-- Writes Log Entry to ETL Schema of DataManager
	EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps]
				 @ExecutionLogID = @ExecutionLogID
/*User Input*/	,@StepDescription = 'Gets the PreLoad Taget Row Count and Pre-Load Target Size [raw].[LINK_BusinessUnit_Opportunity]'
/*User Input*/	,@AffectedDatabaseName = '[DEV_DataVault]'
/*User Input*/	,@AffectedSchemaName = '[raw]'
/*User Input*/	,@AffectedDataEntityName = '[LINK_BusinessUnit_Opportunity]'
/*User Input*/	,@ActionPerformed = 'SELECT'
				,@StartDT = @StepStartDT
				,@FinishDT = @StepFinishDT
				,@DurationSeconds = @StepDuration
				,@AffectedRecordCount = @PreLoadTargetRowCount
				,@ExecutionStepNo = 1

	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--

	--===============================================================================================================================
	-- Moves the Data Into the Data Vault Entity From Stage Area
	--===============================================================================================================================

	-- Quick or Test Load, when @IsTest = 1
	-- If a test is run, ony the top 10000 records will be loaded
	IF (@IsTest = 1)
		SET ROWCOUNT 10000

	-- Inserts the New Values into the HUB from Stage Table
	INSERT INTO [raw].[LINK_BusinessUnit_Opportunity]
	(	
		[HK_BusinessUnit_Opportunity],
		[LoadDT],
		[RecSrcDataEntityID],
		[HK_Opportunity],
		[HK_BusinessUnit]
	)
	SELECT 
		[HK_BusinessUnit_Opportunity] = stagetable.[LINKHK_BusinessUnit_Opportunity],
		[LoadDT] = stagetable.[LoadDT],
		[RecSrcDataEntityID] = stagetable.[RecSrcDataEntityID],			
		[HK_Opportunity] = stagetable.[BKHash],
		[HK_BusinessUnit] = stagetable.[HK_BusinessUnit]
	FROM 
		[DEV_StageArea].[AGE].[dbo_Opportunity_AGE_KEYS] stagetable
	WHERE NOT EXISTS (
						SELECT 
							1
						FROM 
							[raw].[LINK_BusinessUnit_Opportunity] dvtable
						WHERE 
							dvtable.[HK_BusinessUnit_Opportunity] = stagetable.[LINKHK_BusinessUnit_Opportunity]
					  )
	ORDER BY 1

	-- Restore the ROWCOUNT SQL variable to 0
	-- ie All records will be loaded again from this point
	IF (@IsTest = 1)
		SET ROWCOUNT 0

	--************** LOGGING **************--
	-- Destination Counts Post Load (Data Vault)
	SET @sql = (SELECT [DataManager].[DC].[udf_get_TableSpaceAndRows]('[DEV_DataVault]', PARSENAME('[raw]',1), PARSENAME('[LINK_BusinessUnit_Opportunity]',1)))
	INSERT INTO @SpaceUsed
	EXEC sp_executesql @sql

	-- Get the Post-Load Row counts of the Data Vault table
	SET @PostLoadTargetRowCount = (SELECT [rows] FROM @SpaceUsed)
	SET @PostLoadTargetSizeBytes = (SELECT [reserved] FROM @SpaceUsed)

	-- Clears the temp table
	DELETE FROM @SpaceUsed

	-- Calculate   Row Deltas (POST - PRE) and Runtime
	SET		@StepAffectedRowCount = @PostLoadTargetRowCount - @PreLoadTargetRowCount
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	-- Writes Log Entry to ETL Schema of DataManager
	EXEC [DataManager].[ETL].[sp_insert_ExecutionLogSteps]
					 @ExecutionLogID = @ExecutionLogID
	/*User Input*/	,@StepDescription = 'Inserts New LINK records into [raw].[LINK_BusinessUnit_Opportunity]'
	/*User Input*/	,@AffectedDatabaseName = '[DEV_DataVault]'
	/*User Input*/	,@AffectedSchemaName = '[raw]'
	/*User Input*/	,@AffectedDataEntityName = '[LINK_BusinessUnit_Opportunity]'
	/*User Input*/	,@ActionPerformed = 'INSERT'
					,@StartDT = @StepStartDT
					,@FinishDT = @StepFinishDT
					,@DurationSeconds = @StepDuration
					,@AffectedRecordCount = @StepAffectedRowCount
					,@ExecutionStepNo = 1000

	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--

	--================================================================================================================================
	--ETL Logging - Finish Execution (SUCCESSFUL)
	--================================================================================================================================
	
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
						, @SourceRowCount = NULL
						, @InitialTargetRowCount = @PreLoadTargetRowCount
						, @TargetRowCount = @PostLoadTargetRowCount						
						, @InitialTargetTableSizeBytes = @PreLoadTargetSizeBytes
						, @TargetTableSizeBytes = @PostLoadTargetSizeBytes

END TRY  

BEGIN CATCH

	-- IF we catch an error, End the Log Time and determine what error occured
	--************** LOGGING **************--
	SET	@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET	@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	SELECT  
		ERROR_NUMBER() AS ErrorNumber  
    ,	ERROR_SEVERITY() AS ErrorSeverity  
    ,	ERROR_STATE() AS ErrorState  
    ,	ERROR_PROCEDURE() AS ErrorProcedure  
    ,	ERROR_LINE() AS ErrorLine  
    ,	ERROR_MESSAGE() AS ErrorMessage;  

    DECLARE @ERROR_MESSAGE VARCHAR(MAX) = ERROR_MESSAGE() 

	-- Write the Error Caught to the Execution Log
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

	--================================================================================================================================
	--ETL Logging - Finish Execution (FAILURE)
	--================================================================================================================================
	
	-- ON FAILURE, Get the Post Load Counts
	SET @sql = (SELECT [DataManager].[DC].[udf_get_TableSpaceAndRows]('[DEV_DataVault]', PARSENAME('[raw]',1), PARSENAME('[LINK_BusinessUnit_Opportunity]',1)))
	INSERT INTO @SpaceUsed
	EXEC sp_executesql @sql

	SET @PostLoadTargetRowCount = (SELECT [rows] FROM @SpaceUsed)
	SET @PostLoadTargetSizeBytes = (SELECT [reserved] FROM @SpaceUsed)

	DELETE FROM @SpaceUsed

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
						, @SourceTableSizeBytes = NULL
						, @InitialTargetRowCount = @PreLoadTargetRowCount
						, @InitialTargetTableSizeBytes = @PreLoadTargetSizeBytes
						, @TargetRowCount = @PostLoadTargetRowCount
						, @TargetTableSizeBytes = @PostLoadTargetSizeBytes

END CATCH  	

GO
