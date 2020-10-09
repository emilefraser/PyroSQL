SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
--===============================6================================================================================================
--Stored Proc Template Version Control --TODO: Ensure this section gets updated when generating a load template
--===============================================================================================================================
--!~ LoadTypeInfo
/*
	Template Version No.:                       |   V 1.00
	Template last update date:                  |   Never
	Template load Type code:                    |   DataVaultFullLoad_REFSAT
	Template load Type description:             |   Full Load of Reference Satellite
	Template Author:                            |   Emile Fraser
	Stored Proc Create Date:                    |   2020-03-09T18:21:32.747
*/
-- End of LoadTypeInfo ~

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
	EXEC [raw].[sp_loadrefsat_DML_Date_LVD] @Today, @IsTest
*/
CREATE     PROCEDURE [raw].[sp_loadrefsat_DML_Date_LVD]
    @Today datetime2(7)
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
			, @LoadConfigID int = 12614
-- End of LoadConfigID ~!
				, @StartDate DATETIME2(7) = GETDATE()
				, @DataEntityName VARCHAR(100) = '[DateDimension]' --Target Data Entity
				, @SourceRowCount INT
				, @SourceSizeBytes INT
				, @PreLoadTargetRowCount INT
				, @PreLoadTargetSizeBytes INT						
				, @PostLoadTargetRowCount INT	
				, @PostLoadTargetSizeBytes INT
				, @RowCount INT
				, @PreRowCount_LoadEndDT INT
				, @PostRowCount_LoadEndDT INT
			
	-- Table Size Variables
	DECLARE @sql AS NVARCHAR(MAX)

	DECLARE @SpaceUsed TABLE (
		[name] varchar(255), 
		[rows] int, 
		[reserved] int)

	--================================================================================================================================
	-- ETL Logging - Start Execution
	--================================================================================================================================
	
	--************** LOGGING **************--
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
				
	-- Destination Counts PRE-Load (Data Vault)
	SET @sql = (SELECT [DataManager_Local].[ETL].[udf_get_TableSpaceAndRows]('[DEV_DataVault]', PARSENAME('[raw]',1), PARSENAME('[REFSAT_Date_DML_LVD]',1)))
	INSERT INTO @SpaceUsed
	EXEC sp_executesql @sql

	-- Sets PRE-Load Counts to Variables (Data Vault)
	SET @PreLoadTargetRowCount = (SELECT [rows] FROM @SpaceUsed)
	SET @PreLoadTargetSizeBytes = (SELECT [reserved] FROM @SpaceUsed)

	-- Truncates the Temp Table Used
	DELETE FROM @SpaceUsed
	
	-- Gets Completion time of the Step (PRE-Load Data Vault Counts)
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)			

	-- Writes Log Entry to ETL Schema of DataManager
	EXEC [DataManager_Local].[ETL].[sp_insert_ExecutionLogSteps]
				 @ExecutionLogID = @ExecutionLogID
/*User Input*/	,@StepDescription = 'Gets the PreLoad Taget Row Count and PreLoad Target Size [raw].[REFSAT_Date_DML_LVD]'
/*User Input*/	,@AffectedDatabaseName = '[DEV_DataVault]'
/*User Input*/	,@AffectedSchemaName = '[raw]'
/*User Input*/	,@AffectedDataEntityName = '[REFSAT_Date_DML_LVD]'
/*User Input*/	,@ActionPerformed = 'SELECT'
				,@StartDT = @StepStartDT
				,@FinishDT = @StepFinishDT
				,@DurationSeconds = @StepDuration
				,@AffectedRecordCount = @PreLoadTargetRowCount
				,@ExecutionStepNo = 1

	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--

	--================================================================================================================================
	-- Create temp table of BK Hashes for checking whether updates were made 
	--================================================================================================================================

	--Get the UpdateSet - Hash keys of the entries that have changed
	DROP TABLE IF EXISTS #UpdateSet
	CREATE TABLE #UpdateSet (
		BKHash VARCHAR(40)
	)

	--************** LOGGING **************--
	-- Gets Completion time of the Step
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)			

	-- Writes Log Entry to ETL Schema of DataManager
	EXEC [DataManager_Local].[ETL].[sp_insert_ExecutionLogSteps]
				 @ExecutionLogID = @ExecutionLogID
