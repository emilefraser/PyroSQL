SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

--===============================================================================================================================
--Stored Proc Version Control
--===============================================================================================================================
/*
	Create date:						| 2019-01-08
	Author:								| Frans Germishuizen
	Description:						| Create paramaterised template from static template	
*/


-- Sample execution
/*

DECLARE @LoadTypeID int
DECLARE @IsMajorVersionUpdate bit
DECLARE @ODSDatabaseName varchar(100)
DECLARE @StageAreaTableName varchar(100)
DECLARE @StageAreaVelocityTable varchar(100)
DECLARE @StageAreaSchemaName varchar(100)
DECLARE @DataVaultTableName varchar(100)
DECLARE @LoadTypeCode varchar(50)

set		@LoadTypeID = 1
set		@IsMajorVersionUpdate = 0
set		@ODSDatabaseName = 'ODS_XT900'
set		@StageAreaTableName = 'dbo_Employee_KEYS'
set		@StageAreaVelocityTable = REPLACE(@StageAreaTableName, 'KEYS', 'LVD')
set		@StageAreaSchemaName = 'XT'
set		@DataVaultTableName = 'HUB_Employee'
set		@LoadTypeCode = 'StageFullLoad_KEYS'
		

EXECUTE [DMOD].[sp_load_ParamaterisedTemplateStoredProc] 
   @LoadTypeID
  ,@IsMajorVersionUpdate
  ,@ODSDatabaseName
  ,@StageAreaTableName
  ,@StageAreaVelocityTable
  ,@StageAreaSchemaName
  ,@DataVaultTableName
  ,@LoadTypeCode
GO



*/

CREATE PROCEDURE [DMOD].[sp_load_ParamaterisedTemplateStoredProc]
(
		@LoadTypeID int
	--,	@LoadTypeCode varchar(50)		REPLACED with Lookup
	,	@IsMajorVersionUpdate bit
	,	@TargetDataEntity varchar(100)
	,	@ODSDatabaseName varchar(100)
	,	@ODSSchemaName VARCHAR(100) 
	,	@ODSDataEntityName varchar(100)

	,	@StageAreaDatabaseName varchar(100)
	,	@StageAreaSchemaName varchar(100)
	,	@StageAreaTableName varchar(100)
	,	@StageAreaVelocityTable varchar(100)
	
	,	@DataVaultDatabaseName VARCHAR(100)
	,	@DataVaultSchemaName VARCHAR(100)
	,	@DataVaultTableName varchar(100)

	,	@SatelliteFullyQualifiedName VARCHAR(100)

	,	 @CreatedDT_Field  VARCHAR(100)
	,	 @UpdatedDT_Field  VARCHAR(100)
	,	 @DataVaultProcName VARCHAR(150)

	
)
AS
    -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
    SET NOCOUNT ON
