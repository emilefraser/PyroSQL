SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE [DMOD].[sp_execute_ParamaterisedTemplateStoredProc]
AS


EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]
        @LoadTypeID = 1 --@LoadTypeID
  --  ,    @LoadTypeCode = 'StageFullLoad_KEYS'
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Customer]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Customer_EMS_KEYS]'
    ,    @StageAreaVelocityTable = '[DV_Customer_EMS_LVD]'
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName = '[HUB_Customer]'
    ,	 @SatelliteFullyQualifiedName = NULL
		,	 @CreatedDT_Field = NULL
	,	 @UpdatedDT_Field = NULL
	,	@DataVaultProcName = NULL
	--,    @LoadSets_TempTableName = '[#LoadSets_EMS_DV_Customer_EMS_KEYS]'
 --   ,    @LoadComparison_TempTableName = '[#LoadComparison_EMS_DV_Customer_EMS_KEYS]'
 --   ,    @LoadEntity_TempTableName = '[#LoadEntity_EMS_DV_Customer_EMS_KEYS]'
 --   ,    @LoadEntity_PKName = '[PK_EMS_DV_Customer_EMS_KEYS]'
 --   ,    @LoadEntity_NonClusteredIndexName = '[ncidx_EMS_DV_Customer_EMS_KEYS]'

-- VELOCITY (LVD)
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
         @LoadTypeID = 2 --@LoadTypeID
    --,    @LoadTypeCode = 'StageFullLoad_LVD' 		REPLACED with Lookup
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Customer]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Customer_EMS_LVD]'
    ,    @StageAreaVelocityTable = '[DV_Customer_EMS_LVD]'
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName = '[SAT_Customer_EMS_LVD]'
	 ,	 @SatelliteFullyQualifiedName = NULL
		,	 @CreatedDT_Field = NULL
	,	 @UpdatedDT_Field = NULL
	,	@DataVaultProcName = NULL
    --,    @LoadSets_TempTableName = '[#LoadSets_EMS_DV_Customer_EMS_LVD]'
    --,    @LoadComparison_TempTableName = '[#LoadComparison_EMS_DV_Customer_EMS_LVD]'
    --,    @LoadEntity_TempTableName = '[#LoadEntity_EMS_DV_Customer_EMS_LVD]'
    --,    @LoadEntity_PKName = '[PK_EMS_DV_Customer_EMS_LVD]'
    --,    @LoadEntity_NonClusteredIndexName = '[ncidx_EMS_DDV_Customer_EMS_LVD]'


-- VELOCITY (MVD)
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 3 --@LoadTypeID
   -- ,    @LoadTypeCode = 'StageFullLoad_MVD'
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Customer]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Customer_EMS_MVD]'
    ,    @StageAreaVelocityTable = '[DV_Customer_EMS_MVD]'
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName = '[SAT_Customer_EMS_MVD]'
 ,	 @SatelliteFullyQualifiedName = NULL
		,	 @CreatedDT_Field = NULL
	,	 @UpdatedDT_Field = NULL
	,	@DataVaultProcName = NULL
    --,    @LoadSets_TempTableName = '[#LoadSets_EMS_DV_Customer_EMS_MVD]'
    --,    @LoadComparison_TempTableName = '[#LoadComparison_EMS_DV_Customer_EMS_MVD]'
    --,    @LoadEntity_TempTableName = '[#LoadEntity_EMS_DV_Customer_EMS_MVD]'
    --,    @LoadEntity_PKName = '[PK_EMS_DV_Customer_EMS_MVD]'
    --,    @LoadEntity_NonClusteredIndexName = '[ncidx_EMS_DV_Customer_EMS_MVD]'
	

-- VELOCITY (HVD)
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 4 --@LoadTypeID
 --   ,    @LoadTypeCode = 'StageFullLoad_HVD'
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Customer]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Customer_EMS_HVD]'
    ,    @StageAreaVelocityTable = '[DV_Customer_EMS_HVD]'
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName = '[SAT_Customer_EMS_HVD]'
 ,	 @SatelliteFullyQualifiedName = NULL
		,	 @CreatedDT_Field = NULL
	,	 @UpdatedDT_Field = NULL
	,	@DataVaultProcName = NULL
   



--===========================================================================================
--========================= INCREMENTAL NO HISTORY UPDATE ===================================
--===========================================================================================

