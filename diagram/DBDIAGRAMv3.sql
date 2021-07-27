-- Main Generation Procedure
CREATE PROCEDURE #Generate_DbDiagram

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET STATISTICS IO OFF

DECLARE
	@DatabaseType					NVARCHAR(MAX)	= 'SQL Server'
,	@ProjectDescription				NVARCHAR(MAX)	= 'Business Glosary ERD'
,	@Schema_ToDiagram				SYSNAME			= 'BG'

DECLARE 
	@sql_statement					NVARCHAR(MAX)
,	@sql_parameter					NVARCHAR(MAX)
,	@sql_message					NVARCHAR(MAX)
,	@sql_crlf						NVARCHAR(2) = CHAR(13) + CHAR(10)
,	@sql_tab						NVARCHAR(1) = CHAR(9)
,	@sql_debug						BIT = 0
,	@sql_execute					BIT = 0

DECLARE 
	@Level00_project		NVARCHAR(MAX)
,	@level0_enums			NVARCHAR(MAX)
,	@level1_tables			NVARCHAR(MAX)
,	@level2_references		NVARCHAR(MAX)
,	@level012_final			NVARCHAR(MAX)

DECLARE
	@table_cursor			CURSOR
,	@schema_name			NVARCHAR(MAX)
,	@table_name				NVARCHAR(MAX)
,	@column_name			NVARCHAR(MAX)
,	@column_type			NVARCHAR(MAX)
,	@is_primarykey			NVARCHAR(MAX)

-- PROJECT DEFINITION
SET @Level00_project = '
//----------------------------------------------//
// Level 00 - Project
//----------------------------------------------//
Project project_name {
  database_type: ''' + @DatabaseType + '''
  Note: ''' + @ProjectDescription + '''
}
'

-- Finishing up project definitions
SET @Level00_project += @sql_crlf + '
//==============================================//
'
-- ENUMS DEFINITION
SET @level0_enums = '
//----------------------------------------------//
// Level 0 - Enums
//----------------------------------------------//
'

-- Finishing up enums definitions
SET @level0_enums += @sql_crlf + '
//==============================================//
'
-- TABLE DEFINITION
SET @level1_tables = '
//----------------------------------------------//
// Level 1 - Tables
//----------------------------------------------//
'

SET @table_cursor = CURSOR FOR 
SELECT
	sch.name, tab.name
FROM 
	sys.objects AS obj
INNER JOIN 
	sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN 
	sys.schemas AS sch
	ON sch.schema_id = tab.schema_id
WHERE
	obj.is_ms_shipped = 0
AND	
	sch.name = @Schema_ToDiagram

OPEN @table_cursor

FETCH NEXT FROM @table_cursor
INTO @schema_name, @table_name