/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
--Stored Proc Management
	--===============================================================================================================================
	--Variable workbench
	--===============================================================================================================================
	--Stored Proc Varialbles
	declare   @TemplateScript varchar(max)
			, @ParameterSearchValue VARCHAR(100)
			, @ParameterName VARCHAR(100)	
			, @StageAreaHistTableName varchar(100)
			, @StageAreaHistVelocityTable varchar(100)


	DECLARE @LoadTypeCode varchar(100) =  (SELECT LoadTypeCode FROM [DMOD].[LoadType] WHERE LoadTypeID = @LoadTypeID)

	DECLARE @LoadSets_TempTableName VARCHAR(150) = QUOTENAME('#LoadSets_' + PARSENAME(@StageAreaSchemaName,1) + '_' + PARSENAME(@StageAreaTableName,1))
    DECLARE @LoadComparison_TempTableName VARCHAR(150) = QUOTENAME('#LoadComparison_' + PARSENAME(@StageAreaSchemaName,1)  + '_' + PARSENAME(@StageAreaTableName,1))
    DECLARE @LoadEntity_TempTableName VARCHAR(150) = QUOTENAME('#LoadEntity_' + PARSENAME(@StageAreaSchemaName,1)  + '_' + PARSENAME(@StageAreaTableName,1))
    DECLARE @LoadEntity_PKName VARCHAR(150) = QUOTENAME('PK_' + PARSENAME(@StageAreaSchemaName,1)  + '_' + PARSENAME(@StageAreaTableName,1))
    DECLARE @LoadEntity_NonClusteredIndexName VARCHAR(150)  = QUOTENAME('ncix_' + PARSENAME(@StageAreaSchemaName,1)  + '_' + PARSENAME(@StageAreaTableName,1))


		

		--set		@LoadEntity_PKName = QUOTENAME('PK_' +  REPLACE(REPLACE(@StageAreaSchemaName,']',''),'[','') + '_' + REPLACE(REPLACE(@StageAreaTableName,']',''),'[',''))			
		--set		@LoadEntity_NonClusteredIndexName = QUOTENAME('ncidx_' + REPLACE(REPLACE(@StageAreaSchemaName,']',''),'[','') + '_' + REPLACE(REPLACE(@StageAreaTableName,']',''),'[',''))
		set		@StageAreaHistTableName = '[' + @StageAreaTableName + '_Hist' + ']'
		set		@StageAreaHistVelocityTable ='[' + @StageAreaVelocityTable + '_Hist' + ']'

		declare @StageAreaProcName varchar(100) = '[' + 'sp_' + @LoadTypeCode + '_' 
												+ REPLACE(REPLACE(@StageAreaSchemaName,']',''),'[','') + '_' 
												+ REPLACE(REPLACE(@StageAreaTableName,']',''),'[','') + ']'

		DECLARE @DataVaultEntityName VARCHAR(150)
		DECLARE @DataVaultBusinessHashKeyName VARCHAR(150)
		DECLARE @DataVaultEntityType VARCHAR(20) = (SELECT DataEntityTypeCode FROM DMOD.vw_LoadType WHERE LoadTypeID = @LoadTypeID)
			

		-- LINK Specific Replacements
		DECLARE @LinkHKName VARCHAR(200)
		DECLARE @ParentHubHKName VARCHAR(200)
		DECLARE @ChildHubHKName VARCHAR(200)

		IF (@DataVaultEntityType = 'HUB')
		BEGIN
			SET @DataVaultEntityName = (SELECT QUOTENAME(REPLACE(REPLACE(PARSENAME(@DataVaultProcName,1), 'sp_loadhub', 'HUB'), PARSENAME(@StageAreaSchemaName, 1) + '_', '')))
			SET @DataVaultBusinessHashKeyName = REPLACE(@DataVaultEntityName, 'HUB_', 'HK_')
		END
		ELSE IF  (@DataVaultEntityType = 'LINK')
		BEGIN

			--DECLARE @DataVaultProcName  VARCHAR(200) = '[sp_loadlink_Branch_Customer]'
			--DECLARE @DataVaultProcName VARCHAR(200) = '[sp_loadlink_Branch_Customer]'
			--DECLARE @StageAreaSchemaName VARCHAR(200) = '[EMS]'
			--DECLARE @DataVaultEntityName VARCHAR(200)
			--DECLARE @DataVaultBusinessHashKeyName VARCHAR(200)

			SET @DataVaultEntityName = (SELECT QUOTENAME(REPLACE(REPLACE(PARSENAME(@DataVaultProcName,1), 'sp_loadlink', 'LINK'), PARSENAME(@StageAreaSchemaName, 1) + '_', '')))
			SELECT @DataVaultEntityName
			SET @DataVaultBusinessHashKeyName = REPLACE(@DataVaultEntityName, 'LINK_', 'HK_')
			SELECT @DataVaultBusinessHashKeyName

			-- LINK Specific Replacements
			SET @LinkHKName = (SELECT QUOTENAME(REPLACE(PARSENAME(@DataVaultEntityName,1), 'LINK_', 'LINKHK_')))
			
			SET @ParentHubHKName = (SELECT REPLACE(PARSENAME(@DataVaultEntityName,1), 'LINK_', ''))
			SET @ParentHubHKName = (SELECT QUOTENAME('HK_' + SUBSTRING(@ParentHubHKName, 1, CHARINDEX('_', @ParentHubHKName) - 1)))

			SET @ChildHubHKName = (SELECT REPLACE(PARSENAME(@DataVaultEntityName,1), 'LINK_', ''))
			SET @ChildHubHKName = (SELECT QUOTENAME('HK_' + SUBSTRING(@ChildHubHKName, CHARINDEX('_', @ChildHubHKName) + 1, 150)))

		END
		ELSE IF (@DataVaultEntityType = 'SATLVD' OR @DataVaultEntityType = 'SATMVD' OR @DataVaultEntityType = 'SATHVD')
		BEGIN 
			SET @DataVaultEntityName = REPLACE(REPLACE(PARSENAME(@DataVaultProcName,1), 'sp_loadsat', 'SAT'), PARSENAME(@StageAreaSchemaName, 1) + '_', '')
			DECLARE @SatVelocitySuffix VARCHAR(10) = (SELECT DataEntityNamingSuffix FROM DMOD.vw_LoadType WHERE LoadTypeID = @LoadTypeID)
			SET @DataVaultEntityName = QUOTENAME(REPLACE(@DataVaultEntityName, @SatVelocitySuffix, '') + '_' + PARSENAME(@StageAreaSchemaName, 1) + @SatVelocitySuffix)
			SET @DataVaultBusinessHashKeyName = QUOTENAME(REPLACE(REPLACE(REPLACE(PARSENAME(@DataVaultEntityName,1), 'SAT_', 'HK_'), @SatVelocitySuffix, ''), '_' + PARSENAME(@StageAreaSchemaName, 1),''))

		END

		ELSE IF(@DataVaultEntityType = 'REF')
		BEGIN
			SET @DataVaultEntityName = (SELECT QUOTENAME(REPLACE(REPLACE(PARSENAME(@DataVaultProcName,1), 'sp_loadref', 'REF'), PARSENAME(@StageAreaSchemaName, 1) + '_', '')))
			SET @DataVaultBusinessHashKeyName = REPLACE(@DataVaultEntityName, 'REF_', 'HK_')
		END
		ELSE IF(@DataVaultEntityType = 'REFSAT')
		BEGIN
			SET @DataVaultEntityName = REPLACE(REPLACE(PARSENAME(@DataVaultProcName,1), 'sp_loadrefsat', 'REFSAT'), PARSENAME(@StageAreaSchemaName, 1) + '_', '')
			SET @SatVelocitySuffix  = '_LVD'
			SET @DataVaultEntityName = QUOTENAME(REPLACE(@DataVaultEntityName, @SatVelocitySuffix, '') + '_' + PARSENAME(@StageAreaSchemaName, 1) + @SatVelocitySuffix)
			SET @DataVaultBusinessHashKeyName  = QUOTENAME(REPLACE(REPLACE(REPLACE(PARSENAME(@DataVaultEntityName,1), 'REFSAT_', 'HK_'), @SatVelocitySuffix, ''), '_' + PARSENAME(@StageAreaSchemaName, 1),''))
		END