-- Keys
	EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]
        @LoadTypeID = 5 --@LoadTypeID
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Customer]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Customer_EMS_KEYS]'
    ,    @StageAreaVelocityTable = '[DV_Customer_EMS_LVD]'
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName = '[HUB_Customer]'
    ,	 @SatelliteFullyQualifiedName = '[SAT_Customer_EMS_LVD]'
	,	 @CreatedDT_Field = '[CREATEDDATETIME1]'
	,	 @UpdatedDT_Field = NULL
	,	@DataVaultProcName = NULL

 -- VELOCITY (LVD)
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 6 --@LoadTypeID
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Customer]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Customer_EMS_LVD]'
    ,    @StageAreaVelocityTable = '[DV_Customer_EMS_LVD]'
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName = '[SAT_Customer_EMS_LVD]'
    ,    @SatelliteFullyQualifiedName = '[SAT_Customer_EMS_LVD]'
		,	 @CreatedDT_Field = '[CREATEDDATETIME1]'
	,	 @UpdatedDT_Field = NULL
	,	@DataVaultProcName = NULL


	-- VELOCITY (MVD)
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 7 --@LoadTypeID
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Customer]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Customer_EMS_MVD]'
    ,    @StageAreaVelocityTable = '[DV_Customer_EMS_MVD]'
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName = '[SAT_Customer_EMS_MVD]'
    ,    @SatelliteFullyQualifiedName = '[SAT_Customer_EMS_MVD]'
		,	 @CreatedDT_Field = '[CREATEDDATETIME1]'
	,	 @UpdatedDT_Field = NULL
	,	@DataVaultProcName = NULL



-- VELOCITY (HVD)
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 8 --@LoadTypeID
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Customer]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Customer_EMS_HVD]'
    ,    @StageAreaVelocityTable = '[DV_Customer_EMS_HVD]'
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName = '[SAT_Customer_EMS_HVD]'
    ,    @SatelliteFullyQualifiedName = '[SAT_Customer_EMS_HVD]'
		,	 @CreatedDT_Field = '[CREATEDDATETIME1]'
	,	 @UpdatedDT_Field = NULL
		,	@DataVaultProcName = NULL

--=============================================================================================
--========================= INCREMENTAL WITH HISTORY UPDATE ===================================
--=============================================================================================


	-- KEYS (Standard Table)
	EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]
        @LoadTypeID = 9 --@LoadTypeID
  --  ,    @LoadTypeCode = 'StageFullLoad_KEYS'
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Customer]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Customer_EMS_KEYS]'
    ,    @StageAreaVelocityTable = '[DV_Customer_EMS_LVD]'
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName = '[HUB_Customer]'
    ,	 @SatelliteFullyQualifiedName = '[SAT_Customer_EMS_LVD]'
	,	 @CreatedDT_Field = '[CREATEDDATETIME1]'
	,	 @UpdatedDT_Field = '[MODIFIEDDATETIME1]'
	,	@DataVaultProcName = NULL

 -- VELOCITY (LVD)
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 10 --@LoadTypeID
 --   ,    @LoadTypeCode = 'StageFullLoad_LVD'
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Customer]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Customer_EMS_LVD]'
    ,    @StageAreaVelocityTable = '[DV_Customer_EMS_LVD]'
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName = '[SAT_Customer_EMS_LVD]'
    ,    @SatelliteFullyQualifiedName = '[SAT_Customer_EMS_LVD]'
		,	 @CreatedDT_Field = '[CREATEDDATETIME1]'
	,	 @UpdatedDT_Field = '[MODIFIEDDATETIME1]'
	,	@DataVaultProcName = NULL


	-- VELOCITY (MVD)
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 11 --@LoadTypeID
 --   ,    @LoadTypeCode = 'StageFullLoad_MVD'
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Customer]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Customer_EMS_MVD]'
    ,    @StageAreaVelocityTable = '[DV_Customer_EMS_MVD]'
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName = '[SAT_Customer_EMS_MVD]'
    ,    @SatelliteFullyQualifiedName = '[SAT_Customer_EMS_MVD]'
		,	 @CreatedDT_Field = '[CREATEDDATETIME1]'
	,	 @UpdatedDT_Field = '[MODIFIEDDATETIME1]'
	,	@DataVaultProcName = NULL