/*User Input*/	,@StepDescription = 'Creates a temp table to hold all hash keys to be checked against [raw].[REFSAT_Date_DML_LVD]'
/*User Input*/	,@AffectedDatabaseName = 'tempdb'
/*User Input*/	,@AffectedSchemaName = 'dbo'
/*User Input*/	,@AffectedDataEntityName = '#UpdateSet'
/*User Input*/	,@ActionPerformed = 'CREATE'
				,@StartDT = @StepStartDT
				,@FinishDT = @StepFinishDT
				,@DurationSeconds = @StepDuration
				,@AffectedRecordCount = 0
				,@ExecutionStepNo = 1000

	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--

	--================================================================================================================================
	-- INSERTS All Business Key Hashes into temp table from stage where keys ALREADY Exist in the Vault
	--================================================================================================================================

	INSERT INTO #UpdateSet (
		BKHash
	)
	SELECT 
		stagetable.[BKHash]
	FROM 
		[DEV_StageArea].[DML].[MASTER_REF_Date_DML_LVD] stagetable
	WHERE EXISTS (
					SELECT 
						1
					 FROM 
						[raw].[REFSAT_Date_DML_LVD] dvtable
					WHERE 
						dvtable.[HK_Date] = stagetable.[BKHash] 
					AND
						dvtable.[HashDiff] != stagetable.[HashDiff]
				  )


	--************** LOGGING **************--
	-- Gets Completion time of the Step and gets number or rows transferred to the temp table
	SET		@RowCount = (SELECT COUNT(1) FROM #UpdateSet)
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)	
	

	-- Writes Log Entry to ETL Schema of DataManager
	EXEC [DataManager_Local].[ETL].[sp_insert_ExecutionLogSteps]
				 @ExecutionLogID = @ExecutionLogID
/*User Input*/	,@StepDescription = 'Populate all business keys into the temp table #UpdateSet that ALREADY exists in [raw].[REFSAT_Date_DML_LVD]'
/*User Input*/	,@AffectedDatabaseName = 'tempdb'
/*User Input*/	,@AffectedSchemaName = 'dbo'
/*User Input*/	,@AffectedDataEntityName = '#UpdateSet'
/*User Input*/	,@ActionPerformed = 'INSERT'
				,@StartDT = @StepStartDT
				,@FinishDT = @StepFinishDT
				,@DurationSeconds = @StepDuration
				,@AffectedRecordCount = @RowCount
				,@ExecutionStepNo = 1000

	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@PreRowCount_LoadEndDT = (SELECT COUNT(1) FROM [raw].[REFSAT_Date_DML_LVD] WHERE LoadEndDT IS NULL)
	--************** LOGGING **************--

	--================================================================================================================================
	-- Update LoadEndDT to todays date for records that are going to have new versions
	--================================================================================================================================

	-- Close records that are now going to have new versions
	UPDATE 
		dvtable
	SET 
		[LoadEndDT] = @Today
	FROM 
		[raw].[REFSAT_Date_DML_LVD] dvtable
    INNER JOIN 
		#UpdateSet updateset 
		ON updateset.[BKHash] = dvtable.[HK_Date]
	WHERE 
		dvtable.[LoadEndDT] IS NULL

	--************** LOGGING **************--
	-- Gets Completion time of the Step and gets number or rows transferred to the temp table
	SET		@PostRowCount_LoadEndDT = (SELECT COUNT(1) FROM [raw].[REFSAT_Date_DML_LVD] WHERE LoadEndDT IS NULL)
	SET		@RowCount = @PostRowCount_LoadEndDT - @PreRowCount_LoadEndDT
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)	
	
	-- Writes Log Entry to ETL Schema of DataManager
	EXEC [DataManager_Local].[ETL].[sp_insert_ExecutionLogSteps]
				 @ExecutionLogID = @ExecutionLogID
