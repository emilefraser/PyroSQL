DECLARE 
	@DATABASE_LEFT		SYSNAME =
,	@DATABASE_RIGHT		SYSNAME =
,	@SCHEMA_LEFT		SYSNAME = 'lnd'
,	@SCHEMA_RIGHT		SYSNAME = 'ini'
,	@ENTITY_LEFT		SYSNAME = 'BSEG_Accounting_Segment'
,	@ENTITY_RIGHT		SYSNAME = 'BSEG_Accounting_Segment'

DECLARE 
	@sql_statement 		NVARCHAR
	
SET @sql_statement = '
	SELECT ENTLEFT.name as ENTLEFT_ColumnName, 
	ENTRIGHT.name as ENTRIGHT_ColumnName, 
	ENTLEFT.is_nullable as ENTLEFT_is_nullable, 
	ENTRIGHT.is_nullable as ENTRIGHT_is_nullable, 
	ENTLEFT.system_type_name as ENTLEFT_Datatype, 
	ENTRIGHT.system_type_name as ENTRIGHT_Datatype, 
	ENTLEFT.is_identity_column as ENTLEFT_is_identity, 
	ENTRIGHT.is_identity_column as ENTRIGHT_is_identity  
	FROM sys.dm_exec_describe_first_result_set (
		N'''SELECT * FROM ' + 
			QUOTENAME(@SCHEMA_LEFT) + '.' + QUOTENAME(@ENTITY_LEFT) + ''', NULL, 0) AS ENTLEFT 
	FULL OUTER JOIN  sys.dm_exec_describe_first_result_set (
			N'''SELECT * FROM ' + 
		QUOTENAME(@SCHEMA_RIGHT) + '.' + QUOTENAME(@ENTITY_RIGHT) + ''', NULL, 0) AS ENTRIGHT
	ON ENTLEFT.name = ENTRIGHT.name
'

EXECUTE sp_executesql
	stmt = @sql_statement
	
