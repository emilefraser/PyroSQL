EXEC InfoMart.[dbo].[sp_materialise_InfoMartView] 
	@Source_SchemaName			= 'dbo'
,	@Source_DataEntityName			= 'vw_pres_BusinessGlossary'
,	@IsReCreateIndex				= 1
  
EXEC InfoMart.[dbo].[sp_materialise_InfoMartView] 
	@Source_SchemaName			= 'dbo'
,	@Source_DataEntityName			= 'vw_pres_CompanyInfo'
,	@IsReCreateIndex				= 1

EXEC InfoMart.[dbo].[sp_materialise_InfoMartView] 
	@Source_SchemaName			= 'dbo'
,	@Source_DataEntityName			= 'vw_pres_DimCurrentShifts'
,	@IsReCreateIndex				= 1

EXEC InfoMart.[dbo].[sp_materialise_InfoMartView] 
	@Source_SchemaName			= 'dbo'
,	@Source_DataEntityName			= 'vw_pres_DimDate'
,	@IsReCreateIndex				= 1

EXEC InfoMart.[dbo].[sp_materialise_InfoMartView] 
	@Source_SchemaName			= 'dbo'
,	@Source_DataEntityName			= 'vw_pres_DimDepartment'
,	@IsReCreateIndex				= 1

EXEC InfoMart.[dbo].[sp_materialise_InfoMartView] 
	@Source_SchemaName			= 'dbo'
,	@Source_DataEntityName			= 'vw_pres_DimEmployee'
,	@IsReCreateIndex				= 1

EXEC InfoMart.[dbo].[sp_materialise_InfoMartView] 
	@Source_SchemaName			= 'dbo'
,	@Source_DataEntityName			= 'vw_pres_DimEventType'
,	@IsReCreateIndex				= 1

EXEC InfoMart.[dbo].[sp_materialise_InfoMartView] 
	@Source_SchemaName			= 'dbo'
,	@Source_DataEntityName			= 'vw_pres_DimLocation'
,	@IsReCreateIndex				= 1

EXEC InfoMart.[dbo].[sp_materialise_InfoMartView] 
	@Source_SchemaName			= 'dbo'
,	@Source_DataEntityName			= 'vw_pres_DimGang'
,	@IsReCreateIndex				= 1

EXEC InfoMart.[dbo].[sp_materialise_InfoMartView] 
	@Source_SchemaName			= 'dbo'
,	@Source_DataEntityName			= 'vw_pres_ReportRegister'
,	@IsReCreateIndex				= 1