WHILE(@@FETCH_STATUS = 0)
BEGIN
		
	--SELECT @schema_name, @table_name

	-- Kicks off the Table Definition
	SET @level1_tables += 'Table ' + @table_name +  ' {' + @sql_crlf
	
	SELECT 
		-- Combine existing string with Column Name, Column Type and Open Square Bracket for the Column Definition
		@level1_tables += @sql_tab + col.name + ' ' + typ.name + ' ' + '[' + 

	--	---- Now set the different column settings
	--	--CASE 
	--	--		-- First Primary Key
	--	--		WHEN idc.object_id IS NOT NULL
	--	--			THEN	CASE 
	--	--						WHEN idc.object_id IS NOT NULL AND col.is_identity = 1
	--	--							THEN 'pk, increment'
	--	--						WHEN idc.object_id IS NOT NULL AND col.is_identity = 0
	--	--							THEN 'pk'
	--	--							ELSE ''
	--	--					END

	--			-- Now Unique Column Constraint
	--			--WHEN idx.is_unique_constraint = 1 
	--			--	THEN	CASE 
	--			--				WHEN idx.is_unique_constraint = 1 AND col.is_identity = 1
	--			--					THEN 'unique, increment'
	--			--				WHEN idx.is_unique_constraint = 1 AND col.is_identity = 0
	--			--					THEN 'unique'
	--			--					ELSE ''
	--			--			END
			
	--		---- No the Increment that fell through	
	--		--WHEN col.is_identity = 1 
	--		--	THEN 'increment'		

	--		---- Now Get default values 
	--		--WHEN col.default_object_id <> 0 
	--		--	THEN 'default: `' + ISNULL(dcs.[Definition],'') + '`'
	--		--	ELSE ''
	--		--END +
		
	--		---- Add comma in case one of above was true
	--		--CASE 
	--		--	WHEN  (idc.object_id IS NOT NULL OR idx.is_unique_constraint = 1 OR col.is_identity = 1 OR col.default_object_id <> 0 )
	--		--		THEN ', '
	--		--		ELSE ''
	--		--END +

	--		---- nullable and non nullable 
	--		--CASE 
	--		--	WHEN col.is_nullable = 0
	--		--		THEN 'not null'
	--		--		ELSE 'null'
	--		--END + 

	--		---- lastly add optional note
	--		--CASE 
	--		--	WHEN 0 = 1
	--		--		THEN 'note: ''blah blah blah'''
	--		--		ELSE ''
	--		--END + ']' 
	--			--ELSE ''
	--		--END
		+ ']' 
			+ @sql_crlf -- Now close the bracket
	FROM 
		sys.objects AS obj
	INNER JOIN 
		sys.tables AS tab
		ON tab.object_id = obj.object_id
	INNER JOIN 
		sys.schemas AS sch
		ON sch.schema_id = tab.schema_id
	INNER JOIN 
		sys.columns AS col
		ON col.object_id = obj.object_id
	INNER JOIN 
		sys.types AS typ
		ON typ.user_type_id = col.user_type_id
	--WHERE
	--	sch.name = 'BG'

	----LEFT JOIN 
	----	sys.computed_columns AS ccl
	----	ON ccl.object_id = obj.object_id
	--	LEFT JOIN	
	--		sys.default_constraints AS dcs
	--		ON dcs.parent_object_id = obj.object_id
	--		AND dcs.parent_column_id = col.column_id

	-- LEFT join sys.indexes idx
 --       on tab.object_id = idx.object_id 
	--	and  idx.object_id = col.object_id
 --       and idx.is_primary_key = 1

 --   LEFT join sys.index_columns idc
 --       on idc.object_id = idx.object_id
 --       and idc.index_id = idx.index_id
 --       and col.column_id = idc.column_id
	----LEFT JOIN 
	----	sys.key_constraints AS kcs
	----	ON kcs.parent_object_id = obj.object_id
	----		AND kcs.parent_column_id = col.column_id
	WHERE
		sch.name = @schema_name
	AND
		obj.name = @table_name
	AND
		obj.is_ms_shipped = 0
	ORDER BY 
		col.column_id
	

	/* TODO: Create index here */
	SET @level1_tables += '}' + @sql_crlf + @sql_crlf

	IF(@sql_debug = 1)
		RAISERROR(@level1_tables, 0, 1) WITH NOWAIT


	FETCH NEXT FROM @table_cursor
	INTO @schema_name, @table_name

END

-- Finishing up table definitions
SET @level1_tables += @sql_crlf + '
//==============================================//
'



-- REFERENCES DEFINITION
SET @level2_references = '
//----------------------------------------------//
// Level 2 - References
//----------------------------------------------//

'

SELECT
	@level2_references +=	'Ref:' + 
							' "' + pk_tab.name + '"'	+ '.' + '"' + pk_col.name + '" ' + 			
							'<' + 
							' "' + tab.name + '"'	+ '.' + '"' + col.name + '"' + REPLICATE(@sql_crlf,2)

--select *
FROM
	sys.tables tab
inner join 
	sys.schemas AS sch
	on sch.schema_id = tab.schema_id
inner join 
	sys.columns col 
    on col.object_id = tab.object_id
left outer join 
	sys.foreign_key_columns fk_cols
    on fk_cols.parent_object_id = tab.object_id
    and fk_cols.parent_column_id = col.column_id
left outer join 
	sys.foreign_keys fk
    on fk.object_id = fk_cols.constraint_object_id
left outer join 
	sys.tables pk_tab
    on pk_tab.object_id = fk_cols.referenced_object_id
inner join 
	sys.schemas AS pk_sch
	on pk_sch.schema_id = pk_tab.schema_id
left outer join 
	sys.columns pk_col
    on pk_col.column_id = fk_cols.referenced_column_id
    and pk_col.object_id = fk_cols.referenced_object_id
WHERE 
	pk_tab.object_id IS NOT NULL
AND 
	sch.name = @Schema_ToDiagram



-- Finishing up refrences definitions
SET @level2_references += @sql_crlf + '
//==============================================//
'

--SELECT @level3_enum_index

SET @level012_final =  ISNULL(@level00_project, '') + ISNULL(@level0_enums, '') + ISNULL(@level1_tables, '') + ISNULL(@level2_references, '')

SELECT @level012_final



END 
GO

EXEC #Generate_DbDiagram
GO

DROP PROCEDURE IF EXISTS #Generate_DbDiagram
GO
