USE tempdb;
GO

IF EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.ROUTINES r
	WHERE r.ROUTINE_SCHEMA = 'dbo' AND r.ROUTINE_NAME = 'GenerateCursorCommands'
)
	DROP PROCEDURE dbo.GenerateCursorCommands 
GO

--TODO: add params for @MoveToDataPath and @MoveToLogPath.
CREATE PROCEDURE dbo.GenerateCursorCommands
	@Database SYSNAME,
	@SchemaName SYSNAME,
	@TableName SYSNAME
/*
	Purpose:	
	Generates Cursor commands for an input table (or view).
	Copy and paste the output into an SSMS window.
	
	Inputs:
	@Database:	self-explanatory
	@SchemaName :  self-explanatory
	@TableName : self-explanatory
	
	History:
	11/18/2019	DBA	Created
*/
AS
SET NOCOUNT ON

CREATE TABLE #ResultSetDescription (
	is_hidden BIT NOT NULL,
	column_ordinal INT NOT NULL,
	name SYSNAME NULL,
	is_nullable BIT NOT NULL,
	system_type_id INT NOT NULL,
	system_type_name NVARCHAR(256) NULL,
	max_length SMALLINT NOT NULL,
	precision TINYINT NOT NULL,
	scale TINYINT NOT NULL,
	collation_name SYSNAME NULL,
	user_type_id INT NULL,
	user_type_database SYSNAME NULL,
	user_type_schema SYSNAME NULL,
	user_type_name SYSNAME NULL,
	assembly_qualified_type_name NVARCHAR(4000),
	xml_collection_id INT NULL,
	xml_collection_database SYSNAME NULL,
	xml_collection_schema SYSNAME NULL,
	xml_collection_name SYSNAME NULL,
	is_xml_document BIT NOT NULL,
	is_case_sensitive BIT NOT NULL,
	is_fixed_length_clr_type BIT NOT NULL,
	source_server NVARCHAR(128),
	source_database SYSNAME NULL,
	source_schema SYSNAME NULL,
	source_table SYSNAME NULL,
	source_column SYSNAME NULL,
	is_identity_column BIT NULL,
	is_part_of_unique_key BIT NULL,
	is_updateable BIT NULL,
	is_computed_column BIT NULL,
	is_sparse_column_set BIT NULL,
	ordinal_in_order_by_list SMALLINT NULL,
	order_by_list_length SMALLINT NULL,
	order_by_is_descending SMALLINT NULL,
	tds_type_id INT NOT NULL,
	tds_length INT NOT NULL,
	tds_collation_id INT NULL,
	tds_collation_sort_id TINYINT NULL
)
DECLARE @TsqlParam NVARCHAR(MAX) = N'SELECT * FROM ' + QUOTENAME(@Database) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName);
INSERT INTO #ResultSetDescription
EXEC sp_describe_first_result_set 
	@tsql = @TsqlParam;

--Quoted, comma-delimited list of columns.
DECLARE @ColumnList NVARCHAR(MAX) = '';
DECLARE @VariableList NVARCHAR(MAX) = '';
SELECT 
	@ColumnList = @ColumnList + QUOTENAME(d.name) + ', ',
	@VariableList = @VariableList + '@' + d.name + ', '
FROM #ResultSetDescription d
ORDER BY d.column_ordinal

SET @ColumnList = LEFT(RTRIM(@ColumnList), LEN(RTRIM(@ColumnList)) - 1) --trim trailing whitespace & comma
SET @VariableList = LEFT(RTRIM(@VariableList), LEN(RTRIM(@VariableList)) - 1) --trim trailing whitespace & comma

CREATE TABLE #TsqlCommands (
	ID INT IDENTITY PRIMARY KEY,
	Cmd VARCHAR(MAX)
)

INSERT INTO #TsqlCommands(Cmd)
SELECT 'DECLARE @' + d.name + ' ' + UPPER(d.system_type_name) + ';'
FROM #ResultSetDescription d
ORDER BY d.column_ordinal

INSERT INTO #TsqlCommands(Cmd) VALUES ('');
INSERT INTO #TsqlCommands(Cmd) VALUES ('DECLARE ' + QUOTENAME('cur' + @TableName) + ' CURSOR READ_ONLY FAST_FORWARD FOR');
INSERT INTO #TsqlCommands(Cmd) VALUES (CHAR(9) + 'SELECT ' + @ColumnList);
INSERT INTO #TsqlCommands(Cmd) VALUES (CHAR(9) + 'FROM ' + QUOTENAME(@Database) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ';');
INSERT INTO #TsqlCommands(Cmd) VALUES ('');
INSERT INTO #TsqlCommands(Cmd) VALUES ('OPEN ' + QUOTENAME('cur' + @TableName) + ';');
INSERT INTO #TsqlCommands(Cmd) VALUES ('FETCH NEXT FROM ' + QUOTENAME('cur' + @TableName) + ' INTO');
INSERT INTO #TsqlCommands(Cmd) VALUES (CHAR(9) + @VariableList + ';');
INSERT INTO #TsqlCommands(Cmd) VALUES ('');
INSERT INTO #TsqlCommands(Cmd) VALUES ('WHILE @@FETCH_STATUS = 0');
INSERT INTO #TsqlCommands(Cmd) VALUES ('BEGIN');
INSERT INTO #TsqlCommands(Cmd) VALUES ('');
INSERT INTO #TsqlCommands(Cmd) VALUES (CHAR(9) + 'FETCH NEXT FROM ' + QUOTENAME('cur' + @TableName) + ' INTO');
INSERT INTO #TsqlCommands(Cmd) VALUES (CHAR(9) + CHAR(9) + @VariableList + ';');
INSERT INTO #TsqlCommands(Cmd) VALUES ('END');
INSERT INTO #TsqlCommands(Cmd) VALUES ('');
INSERT INTO #TsqlCommands(Cmd) VALUES ('CLOSE ' + QUOTENAME('cur' + @TableName) + ';');
INSERT INTO #TsqlCommands(Cmd) VALUES ('DEALLOCATE ' + QUOTENAME('cur' + @TableName) + ';');

SELECT *
FROM #TsqlCommands c
ORDER BY c.ID

/*
	--Examples:
	EXEC dbo.GenerateCursorCommands @Database = 'master', @SchemaName = 'information_schema', @TableName = 'tables'
	EXEC dbo.GenerateCursorCommands @Database = 'model', @SchemaName = 'sys', @TableName = 'objects'
	EXEC dbo.GenerateCursorCommands @Database = 'AdventureWorks', @SchemaName = 'HumanResources', @TableName = 'Employee'
*/
