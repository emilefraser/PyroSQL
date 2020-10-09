SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*

Proc to DROP/RECREATE USER TYPE for Logging to [ETL].[ExecutionLog]


EXEC [ETL].[sp_generate_ExecutionLog_UserDefinedDataTable] 

*/
CREATE PROCEDURE [ETL].[sp_generate_ExecutionLog_UserDefinedDataTable] 

AS 

	-- TODO: Which Procs are using this UDTT and drop dependency
	DROP TYPE IF EXISTS [ETL].[udtt_LoadConfig] 

	CREATE TYPE [ETL].[udtt_LoadConfig] AS TABLE
	(
		 DatabaseName varchar(100) NULL
		,SchemaName varchar(100) NULL
		,swStart_FinishLogEntry int NULL
		,ExecutionLogID_In int NULL
		,LoadConfigID int NULL
		,QueuedForProcessingDT datetime2(7) NULL
		,IsReload bit NULL
		,ErrorMessage varchar(500) NULL
		,DataEntityName varchar(100) NULL
		,NewRowCount int NULL
		,IsError int NULL
		,LastProcessingKeyValue varchar(max) NULL
		,DeletedRowCount int NULL
		,SourceRowCount int NULL
		,SourceTableSizeBytes int NULL
		,TargetRowCount int NULL
		,TargetTableSizeBytes int NULL
		,UpdatedRowBytes int NULL
		,UpdatedRowCount int NULL
		,NewRowsBytes int NULL
		,RowsTransferred int NULL
		,InitialTargetRowCount int NULL
		,InitialTargetTableSizeBytes int NULL
	)

GO