/*User Input*/	,@StepDescription = 'Closes records that will now have new versions in  [raw].[REFSAT_Date_DML_LVD]'
/*User Input*/	,@AffectedDatabaseName = '[DEV_DataVault]'
/*User Input*/	,@AffectedSchemaName = '[raw]'
/*User Input*/	,@AffectedDataEntityName = '[REFSAT_Date_DML_LVD]'
/*User Input*/	,@ActionPerformed = 'UPDATE'
				,@StartDT = @StepStartDT
				,@FinishDT = @StepFinishDT
				,@DurationSeconds = @StepDuration
				,@AffectedRecordCount = @RowCount
				,@ExecutionStepNo = 1000

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

	--Insert new records and records that have been updated (new versions of the records)
	INSERT INTO [raw].[REFSAT_Date_DML_LVD] 
	(
		[HK_Date],
		[LoadDT],
		[LoadEndDT],
		[RecSrcDataEntityID],
		[HashDiff]
--!~ Field List without alias of Business Keys for DataVault
		, [IsWeekend]
		, [Year]
		, [QuarterNo]
		, [MonthNumber]
		, [DayofYear]
		, [Day]
		, [Week]
		, [DayofWeekNo]
		, [DayofWeek]
		, [DayofWeekAbbreviation]
		, [Month]
		, [MonthAbbreviation]
		, [FinancialYear]
		, [FinancialPeriodNo]
		, [YearFinancialPeriod]
		, [FinancialPeriod]
		, [FinancialQuarterNo]
		, [FinancialYearQuarter]
		, [FinancialQuarter]
		, [MonthBeginDate]
		, [MonthEndDate]
		, [WeekBeginDate]
		, [WeekEndDate]
		, [PreviousYear]
		, [PreviousYearDate]
		      ,[IsPublicHoliday]
      ,[IsSchoolHoliday]
      ,[IsToday]
      ,[IsCurrentWeek]
      ,[IsCurrentMonth]
      ,[IsInLast7Days]
      ,[IsInLast30Days]
-- End of Field List without alias of Business Keys for DataVault ~!
	)
	SELECT
		[HK_Date] = stagetable.[BKHash],
		[LoadDT] = stagetable.LoadDT,
		[LoadEndDT] = NULL,
		[RecSrcDataEntityID] = stagetable.RecSrcDataEntityID,
		[HashDiff] = stagetable.HashDiff,
--!~ Field List with no alias - ODS
		 [IsWeekend],
		 [Year],
		 [QuarterNo],
		 [MonthNumber],
		 [DayofYear],
		 [Day],
		 [Week],
		 [DayofWeekNo],
		 [DayofWeek],
		 [DayofWeekAbbreviation],
		 [Month],
		 [MonthAbbreviation],
		 [FinancialYear],
		 [FinancialPeriodNo],
		 [YearFinancialPeriod],
		 [FinancialPeriod],
		 [FinancialQuarterNo],
		 [FinancialYearQuarter],
		 [FinancialQuarter],
		 [MonthBeginDate],
		 [MonthEndDate],
		 [WeekBeginDate],
		 [WeekEndDate],
		 [PreviousYear],
		 [PreviousYearDate],
       [IsPublicHoliday]
      ,[IsSchoolHoliday]
      ,[IsToday]
      ,[IsCurrentWeek]
      ,[IsCurrentMonth]
      ,[IsInLast7Days]
      ,[IsInLast30Days]
