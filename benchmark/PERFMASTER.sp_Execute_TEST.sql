SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- RUN TEST 
-- EXEC PERFTEST.sp_Execute_TEST
CREATE   PROCEDURE [PERFMASTER].[sp_Execute_TEST]
AS
DECLARE 
	   @SourceObject			SYSNAME = 'dbo.BRIDGE_StockTransaction'
	 , @TargetObject			SYSNAME = 'dbo.CALCSAT_Stock_DailyBalanceSnapshot'
	 , @IsReloadTestData		BIT = 0
	 , @TestRowsNeeded			INT = NULL
	 , @IterationCount			INT = 1
	 , @IsTruncateRunLogs		BIT = 1
	
	 , @sql_parameters			NVARCHAR(MAX)
	 , @sql_parameters_declare	NVARCHAR(MAX)
	 , @sql_parameters_value	NVARCHAR(MAX)
	 , @Today					DATETIME2(2) = GETDATE()
	 , @IsTest					BIT =1 
	 , @IsDebug					BIT = 1


SET @sql_parameters = N'@Today, @IsReload, @IsTest'

SET @sql_parameters_declare  = N' @Today DATE'
SET @sql_parameters_declare += N', @IsReload BIT'
SET @sql_parameters_declare += N', @IsTest BIT'

SET @sql_parameters_value  = N' @Today = ''' + FORMAT(@Today, 'dd/MM/yyyy') + ''''
SET @sql_parameters_value += N', @IsReload = ' + CONVERT(NVARCHAR, 0)
SET @sql_parameters_value += N', @IsTest = ' + CONVERT(NVARCHAR, 0)


EXEC PERFTEST.sp_Execute_TestOrchestrator
		@TestClass				= 'dbo',
		@TestName				= 'loadcalcsat_Stock_DailyBalanceSnapshot',
		@TestIterationName		= 'DualCTE_WithLAG',
		@SourceObject			= @SourceObject,
		@TargetObject			= @TargetObject,
		@IsReloadTestData		= @IsReloadTestData,
		@TestRowsNeeded			= @TestRowsNeeded,
		@IterationCount			= @IterationCount,
		@IsTruncateRunLogs		= @IsTruncateRunLogs,
		@sql_params				= @sql_parameters,
		@sql_declare			= @sql_parameters_declare,
		@sql_values				= @sql_parameters_value,
		@IsTest					= @IsTest,
		@IsDebug				= @IsDebug

GO