/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
	
	--======================================================================================================================
	--Create history version of the template script before updating
	--======================================================================================================================

	--EXECUTE [DMOD].[sp_audit_LoadType] @LoadTypeID

	--======================================================================================================================
	--Get static template from DMOD.LoadType
	--======================================================================================================================
    select	@TemplateScript = StaticTemplateScript
	from	DMOD.LoadType
	where	LoadTypeID = @LoadTypeID

	
	--======================================================================================================================
	--Replace dynamic componenets in the static script with variables that will be replaced when itterating through 
	-- the DMOD.LoadConfig table to generate the stored procs for the configured tables
	--======================================================================================================================
    
	--TODO: Replace static replace statements with dynamic sql that loops through the load type parameter table
	--======================================================================================================================
	--Static value replacements
	--======================================================================================================================
	--Union all static value parameter replacement values from stored proc parameter list
	--FUTURE: Develop a front end screen for template type mappings etc. (map parameters)
	DROP TABLE IF EXISTS #StaticParameterReplacements
	CREATE TABLE #StaticParameterReplacements
		(
			ReplacementOrder int, 
			VariableValue varchar(500),
			ParameterName varchar(500)
		)
	
	--FUTURE: Figure out a way to make this more dynamic and how to map it to the specific parameter type values
	 
	-- select	LoadTypeID, LoadTypeParameterID, count(1)
	-- from	[DMOD].LinkLoadTypeToLoadTypeParameter
	---- where	LoadTypeID = 3
	-- group by LoadTypeID, LoadTypeParameterID
	-- having count(1) > 1
	-- order by 3


	INSERT INTO #StaticParameterReplacements (ReplacementOrder, VariableValue, ParameterName)
	select 1 AS ReplacementOrder
		, @StageAreaProcName					, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@StageAreaProcName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) union
	select 2 AS ReplacementOrder
		, @LoadTypeCode					, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@LoadTypeCode~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) 
										  union
	select 3 AS ReplacementOrder
		, @ODSDataEntityName			, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@ODSDataEntityName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) 
										  union
	select 4 AS ReplacementOrder
		, @TargetDataEntity			, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@TargetDataEntity~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  )  union
	select 5 AS ReplacementOrder
		, @StageAreaTableName			, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@StageAreaTableName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) union 
	select 6 AS ReplacementOrder
		, '[' + REPLACE(REPLACE(@StageAreaHistTableName,']',''),'[','') + ']'
										, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@StageAreaHistTableName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) union
	select 7 AS ReplacementOrder
		, '[' + REPLACE(REPLACE(@StageAreaVelocityTable,']',''),'[','') + ']'		
										, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@StageAreaVelocityTableName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) union
	select 8 AS ReplacementOrder
		, '[' + REPLACE(REPLACE(@StageAreaHistVelocityTable,']',''),'[','') + ']'	
										, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@StageAreaHistVelocityTableName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) union
	select 9 AS ReplacementOrder
		, @DataVaultTableName			, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@DataVaultTableName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) 
										  union
	select 10 AS ReplacementOrder
		, @ODSDatabaseName				, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@ODSDatabaseName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) union 
	select 11 AS ReplacementOrder
		, @ODSSchemaName			, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@ODSSchemaName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) union 
										  
	select 12 AS ReplacementOrder
		, @StageAreaSchemaName			, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@StageAreaSchemaName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) union
	

		  
	select 13 AS ReplacementOrder
		, @StageAreaDatabaseName			, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@StageAreaDatabaseName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) 
		  union
	select 14 AS ReplacementOrder
		, @DataVaultDatabaseName			, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@DataVaultDatabaseName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) 
		union
	select 15 AS ReplacementOrder
		, @DataVaultSchemaName			, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@DataVaultSchemaName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) 
	union
	select 16 AS ReplacementOrder
		, @LoadEntity_PKName			, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@LoadEntity_PKName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) union
	select 17 AS ReplacementOrder
		, @LoadEntity_NonClusteredIndexName
										, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@LoadEntity_NonClusteredIndex~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) union
	select 18 AS ReplacementOrder
		, @LoadSets_TempTableName
										, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@LoadSets_TempTableName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) union
	select 19 AS ReplacementOrder
		, @LoadComparison_TempTableName
										, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@LoadComparison_TempTableName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) union
	select 20 AS ReplacementOrder
		, @LoadEntity_TempTableName
										, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@LoadEntity_TempTableName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) union
	select 21 AS ReplacementOrder
		, @CreatedDT_Field
										, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@SatelliteCreatedDT_Last~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  )  union
	select 22 AS ReplacementOrder
		, @UpdatedDT_Field 
										, (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@SatelliteUpdatedDT_Last~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) 
										  union
	
	select 23 AS ReplacementOrder
		, @SatelliteFullyQualifiedName
										,  (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@SatelliteFullyQualifiedName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) 

										union
	
	select 24 AS ReplacementOrder
		, @DataVaultProcName
										,  (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@DataVaultProcName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) 

										union
	select 25 AS ReplacementOrder
		, @DataVaultEntityName
										,  (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@DataVaultEntityName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) 


										union
	select 26 AS ReplacementOrder
		, @DataVaultBusinessHashKeyName
										,  (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@DataVaultBusinessHashKeyName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) 
										  union
	select 27 AS ReplacementOrder
		, @LinkHKName
										,  (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@LinkHKName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) 
										  union
	select 28 AS ReplacementOrder
		, @ParentHubHKName
										,  (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@ParentHubHKName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) 
										  union
	select 29 AS ReplacementOrder
		, @ChildHubHKName
										,  (	select	ParameterName
											from	[DMOD].LoadType ltype
												inner join [DMOD].LinkLoadTypeToLoadTypeParameter parmlink on parmlink.LoadTypeID = ltype.LoadTypeID
												inner join [DMOD].[LoadTypeParameter] parm on parm.LoadTypeParameterID = parmlink.LoadTypeParameterID
											where	ltype.LoadTypeID = @LoadTypeID
												and parm.ParameterName = '~@ChildHubHKName~'
												and IsStaticReplacementValue = 1
												and parm.IsActive = 1
										  ) 
										

	
	select	*
	from	#StaticParameterReplacements
	order by ReplacementOrder
	
	--Loop through the static replacement parameters and replace the static text with the parameter placeholder
	DECLARE ParameterCursor_StaticValue CURSOR FOR
		SELECT	ParameterSearchValue = VariableValue
				, ParameterName = ParameterName
		FROM	#StaticParameterReplacements
		WHERE	VariableValue IS NOT NULL
			OR ParameterName IS NOT NULL
	
	OPEN ParameterCursor_StaticValue

	FETCH NEXT FROM ParameterCursor_StaticValue INTO @ParameterSearchValue, @ParameterName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Replace Field Lists with alias
		WHILE CHARINDEX(@ParameterSearchValue, @TemplateScript, 0) > 0
		BEGIN	

			--PRINT @ParameterName
			--print @ParameterSearchValue

			select	@TemplateScript = REPLACE(@TemplateScript, @ParameterSearchValue, @ParameterName)
			
			--select	@TemplateScript = GENERAL.udf_Replace_WholeWordMatch(@TemplateScript, @ParameterSearchValue, @ParameterName)
			--select	@TemplateScript = REPLACE(@TemplateScript, '\b'+@ParameterSearchValue+'\b', @ParameterName)
			--select @TemplateScript
			
			--select	@TemplateScript = SUBSTRING(@TemplateScript, 0, CHARINDEX(@ParameterSearchValue, @TemplateScript, 0)) --Find the start of the @ParameterSearchValue
			--	+ @ParameterName --Inject the @ParameterName
			--	+ SUBSTRING(@TemplateScript, CHARINDEX('~!', @TemplateScript, CHARINDEX(@ParameterSearchValue, @TemplateScript, 0) + 1)+2, LEN(@TemplateScript)) --The remainder of the @TemplateScript after the close of the @ParameterSearchValue
		END

		--Fetch next from cursor
		FETCH NEXT FROM ParameterCursor_StaticValue INTO @ParameterSearchValue, @ParameterName

	END

	CLOSE ParameterCursor_StaticValue
	DEALLOCATE ParameterCursor_StaticValue

	--======================================================================================================================
	--List value replacements
	--======================================================================================================================
	
	DECLARE ParameterCursor_Lists CURSOR FOR
		SELECT	ParameterSearchValue, ParameterName--, LTP.ParameterValueReplacementSQLCode
		FROM	[DMOD].[LoadTypeParameter] LTP
			INNER JOIN [DMOD].[LinkLoadTypeToLoadTypeParameter] link ON link.LoadTypeParameterID = LTP.LoadTypeParameterID
		WHERE	LTP.IsStaticReplacementValue = 0
			AND LTP.IsActive = 1
			and link.LoadTypeID = @LoadTypeID
			--and ParameterValueReplacementSQLCode IS NOT NULL
	
	OPEN ParameterCursor_Lists

	FETCH NEXT FROM ParameterCursor_Lists INTO @ParameterSearchValue, @ParameterName

	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Replace Field Lists with alias
		WHILE CHARINDEX(@ParameterSearchValue, @TemplateScript, 0) > 0
		BEGIN	
			select	@TemplateScript = SUBSTRING(@TemplateScript, 0, CHARINDEX(@ParameterSearchValue, @TemplateScript, 0)) --Find the start of the @ParameterSearchValue
				+ @ParameterName --Inject the @ParameterName
				+ SUBSTRING(@TemplateScript, CHARINDEX('~!', @TemplateScript, CHARINDEX(@ParameterSearchValue, @TemplateScript, 0) + 1)+2, LEN(@TemplateScript)) --The remainder of the @TemplateScript after the close of the @ParameterSearchValue
		END

		--Fetch next from cursor
		FETCH NEXT FROM ParameterCursor_Lists INTO @ParameterSearchValue, @ParameterName

	END

	CLOSE ParameterCursor_Lists
	DEALLOCATE ParameterCursor_Lists
	
	DROP TABLE IF EXISTS DMOD.ParameterScriptTest

	select @TemplateScript AS PScript
	into	DMOD.ParameterScriptTest
	
	--*************************************************************************************************************************************
	--*************************************************************************************************************************************
	--Generate the whole script - this is testing code
	/*
	DECLARE @ProcStatement varchar(max)

	DECLARE sqlcursor CURSOR FOR   
		select	@TemplateScript
		
		--where	TableName = 'EMPLOYEE'

	OPEN sqlcursor  

	FETCH NEXT FROM sqlcursor   
	INTO @ProcStatement

	declare @i int = 0

		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			--SELECT @DropStatement
			--insert into DMOD.Stage_StaticLoadTemplate
			--SELECT @ProcStatement
			--EXEC (@DropStatement)
			--EXEC (@ProcStatement)
	
			WHILE @i < LEN(@ProcStatement)
			BEGIN
				SELECT SUBSTRING(@ProcStatement, @i, @i + 8000)
				select @i += 8000
			END

			FETCH NEXT FROM sqlcursor   
			INTO @ProcStatement 
		END     

	CLOSE sqlcursor;  
	DEALLOCATE sqlcursor;
	--*/
		
	--*************************************************************************************************************************************
	--*************************************************************************************************************************************

	--======================================================================================================================
	--Update DMOD.LoadType.[LoadScriptTemplate]
	--======================================================================================================================
    
	update	DMOD.LoadType
	set		[ParameterisedTemplateScript] = @TemplateScript
		, ModifiedDT = GETDATE()
			, IsStaticTemplateProcessed = 1
			, LoadScriptVersionNo = CASE WHEN @IsMajorVersionUpdate = 0
										THEN LoadScriptVersionNo + 0.1 -- Minor version update
										ELSE LoadScriptVersionNo + 1 --Major version update
									END 
	where	LoadTypeID = @LoadTypeID

	