-- End of Field List with no alias - ODS ~!
	 FROM 
		[DEV_StageArea].[DML].[MASTER_REF_Date_DML_LVD] stagetable
	 WHERE NOT EXISTS (
							SELECT 
								1
							FROM 
								[raw].[REFSAT_Date_DML_LVD] dvtable
							WHERE 
								dvtable.[HK_Date] = stagetable.[BKHash] 
							AND
							  dvtable.HashDiff = stagetable.[HashDiff]
							AND
							  dvtable.[LoadEndDT] IS NULL
					  )
		ORDER BY 1
 
	-- Restore the ROWCOUNT SQL variable to 0
	-- All records will be loaded again from this point
	IF (@IsTest = 1)
		SET ROWCOUNT 0

	--************** LOGGING **************--
	-- Destination Counts Post Load (Data Vault)
	SET @sql = (SELECT [DataManager_Local].[ETL].[udf_get_TableSpaceAndRows]('[DEV_DataVault]', PARSENAME('[raw]',1), PARSENAME('[REFSAT_Date_DML_LVD]',1)))
	INSERT INTO @SpaceUsed
	EXEC sp_executesql @sql

	-- Destination POST-Load Counts assigned to Variables (Data Vault)
	SET @PostLoadTargetRowCount = (SELECT [rows] FROM @SpaceUsed)
	SET @PostLoadTargetSizeBytes = (SELECT [reserved] FROM @SpaceUsed)

	-- Clears out Space Used Temp Table
	DELETE FROM @SpaceUsed

	-- Calculate the Row Deltas (POST - PRE) and Runtime
	SET		@StepAffectedRowCount = @PostLoadTargetRowCount - @PreLoadTargetRowCount
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	-- Writes Log Entry to ETL Schema of DataManager
	EXEC [DataManager_Local].[ETL].[sp_insert_ExecutionLogSteps]
					@ExecutionLogID = @ExecutionLogID
	/*User Input*/	,@StepDescription = 'Loads New Records into the REFSATellite [raw].[REFSAT_Date_DML_LVD]'
	/*User Input*/	,@AffectedDatabaseName = '[DEV_DataVault]'
	/*User Input*/	,@AffectedSchemaName = '[raw]'
	/*User Input*/	,@AffectedDataEntityName = '[REFSAT_Date_DML_LVD]'
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
	-- Drops and Temporary tables or objects created for the REFSATellite load procedure
	--===============================================================================================================================

	DROP TABLE IF EXISTS #UpdateSet

	--************** LOGGING **************--
	SET		@StepFinishDT = CONVERT(DATETIME2(7), GETDATE())
	SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)

	-- Writes Log Entry to ETL Schema of DataManager
	EXEC [DataManager_Local].[ETL].[sp_insert_ExecutionLogSteps]
					@ExecutionLogID = @ExecutionLogID
	/*User Input*/	,@StepDescription = 'DROPS the temps table #UpdateSet used to check for existing keys'
	/*User Input*/	,@AffectedDatabaseName = 'tempdb'
	/*User Input*/	,@AffectedSchemaName = 'dbo'
	/*User Input*/	,@AffectedDataEntityName = '#UpdateSet'
	/*User Input*/	,@ActionPerformed = 'DROP'
					,@StartDT = @StepStartDT
					,@FinishDT = @StepFinishDT
					,@DurationSeconds = @StepDuration
					,@AffectedRecordCount = @StepAffectedRowCount
					,@ExecutionStepNo = 1000
	
	-- Set the start time of the following step 
	SET		@StepStartDT = CONVERT(DATETIME2(7), GETDATE())
	--************** LOGGING **************--

	--================================================================================================================================
	-- ETL Logging - Finish Execution (SUCCESSFUL)
	--================================================================================================================================
	
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
	SELECT  
		ERROR_NUMBER() AS ErrorNumber  
    ,	ERROR_SEVERITY() AS ErrorSeverity  
    ,	ERROR_STATE() AS ErrorState  
    ,	ERROR_PROCEDURE() AS ErrorProcedure  
    ,	ERROR_LINE() AS ErrorLine  
    ,	ERROR_MESSAGE() AS ErrorMessage;  

    DECLARE @ERROR_MESSAGE VARCHAR(MAX) = ERROR_MESSAGE() 

	-- Write the Error Caught to the Execution Log
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
	-- ETL Logging - Finish Execution (FAILURE)
	--================================================================================================================================
	
	-- ON FAILURE, Get the Post Load Counts
	SET @sql = (SELECT [DataManager_Local].[ETL].[udf_get_TableSpaceAndRows]('[DEV_DataVault]', PARSENAME('[raw]',1), PARSENAME('[REFSAT_Date_DML_LVD]',1)))
	INSERT INTO @SpaceUsed
	EXEC sp_executesql @sql

	-- Assign the Load Counts to variables
	SET @PostLoadTargetRowCount = (SELECT [rows] FROM @SpaceUsed)
	SET @PostLoadTargetSizeBytes = (SELECT [reserved] FROM @SpaceUsed)

	DELETE FROM @SpaceUsed

	--Finish the logging process for this stored proc, by Logging what was caught
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
						, @SourceTableSizeBytes = @SourceSizeBytes
						, @InitialTargetRowCount = @PreLoadTargetRowCount
						, @InitialTargetTableSizeBytes = @PreLoadTargetSizeBytes
						, @TargetRowCount = @PostLoadTargetRowCount
						, @TargetTableSizeBytes = @PostLoadTargetSizeBytes

END CATCH  						





GO
