SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
--===============================================================================================================================
--Stored Proc Version Control
--===============================================================================================================================
/*
	Create date:						| 2019-01-08
	Author:								| Frans Germishuizen
	Description:						| Create exectable stored proc from static template	

	EXEC [DMOD].[sp_generate_ddl_LoadStoredProcs] 1, 'Frans Germhuizen'

*/

CREATE PROCEDURE [DMOD].[sp_generate_ddl_LoadStoredProcs] 
	@LoadConfigID INT
,	@Author VARCHAR(250)
,	@IsDebug BIT

AS

--
/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
--Stored Proc Management
	--===============================================================================================================================
	--Variable workbench
	--===============================================================================================================================
	--Stored Proc Varialbles
	declare @SourceDataEntityID int = NULL
			, @TargetDataEntityID int = NULL
			, @SourceSystemAbbreviation varchar(50) = NULL
			, @LoadTypeID int = NULL
			, @DropStatement varchar(max) = NULL
			, @ProcStatement nvarchar(max)
			, @ParameterSearchValue varchar(max)
			, @ParameterReplacementValue varchar(max)
			, @ParameterReplacementSQLCode nvarchar(max)


/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

	--======================================================================================================================
	--Get list of tables that are configured in DMOD.LoadConfig
	--======================================================================================================================

	select	@SourceDataEntityID = SourceDataEntityID
			, @TargetDataEntityID = TargetDataEntityID
			, @LoadTypeID = conf.LoadTypeID
			, @SourceSystemAbbreviation = DC.udf_get_TopLevelParentDataEntity_SourceSystemAbbr(TargetDataEntityID)
			, @ProcStatement = ltype.ParameterisedTemplateScript
	from	DMOD.LoadConfig conf
		inner join DMOD.LoadType ltype on ltype.LoadTypeID = conf.LoadTypeID
	where	LoadConfigID = @LoadConfigID


	--select @SourceDataEntityID, @TargetDataEntityID, @LoadTypeID, @SourceSystemAbbreviation
	
	--======================================================================================================================
	-- Generate drop statement for load proc
	--======================================================================================================================
	SELECT	@DropStatement =
				CONVERT(varchar(max), 'IF EXISTS (select p.name from sys.procedures p inner join sys.schemas s on s.schema_id = p.schema_id where p.name = ''sp_' 
										+ ltype.LoadTypeCode + '_' 
										+ @SourceSystemAbbreviation + '_' 
										+ dctarget.DataEntityName + ''' and s.name = ''' 
										+ @SourceSystemAbbreviation +''')' + CHAR(13) + CHAR(10) 
										+ 'BEGIN' + CHAR(13) + CHAR(10)
										+ CHAR(9) + 'DROP PROCEDURE ' + @SourceSystemAbbreviation 
										+ '.sp_' + ltype.LoadTypeCode +'_'+ @SourceSystemAbbreviation +'_' + dctarget.DataEntityName + CHAR(13) + CHAR(10) 
										+ 'END' + CHAR(13) + CHAR(10))
	--select	dcsource.*
	from	DMOD.LoadConfig lconfig
		inner join DMOD.LoadType ltype on lconfig.LoadTypeID = ltype.LoadTypeID
		inner join 
					(
						select	distinct  DataEntityID, SystemAbbreviation, DataEntityName
						from	DC.vw_rpt_DatabaseFieldDetail 
						where	DataEntityID = @SourceDataEntityID
					) dcsource on lconfig.SourceDataEntityID = dcsource.DataEntityID
		inner join 
					(
						select	distinct  DataEntityID, SystemAbbreviation, DataEntityName
						from	DC.vw_rpt_DatabaseFieldDetail 
						where	DataEntityID = @TargetDataEntityID
					) dctarget on lconfig.TargetDataEntityID = dctarget.DataEntityID
	where	LoadConfigID = @LoadConfigID

	/************************************************************************************************************************************************************************
	DEV NOTE (ID: DLT_FunctionReplacementList):		
		If a new function is created and linked to a paramater in the DMOD.LoadTypeParameter table
		, this list needs to be updated with the new function and pass in the correct parameters to execute the function.
		This gets passed into a # table which is then matched with the parameter link table to make sure that replacements do not get done by accident 
		and for future functionality use
	************************************************************************************************************************************************************************/
	--======================================================================================================================
	--List of all functions that exists that can be linked to templates to replace dynamic porsions of code
	--======================================================================================================================
	--FUTURE: Make this managable and dynamic - move to table for front end configuration etc.
	DROP TABLE IF EXISTS #FunctionReplacements
	CREATE TABLE #FunctionReplacements
		(
			  [ReplacementOrder] int
			, [TemplateParameterName] varchar(200)
			, [FunctionReplacementValue] varchar(max)
		)

	INSERT INTO #FunctionReplacements([ReplacementOrder], [TemplateParameterName], [FunctionReplacementValue])
	--TODO: Replace all function parameters with dynamic lookup parameters that get done before hand
		
		select	1 AS [ReplacementOrder]
				, '~@FieldList_CreateTable_Stage~' AS [TemplateParameterName]
				, [DMOD].[udf_get_FieldList_Create_Table_Stage](@LoadConfigID) AS FunctionReplacementValue		
		union
		select	2 AS [ReplacementOrder]
				, '~@FieldList_WithAlias_BK_ODS~' AS [TemplateParameterName]
				, [DMOD].[udf_get_FieldList_WithAlias_BK_ODS](@LoadConfigID) AS FunctionReplacementValue
		union
		select	3 AS [ReplacementOrder]
				, '~@FieldList_WithAlias_HashKeys_ODS~' AS [TemplateParameterName]
				, [DMOD].[udf_get_FieldList_WithAlias_HashKeys_ODS](@LoadConfigID) AS FunctionReplacementValue	
		union
		select	4 AS [ReplacementOrder]
				, '~@FieldList_WithAlias_ODS~' AS [TemplateParameterName]
				, [DMOD].[udf_get_FieldList_WithAlias_ODS](@LoadConfigID) AS FunctionReplacementValue		
		union
		
		select	5 AS [ReplacementOrder]
				, '~@FieldList_WithAlias_Stage~' AS [TemplateParameterName]
				, [DMOD].[udf_get_FieldList_WithAlias_Stage] (@LoadConfigID)  AS FunctionReplacementValue
		union
		select	6 AS [ReplacementOrder]
				, '~@JoinList_WithAlias_ODS~' AS [TemplateParameterName]
				, [DMOD].[udf_get_JoinList_WithAlias_ODS](@LoadConfigID) AS FunctionReplacementValue
		union
		select	7 AS [ReplacementOrder]
				, '~@LoadConfigID~' AS [TemplateParameterName]
				, [DMOD].[udf_get_LoadConfigID](@LoadConfigID) AS FunctionReplacementValue	
		union
		select	8 AS [ReplacementOrder]
				, '~@LoadTypeInfo~' AS [TemplateParameterName]
				, [DMOD].[udf_get_LoadTypeInfo](@LoadConfigID, @Author) AS FunctionReplacementValue
		
		union
		select	9 AS [ReplacementOrder]
				, '~@LoggingConventionNotes~' AS [TemplateParameterName]
				, [DMOD].[udf_get_LoggingConventionNotes]('SP01') AS FunctionReplacementValue -- Hard coded parameter	
		union 
		select	10 AS [ReplacementOrder]
				, '~@FieldList_WithNoAlias_ODS~' AS [TemplateParameterName]
				, [DMOD].[udf_get_FieldList_WithNoAlias_ODS](@LoadConfigID) AS FunctionReplacementValue			
	
		union 
		select	11 AS [ReplacementOrder]
				, '~@FieldList_WithNoAlias_Stage~' AS [TemplateParameterName]
				, [DMOD].[udf_get_FieldList_WithNoAlias_Stage](@LoadConfigID) AS FunctionReplacementValue					
		union 
		select	12 AS [ReplacementOrder]
				, '~@StageAreaSchemaName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_StageAreaSchemaName](@LoadConfigID) AS FunctionReplacementValue	
		union 
		select	13 AS [ReplacementOrder]
				, '~@LoadTypeCode~' AS [TemplateParameterName]
				, [DMOD].[udf_get_LoadTypeCode](@LoadConfigID) AS FunctionReplacementValue	
		union
		select	14 AS [ReplacementOrder]
				, '~@StageAreaTableName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_StageAreaTableName](@LoadConfigID) AS FunctionReplacementValue	
		union 
		select	15 AS [ReplacementOrder]
				, '~@DataVaultTableName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_DataVaultTableName](@LoadConfigID) AS FunctionReplacementValue	
		union 
		select	16 AS [ReplacementOrder]
				, '~@StageAreaVelocityTableName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_StageAreaVelocityTableName](@LoadConfigID) AS FunctionReplacementValue	
		union 
		select	17 AS [ReplacementOrder]
				, '~@ODSDatabaseName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_ODSDatabaseName](@LoadConfigID) AS FunctionReplacementValue	
		union 
		select	18 AS [ReplacementOrder]
				, '~@RecSrcDataEntityID~' AS [TemplateParameterName]
				, [DMOD].[udf_get_RecSrcDataEntityID](@LoadConfigID) AS FunctionReplacementValue	
		union 
		select	19 AS [ReplacementOrder]
				, '~@ODSDataEntityName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_ODSDataEntityName](@LoadConfigID) AS FunctionReplacementValue		
		union 
		select	20 AS [ReplacementOrder]
				, '~@TargetDataEntity~' AS [TemplateParameterName]
				, [DMOD].[udf_get_TargetDataEntity](@LoadConfigID) AS FunctionReplacementValue		
		union
		select	21 AS [ReplacementOrder]
				, '~@StageAreaHistTableName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_StageAreaHistoryTableName](@LoadConfigID) AS FunctionReplacementValue	
		union
		select	22 AS [ReplacementOrder]
				, '~@StageAreaProcName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_StageAreaProcName](@LoadConfigID) AS FunctionReplacementValue	
		union
		select	23 AS [ReplacementOrder]
				, '~@HashDiffForSatellite~' AS [TemplateParameterName]
				, [DMOD].[udf_get_FieldList_WithAlias_HashDiff](@LoadConfigID) AS FunctionReplacementValue	
		union
		select	24 AS [ReplacementOrder]
				, '~@LoadEntity_PKName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_LoadEntity_PKName](@LoadConfigID) AS FunctionReplacementValue
		union
		select	25 AS [ReplacementOrder]
				, '~@LoadEntity_NonClusteredIndex~' AS [TemplateParameterName]
				, [DMOD].[udf_get_LoadEntity_NonClusteredIndex](@LoadConfigID) AS FunctionReplacementValue
		union
		select	26 AS [ReplacementOrder]
				, '~@LoadSets_TempTableName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_LoadSets_TempTableName](@LoadConfigID) AS FunctionReplacementValue
		union
		select	27 AS [ReplacementOrder]
				, '~@LoadComparison_TempTableName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_LoadComparison_TempTableName](@LoadConfigID) AS FunctionReplacementValue
		union
		select	28 AS [ReplacementOrder]
				, '~@LoadEntity_TempTableName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_LoadEntity_TempTableName](@LoadConfigID) AS FunctionReplacementValue
		union
		select	29 AS [ReplacementOrder]
				, '~@DataVaultSchemaName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_DataVaultSchemaName](@LoadConfigID) AS FunctionReplacementValue
		union
		select	30 AS [ReplacementOrder]
				, '~@DataVaultDatabaseName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_DataVaultDatabaseName](@LoadConfigID) AS FunctionReplacementValue
		union
		select	31 AS [ReplacementOrder]
				, '~@StageAreaDatabaseName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_StageAreaDatabaseName](@LoadConfigID) AS FunctionReplacementValue
		union
		select	32 AS [ReplacementOrder]
				, '~@ODSSchemaName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_ODSSchemaName](@LoadConfigID) AS FunctionReplacementValue
		union
		select	33 AS [ReplacementOrder]
				, '~@StageAreaHistVelocityTableName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_StageAreaVelocityHistoryTableName](@LoadConfigID) AS FunctionReplacementValue	
		union
		select	34 AS [ReplacementOrder]
				, '~@Where_IncrementalLoadWithHistoryUpdate~' AS [TemplateParameterName]
				, [DMOD].[udf_get_WhereClause_IncrementalLoads](@LoadConfigID) AS FunctionReplacementValue	
		union
		select	35 AS [ReplacementOrder]
				, '~@SatelliteCreatedDT_Last~' AS [TemplateParameterName]
				, [DMOD].[udf_get_SatelliteCreatedDT_Last_Field](@LoadConfigID) AS FunctionReplacementValue	
		union
		select	36 AS [ReplacementOrder]
				, '~@SatelliteUpdatedDT_Last~' AS [TemplateParameterName]
				, [DMOD].[udf_get_SatelliteUpdatedDT_Last_Field](@LoadConfigID) AS FunctionReplacementValue	
		union
		select	37 AS [ReplacementOrder]
				, '~@SatelliteFullyQualifiedName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_SatelliteName_For_RelatedEntity](@LoadConfigID) AS FunctionReplacementValue	
		union
		select	38 AS [ReplacementOrder]
				, '~@LinkHashKeyComparison~' AS [TemplateParameterName]
				, [DMOD].[udf_get_LinkHK_StageArea](@LoadConfigID) AS FunctionReplacementValue	
		union
		select	39 AS [ReplacementOrder]
				, '~@DataVaultBusinessHashKeyName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_DataVaultBusinessHashKeyName](@LoadConfigID) AS FunctionReplacementValue
		union
		select	40 AS [ReplacementOrder]
				, '~@DataVaultEntityName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_DataVaultEntityName](@LoadConfigID) AS FunctionReplacementValue
		union
		select	41 AS [ReplacementOrder]
				, '~@FieldList_Without_BK_DV~' AS [TemplateParameterName]
				, [DMOD].[udf_get_FieldList_WithoutAlias_BK_DV](@LoadConfigID) AS FunctionReplacementValue 
		union
		select	42 AS [ReplacementOrder]
				, '~@FieldList_WithNoAlias_ODS~' AS [TemplateParameterName]
				, [DMOD].[udf_get_FieldList_WithNoAlias_ODS](@LoadConfigID) AS FunctionReplacementValue 
		union   
		select  43 AS [ReplacementOrder]
				, '~@DataVaultProcName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_DataVaultProcName](@LoadConfigID) AS FunctionReplacementValue 
		union  
		select  44 AS [ReplacementOrder]
				, '~@LinkHKName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_DataVault_LinkHKName](@LoadConfigID) AS FunctionReplacementValue 
		union   
		select  45 AS [ReplacementOrder]
				, '~@ParentHubHKName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_DataVault_ParentHubHKName](@LoadConfigID) AS FunctionReplacementValue 
		union   
		select  46 AS [ReplacementOrder]
				, '~@ChildHubHKName~' AS [TemplateParameterName]
				, [DMOD].[udf_get_DataVault_ChildHubHKName](@LoadConfigID) AS FunctionReplacementValue 		
		union   
		select  47 AS [ReplacementOrder]
				, '~@DataVaultEntityTypeCreatedDT_Last~' AS [TemplateParameterName]
				, [DMOD].[udf_get_DataVaultEntityType_CreatedDT_Last](@LoadConfigID) AS FunctionReplacementValue 
		union   
		select  48 AS [ReplacementOrder]
				, '~@DataVaultEntityTypeUpdatedDT_Last~' AS [TemplateParameterName]
				, [DMOD].[udf_get_DataVaultEntityType_UpdatedDT_Last](@LoadConfigID) AS FunctionReplacementValue 
			
	--======================================================================================================================
	-- Check if the parameter is linked to the load type template
	--======================================================================================================================
	IF(@IsDebug = 1)
	BEGIN
		SELECT	
			*
		FROM	
			#FunctionReplacements funcparm
	END

	--======================================================================================================================
	-- Generate create procedure statement
	--======================================================================================================================
	
	--Loop through the function replacement parameters and values. Replace the parameter placeholder with the function result set
	DECLARE ParameterCursor_FunctionValue CURSOR FOR
		SELECT	ParameterSearchValue = [TemplateParameterName]
				, ParameterReplacementValue = [FunctionReplacementValue]
		FROM	#FunctionReplacements
		WHERE	[FunctionReplacementValue] IS NOT NULL
			OR [FunctionReplacementValue] IS NOT NULL
		ORDER BY ReplacementOrder

		IF(@IsDebug = 1)
		BEGIN
			SELECT	 
				[TemplateParameterName]
			,	[FunctionReplacementValue]
			FROM	
				#FunctionReplacements
			WHERE	
				[FunctionReplacementValue] IS NOT NULL
			OR 
				[FunctionReplacementValue] IS NOT NULL
			ORDER BY 
				ReplacementOrder
		END


	OPEN ParameterCursor_FunctionValue

	FETCH NEXT FROM ParameterCursor_FunctionValue INTO @ParameterSearchValue, @ParameterReplacementValue 

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Replace parameter placeholders with function result sets
		WHILE CHARINDEX(@ParameterSearchValue, @ProcStatement, 0) > 0
		BEGIN	
			
			SELECT	@ProcStatement = REPLACE(@ProcStatement, @ParameterSearchValue, @ParameterReplacementValue)
			
		END

		FETCH NEXT FROM ParameterCursor_FunctionValue INTO @ParameterSearchValue, @ParameterReplacementValue
	END

	CLOSE ParameterCursor_FunctionValue
	DEALLOCATE ParameterCursor_FunctionValue
	
	IF NOT EXISTS (select name from sys.tables where name = N'LoadProcExports')
	CREATE TABLE [DMOD].[LoadProcExports](
		[LoadProcID] [int] IDENTITY(1,1) NOT NULL,
		[LoadConfigID] INT NOT NULL,
		[TableName] [varchar](100) NULL,
		[PScript] [varchar](max) NULL,
		[Author] [varchar](100) NULL,
		[CreatedDT] [datetime2](7) NULL,
		[RunNumber] INT NULL,
		[IsLastRun] BIT NULL,
		[Status] [varchar](100) NULL
	) ON [PRIMARY]
	

	DECLARE @RunCountOfLoadConfig INT = (
												SELECT 
													ISNULL(MAX([RunNumber]),0) 
												FROM 
													DMOD.[LoadProcExports] 
												WHERE 
													LoadConfigID  = @LoadConfigID
										)


	DECLARE @DatabasePurpose VARCHAR(200) = (
												SELECT 
													[DatabasePurposeCode] 
												FROM 
													DMOD.[vw_LoadConfig] 
												WHERE 
													[LoadConfigID] = @LoadConfigID
											
											)

	IF (@DatabasePurpose = 'StageArea')
	BEGIN
		INSERT INTO 
			DMOD.[LoadProcExports] 
			(
					[LoadConfigID]
				,	[TableName]
				,	[StoredProcName]
				,	[PScript]
				,	[Author]
				,	[CreatedDT]
				,	[RunNumber]
				,	[IsLastRun]
				,	[Status]
			)
		SELECT	
			@LoadConfigID AS [LoadConfig]
		,	[DMOD].[udf_get_StageAreaTableName](@LoadConfigID) AS [TableName]
		,	[DMOD].[udf_get_StageAreaProcName](@LoadConfigID) AS [StoredProcName]
		,	@ProcStatement AS [PScript]
		,	@Author AS [Author]
		,	GETDATE() AS [CreatedDT]
		,	@RunCountOfLoadConfig + 1 AS [RunNumber]
		,	1 AS [IsLastRun]
		,	'Generated, Not Deployed' AS [Status]
	END
	ELSE IF(@DatabasePurpose = 'DataVault')
	BEGIN
			INSERT INTO 
			DMOD.[LoadProcExports] 
			(
					[LoadConfigID]
				,	[TableName]
				,	[StoredProcName]
				,	[PScript]
				,	[Author]
				,	[CreatedDT]
				,	[RunNumber]
				,	[IsLastRun]
				,	[Status]
			)
		SELECT	
			@LoadConfigID AS [LoadConfig]
		,	[DMOD].[udf_get_DataVaultTableName](@LoadConfigID) AS [TableName]
		,	[DMOD].[udf_get_DataVaultProcName](@LoadConfigID) AS [StoredProcName]
		,	@ProcStatement AS [PScript]
		,	@Author AS [Author]
		,	GETDATE() AS [CreatedDT]
		,	@RunCountOfLoadConfig + 1 AS [RunNumber]
		,	1 AS [IsLastRun]
		,	'Generated, Not Deployed' AS [Status]
	END
	ELSE
	BEGIN
		INSERT INTO 
			DMOD.[LoadProcExports] 
			(
					[LoadConfigID]
				,	[TableName]
				,	[StoredProcName]
				,	[PScript]
				,	[Author]
				,	[CreatedDT]
				,	[RunNumber]
				,	[IsLastRun]
				,	[Status]
			)
		SELECT	
				@LoadConfigID AS [LoadConfig]
		,		[DMOD].[udf_get_StageAreaTableName](@LoadConfigID) AS [TableName]
		,		'LOAD CONFIG INCORRECT'  
		,		@ProcStatement  AS [PScriptAS [StoredProcName]
		,		@Author AS [Author]
		,		GETDATE() AS [CreatedDT]
		,		@RunCountOfLoadConfig + 1 AS [RunNumber]
		,		1 AS [IsLastRun]
		,		'Generated, Not Deployed' AS [Status]
	END

	-- Update  Non-Current Runs to 0 for IsLastRun
	UPDATE 
		DMOD.[LoadProcExports] 
	SET 
		[IsLastRun] = 0
	WHERE 
		[LoadConfigID] = @LoadConfigID
	AND 
		[RunNumber] != @RunCountOfLoadConfig + 1

	

	--======================================================================================================================
	--
	--======================================================================================================================

GO
