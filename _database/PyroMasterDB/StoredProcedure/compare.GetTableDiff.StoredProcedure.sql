SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[compare].[GetTableDiff]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [compare].[GetTableDiff] AS' 
END
GO

ALTER procedure [compare].[GetTableDiff]
AS

DECLARE 
	@DATABASE_LEFT		SYSNAME = ''
,	@DATABASE_RIGHT		SYSNAME = ''
,	@SCHEMA_LEFT		SYSNAME = 'ini'
,	@SCHEMA_RIGHT		SYSNAME = 'ext'
,	@ENTITY_LEFT		SYSNAME = 'BSEG_Accounting_Segment'
,	@ENTITY_RIGHT		SYSNAME = 'BSEG_Accounting_Segment'

DECLARE 
	@sql_statement 		NVARCHAR(MAX)
	
SET @sql_statement = '
	SELECT ENTLEFT.name as ENTLEFT_ColumnName, 
	ENTRIGHT.name as ENTRIGHT_ColumnName, 
	ENTLEFT.is_nullable as ENTLEFT_is_nullable, 
	ENTRIGHT.is_nullable as ENTRIGHT_is_nullable, 
	ENTLEFT.system_type_name as ENTLEFT_Datatype, 
	ENTRIGHT.system_type_name as ENTRIGHT_Datatype, 
	ENTLEFT.is_identity_column as ENTLEFT_is_identity, 
	ENTRIGHT.is_identity_column as ENTRIGHT_is_identity ,
	IIF(ENTLEFT.system_type_name = ENTRIGHT.system_type_name, 1, 0) AS is_system_type_match
	FROM sys.dm_exec_describe_first_result_set (
		N''SELECT * FROM ' + 
			QUOTENAME(@SCHEMA_LEFT) + '.' + QUOTENAME(@ENTITY_LEFT) + 
			''', NULL, 0) AS ENTLEFT 
	FULL OUTER JOIN  sys.dm_exec_describe_first_result_set (
		N''SELECT * FROM ' + 
			QUOTENAME(@SCHEMA_RIGHT) + '.' + QUOTENAME(@ENTITY_RIGHT) + 
		''', NULL, 0) AS ENTRIGHT
	ON ENTLEFT.name = ENTRIGHT.name
'
PRINT(@sql_statement)
EXECUTE sp_executesql
	@stmt = @sql_statement
	
GO