-- VELOCITY (HVD)
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 12 --@LoadTypeID
 --   ,    @LoadTypeCode = 'StageFullLoad_HVD'
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Customer]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Customer_EMS_HVD]'
    ,    @StageAreaVelocityTable = '[DV_Customer_EMS_HVD]'
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName = '[SAT_Customer_EMS_HVD]'
    ,    @SatelliteFullyQualifiedName = '[SAT_Customer_EMS_HVD]'
		,	 @CreatedDT_Field = '[CREATEDDATETIME1]'
	,	 @UpdatedDT_Field = '[MODIFIEDDATETIME1]'
		,	@DataVaultProcName = NULL



-- HUB (VAULT)
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 33 --@LoadTypeID
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Branch]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Branch]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Branch_EMS_KEYS]'
    ,    @StageAreaVelocityTable = NULL
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName =  NULL
    ,    @SatelliteFullyQualifiedName = NULL
	,	 @CreatedDT_Field = NULL
	,	 @UpdatedDT_Field =  NULL
	,	@DataVaultProcName = '[sp_loadhub_EMS_Branch]'


	
-- HUB (LINK)
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 34 --@LoadTypeID
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Branch]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Customer_EMS_KEYS]'
    ,    @StageAreaVelocityTable = NULL
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName =  NULL
    ,    @SatelliteFullyQualifiedName = NULL
	,	 @CreatedDT_Field = NULL
	,	 @UpdatedDT_Field =  NULL
	,	 @DataVaultProcName = '[sp_loadlink_EMS_Branch_Customer]'

	
-- SAT (LVD)
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 35 --@LoadTypeID
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Branch]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Branch]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Branch_EMS_LVD]'
    ,    @StageAreaVelocityTable = NULL
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName =  NULL
    ,    @SatelliteFullyQualifiedName = NULL
	,	 @CreatedDT_Field = NULL
	,	 @UpdatedDT_Field =  NULL
	,	@DataVaultProcName = '[sp_loadsat_EMS_Branch_LVD]'



	
-- HUB (VAULT)
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 36 --@LoadTypeID
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Branch]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Branch]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Branch_EMS_MVD]'
    ,    @StageAreaVelocityTable = NULL
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName =  NULL
    ,    @SatelliteFullyQualifiedName = NULL
	,	 @CreatedDT_Field = NULL
	,	 @UpdatedDT_Field =  NULL
	,	@DataVaultProcName = '[sp_loadsat_EMS_Branch_MVD]'


	


	
-- HUB (VAULT)
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 37 --@LoadTypeID
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Branch]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Branch]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Branch_EMS_HVD]'
    ,    @StageAreaVelocityTable = NULL
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName =  NULL
    ,    @SatelliteFullyQualifiedName = NULL
		,	 @CreatedDT_Field = NULL
	,	 @UpdatedDT_Field =  NULL
	,	@DataVaultProcName = '[sp_loadsat_EMS_Branch_HVD]'


	SELECT * FROM DMOD.LoadType
	
	-- REF Table
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 48 --@LoadTypeID
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Customer]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Branch_EMS_KEYS]'
    ,    @StageAreaVelocityTable = NULL
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName =  NULL
    ,    @SatelliteFullyQualifiedName = NULL
		,	 @CreatedDT_Field = NULL
	,	 @UpdatedDT_Field =  NULL
	,	@DataVaultProcName = '[sp_loadref_EMS_Branch]'

	-- REFSAT
EXEC DataManager.[DMOD].[sp_load_ParamaterisedTemplateStoredProc]  
        @LoadTypeID = 49
    ,    @IsMajorVersionUpdate = 0
    ,    @TargetDataEntity = '[Customer]'
    ,    @ODSDatabaseName = '[DEV_ODS_EMS]'
    ,    @ODSSchemaName    = '[DV]'
    ,    @ODSDataEntityName    = '[Customer]'
    ,    @StageAreaDatabaseName = '[DEV_StageArea]'
    ,    @StageAreaSchemaName = '[EMS]'
    ,    @StageAreaTableName = '[DV_Branch_EMS_LVD]'
    ,    @StageAreaVelocityTable = NULL
    ,    @DataVaultDatabaseName = '[DEV_DataVault]'
    ,    @DataVaultSchemaName = '[raw]'
    ,    @DataVaultTableName =  NULL
    ,    @SatelliteFullyQualifiedName = NULL
		,	 @CreatedDT_Field = NULL
	,	 @UpdatedDT_Field =  NULL
	,	@DataVaultProcName = '[sp_loadrefsat_EMS_Branch_LVD]'

GO