/*

	/* COMMENTED OUT OLD CODE 2019-05-15 - REPLACED WITH ABOVE CODE
	---- Replace TableName
	--select	@TemplateScript = REPLACE(@TemplateScript, @StaticTemplate_TableName, '~@TableName~')

	---- Replace Source System Abbreviation
	--select	@TemplateScript = REPLACE(@TemplateScript, @StaticTemplate_SourceSystemAbbr, '~@SourceSystemAbbr~')

	---- Replace Load Type Code
	--select	@TemplateScript = REPLACE(@TemplateScript, @StaticTemplate_LoadTypeCode, (select LoadTypeCode from DMOD.LoadType where LoadTypeID = @LoadTypeID))	
	*/

	---- Replace Field Lists with alias
	--WHILE CHARINDEX('--!~ Field List with alias', @TemplateScript, 0) > 0
	--BEGIN	
	--	select	@TemplateScript = SUBSTRING(@TemplateScript, 0, CHARINDEX('--!~ Field List with alias', @TemplateScript, 0)) --1st portion of the proc before the create table statement
	--		+ '~@FieldListWithAlias~' -- Injecting the create table statement field list
	--		+ SUBSTRING(@TemplateScript, CHARINDEX('~!', @TemplateScript, CHARINDEX('--!~ Field List with alias', @TemplateScript, 0) + 1)+2, LEN(@TemplateScript)) --2nd portion of the proc after the create table filed list
	--END

	---- Replace Field Lists without alias
	--WHILE CHARINDEX('--!~ Field List with no alias', @TemplateScript, 0) > 0
	--BEGIN	
	--	select	@TemplateScript = SUBSTRING(@TemplateScript, 0, CHARINDEX('--!~ Field List with no alias', @TemplateScript, 0)) --1st portion of the proc before the create table statement
	--		+ '~@FieldListNoAlias~' -- Injecting the create table statement field list
	--		+ SUBSTRING(@TemplateScript, CHARINDEX('~!', @TemplateScript, CHARINDEX('--!~ Field List with no alias', @TemplateScript, 0) + 1)+2, LEN(@TemplateScript)) --2nd portion of the proc after the create table filed list
	--END

	---- Replace Create Table Field Lists
	--WHILE CHARINDEX('--!~ Field list for CREATE TABLE', @TemplateScript, 0) > 0
	--BEGIN
	
	--	select	@TemplateScript = SUBSTRING(@TemplateScript, 0, CHARINDEX('--!~ Field list for CREATE TABLE', @TemplateScript, 0)) --1st portion of the proc before the create table statement
	--		+ '~@CreateTableFieldList~' -- Injecting the create table statement field list
	--		+ SUBSTRING(@TemplateScript, CHARINDEX('~!', @TemplateScript, CHARINDEX('--!~ Field list for CREATE TABLE', @TemplateScript, 0) + 1)+2, LEN(@TemplateScript)) --2nd portion of the proc after the create table filed list
	--END 

--select	CHARINDEX('--~ Field list for CREATE TABLE', @TemplateScript, 0), CHARINDEX('~!', @TemplateScript, CHARINDEX('--!~ Field list for CREATE TABLE', @TemplateScript, 0) + 1)

--select	SUBSTRING(@TemplateScript, 0, CHARINDEX('--~ Field list for CREATE TABLE', @TemplateScript, 0)) --1st portion of the proc before the create table statement
--		+ '~CreateTableFieldList~' -- Injecting the create table statement field list
--		+ SUBSTRING(@TemplateScript, CHARINDEX('~!', @TemplateScript, CHARINDEX('--!~ Field list for CREATE TABLE', @TemplateScript, 0) + 1), LEN(@TemplateScript)) --2nd portion of the proc after the create table filed list


*/

GO
