SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Generate_DbDiagram]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[Generate_DbDiagram] AS' 
END
GO



-- Main Generation Procedure
-- EXEC [dbo].[Generate_DbDiagram]
ALTER   PROCEDURE [dbo].[Generate_DbDiagram]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET STATISTICS IO OFF

DECLARE
	@DatabaseType					NVARCHAR(MAX)	= 'SQL Server'
,	@ProjectDescription				NVARCHAR(MAX)	= 'MetadataDB'
,	@Database_ToDiagram				SYSNAME			= 'AcAzMetaDataDB'
,	@Schema_ToDiagram				SYSNAME			= 'adf'
,	@ERD_Type						SMALLINT		= 1 -- 1 = ONLY KEYS, 2 = FULL
,	@Object_Type					SYSNAME			= 'U' -- U, V

DECLARE 
	@sql_statement					NVARCHAR(MAX)
,	@sql_parameter					NVARCHAR(MAX)
,	@sql_message					NVARCHAR(MAX)
,	@sql_crlf						NVARCHAR(2) = CHAR(13) + CHAR(10)
,	@sql_tab						NVARCHAR(1) = CHAR(9)
,	@sql_debug						BIT = 1
,	@sql_execute					BIT = 1

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

DECLARE 
	@ObjectName				NVARCHAR(MAX)
,	@ObjectType				NVARCHAR(MAX)

DECLARE @metadata TABLE (
	Id					INT IDENTITY(1,1)	NOT NULL PRIMARY KEY
,	ObjectType			SYSNAME				NOT NULL
,	ObjectName			SYSNAME				NOT NULL
,	ObjectValue			NVARCHAR(256)		NULL
,	ObjectParent		SYSNAME				NULL
,	ObjectReference		NVARCHAR(256)		NULL
,	SpecialProperty		NVARCHAR(256)		NULL
,	IsInclude			BIT					DEFAULT 1
)

RAISERROR('************ DATABASE *************', 0, 1) WITH NOWAIT

-- Database 
INSERT INTO @metadata(ObjectType, ObjectName)
SELECT 'DATABASE', QUOTENAME(db.name)
FROM sys.databases AS db
WHERE db.name = @Database_ToDiagram

IF NOT EXISTS (
	SELECT * FROM @metadata WHERE ObjectType = 'DATABASE'
)
BEGIN
	SET @ObjectName = @Database_ToDiagram
	SET @objectType = 'DATABASE'
	GOTO ISSUE
END
ELSE
BEGIN	
	SET @sql_message = @Database_ToDiagram + ' has been added' + @sql_crlf
	RAISERROR(@sql_message, 0, 1) WITH NOWAIT
END


-- SCHEMA
RAISERROR('************ SCHEMA *************', 0, 1) WITH NOWAIT
SET @sql_statement = '
	SELECT ''SCHEMA'', QUOTENAME(sc.name), ''' + QUOTENAME(@Database_ToDiagram) + '''
	FROM ' + QUOTENAME(@Database_ToDiagram) + '.[sys].[schemas] AS sc
	WHERE sc.name = ''' + @Schema_ToDiagram + ''''

IF(@sql_debug = 1)
BEGIN
	RAISERROR(@sql_statement,0,1) WITH NOWAIT
END
IF(@sql_execute = 1)
BEGIN
	INSERT INTO @metadata(ObjectType, ObjectName, ObjectParent)
	EXEC sp_executesql @stmt = @sql_statement
END


IF NOT EXISTS (
	SELECT * FROM @metadata WHERE ObjectType = 'SCHEMA'
)
BEGIN
	SET @ObjectName = @Schema_ToDiagram
	SET @objectType = 'SCHEMA'
	GOTO ISSUE
END
ELSE
BEGIN	
	SET @sql_message = @Schema_ToDiagram + ' has been added' + @sql_crlf
	RAISERROR(@sql_message, 0, 1) WITH NOWAIT
END


-- OBJECTS
RAISERROR('************ OBJECTS *************', 0, 1) WITH NOWAIT
SET @sql_statement = '
SELECT
	obj.Type_Desc
,  ''' + QUOTENAME(@Database_ToDiagram) + '.' + QUOTENAME(@Schema_ToDiagram) + '.'' + QUOTENAME(obj.name)
, ''' + QUOTENAME(@Database_ToDiagram) + '.' + QUOTENAME(@Schema_ToDiagram) + '''
FROM 
	sys.objects AS obj
INNER JOIN 
	sys.schemas AS sch
	ON sch.schema_id = obj.schema_id
WHERE
	obj.is_ms_shipped = 0
AND	
	sch.name = ''DC''
	AND
	obj.[Type] = ''' + @Object_Type + ''''

IF(@sql_debug = 1)
BEGIN
	RAISERROR(@sql_statement,0,1) WITH NOWAIT
END
IF(@sql_execute = 1)
BEGIN
	INSERT INTO @metadata(ObjectType, ObjectName, ObjectParent)
	EXEC sp_executesql @stmt = @sql_statement
END



-- COLUMNS
RAISERROR('************ COLUMN *************', 0, 1) WITH NOWAIT
SET @sql_statement = '
SELECT 
		ObjectType		= ''COLUMN'' 
    ,	ObjectName		= ''' + QUOTENAME(@Database_ToDiagram) + ''' + ' + '''.''' + '+ QUOTENAME(sch.name)' + ' + ' + '''.''' + '+ QUOTENAME(tab.name)' + ' + ' + '''.''' + '+ QUOTENAME(col.name)
	,	ObjectValue		= t.name + '' ['' + IIF(col.is_nullable = 1, ''null'', ''not null'') + '']''
	,	ObjectParent	= ''' + QUOTENAME(@Database_ToDiagram) + ''' + ' + '''.''' + '+ QUOTENAME(sch.name)' + ' + ' + '''.''' + '+ QUOTENAME(tab.name)
FROM ' + QUOTENAME(@Database_ToDiagram) + '.sys.tables as tab
INNER JOIN ' + QUOTENAME(@Database_ToDiagram) + '.sys.schemas AS sch
ON sch.Schema_ID = tab.Schema_ID
INNER JOIN ' + QUOTENAME(@Database_ToDiagram) + '.sys.columns as col
ON tab.object_id = col.object_id
    left join ' + QUOTENAME(@Database_ToDiagram) + '.sys.types as t
    on col.user_type_id = t.user_type_id
where sch.name = ''' + @Schema_ToDiagram + '''
order by tab.name, column_id'

IF(@sql_debug = 1)
BEGIN
	RAISERROR(@sql_statement,0,1) WITH NOWAIT
END
IF(@sql_execute = 1)
BEGIN
	INSERT INTO @metadata(ObjectType, ObjectName, ObjectValue, ObjectParent)
	EXEC sp_executesql @stmt = @sql_statement
END


select table_view,
    object_type, 
    constraint_type,
    constraint_name,
    details
from (
    select schema_name(t.schema_id) + '.' + t.[name] as table_view, 
        case when t.[type] = 'U' then 'Table'
            when t.[type] = 'V' then 'View'
            end as [object_type],
        case when c.[type] = 'PK' then 'Primary key'
            when c.[type] = 'UQ' then 'Unique constraint'
            when i.[type] = 1 then 'Unique clustered index'
            when i.type = 2 then 'Unique index'
            end as constraint_type, 
        isnull(c.[name], i.[name]) as constraint_name,
        substring(column_names, 1, len(column_names)-1) as [details]
    from sys.objects t
        left outer join sys.indexes i
            on t.object_id = i.object_id
        left outer join sys.key_constraints c
            on i.object_id = c.parent_object_id 
            and i.index_id = c.unique_index_id
       cross apply (select col.[name] + ', '
                        from sys.index_columns ic
                            inner join sys.columns col
                                on ic.object_id = col.object_id
                                and ic.column_id = col.column_id
                        where ic.object_id = t.object_id
                            and ic.index_id = i.index_id
                                order by col.column_id
                                for xml path ('') ) D (column_names)
    where is_unique = 1
    and t.is_ms_shipped <> 1
    union all 
    select schema_name(fk_tab.schema_id) + '.' + fk_tab.name as foreign_table,
        'Table',
        'Foreign key',
        fk.name as fk_constraint_name,
        schema_name(pk_tab.schema_id) + '.' + pk_tab.name
    from sys.foreign_keys fk
        inner join sys.tables fk_tab
            on fk_tab.object_id = fk.parent_object_id
        inner join sys.tables pk_tab
            on pk_tab.object_id = fk.referenced_object_id
        inner join sys.foreign_key_columns fk_cols
            on fk_cols.constraint_object_id = fk.object_id
    union all
    select schema_name(t.schema_id) + '.' + t.[name],
        'Table',
        'Check constraint',
        con.[name] as constraint_name,
        con.[definition]
    from sys.check_constraints con
        left outer join sys.objects t
            on con.parent_object_id = t.object_id
        left outer join sys.all_columns col
            on con.parent_column_id = col.column_id
            and con.parent_object_id = col.object_id
    union all
    select schema_name(t.schema_id) + '.' + t.[name],
        'Table',
        'Default constraint',
        con.[name],
        col.[name] + ' = ' + con.[definition]
    from sys.default_constraints con
        left outer join sys.objects t
            on con.parent_object_id = t.object_id
        left outer join sys.all_columns col
            on con.parent_column_id = col.column_id
            and con.parent_object_id = col.object_id) a
order by table_view, constraint_type, constraint_name



SELECT * FROM @metadata

	
--	DatabseName	SYSNAME
--,	SchemaName	SYSNAME
--,	ObjectName	SYSNAME




--SET @table_cursor = CURSOR FOR 
--SELECT
--	sch.name, tab.name
--FROM 
--	sys.objects AS obj
--INNER JOIN 
--	sys.tables AS tab
--	ON tab.object_id = obj.object_id
--INNER JOIN 
--	sys.schemas AS sch
--	ON sch.schema_id = tab.schema_id
--WHERE
--	obj.is_ms_shipped = 0
--AND	
--	sch.name = @Schema_ToDiagram

--select 
--    col.column_id as id,
--    col.name,
--    t.name as data_type,
--    col.max_length,
--    col.precision,
--    col.is_nullable
--from sys.tables as tab
--    inner join sys.columns as col
--        on tab.object_id = col.object_id
--    left join sys.types as t
--    on col.user_type_id = t.user_type_id
--where tab.name = 'Table name' -- enter table name here
---- and schema_name(tab.schema_id) = 'Schema name'
--order by tab.name, column_id;


--OPEN @table_cursor

--FETCH NEXT FROM @table_cursor
--INTO @schema_name, @table_name

--WHILE(@@FETCH_STATUS = 0)
--BEGIN
		
--	--SELECT @schema_name, @table_name

--	-- Kicks off the Table Definition
--	SET @level1_tables += 'Table ' + @table_name +  ' {' + @sql_crlf
	
--	SELECT 
--		-- Combine existing string with Column Name, Column Type and Open Square Bracket for the Column Definition
--		@level1_tables += @sql_tab + col.name + ' ' + typ.name + ' ' + '[' + 

--	--	---- Now set the different column settings
--	--	--CASE 
--	--	--		-- First Primary Key
--	--	--		WHEN idc.object_id IS NOT NULL
--	--	--			THEN	CASE 
--	--	--						WHEN idc.object_id IS NOT NULL AND col.is_identity = 1
--	--	--							THEN 'pk, increment'
--	--	--						WHEN idc.object_id IS NOT NULL AND col.is_identity = 0
--	--	--							THEN 'pk'
--	--	--							ELSE ''
--	--	--					END

--	--			-- Now Unique Column Constraint
--	--			--WHEN idx.is_unique_constraint = 1 
--	--			--	THEN	CASE 
--	--			--				WHEN idx.is_unique_constraint = 1 AND col.is_identity = 1
--	--			--					THEN 'unique, increment'
--	--			--				WHEN idx.is_unique_constraint = 1 AND col.is_identity = 0
--	--			--					THEN 'unique'
--	--			--					ELSE ''
--	--			--			END
			
--	--		---- No the Increment that fell through	
--	--		--WHEN col.is_identity = 1 
--	--		--	THEN 'increment'		

--	--		---- Now Get default values 
--	--		--WHEN col.default_object_id <> 0 
--	--		--	THEN 'default: `' + ISNULL(dcs.[Definition],'') + '`'
--	--		--	ELSE ''
--	--		--END +
		
--	--		---- Add comma in case one of above was true
--	--		--CASE 
--	--		--	WHEN  (idc.object_id IS NOT NULL OR idx.is_unique_constraint = 1 OR col.is_identity = 1 OR col.default_object_id <> 0 )
--	--		--		THEN ', '
--	--		--		ELSE ''
--	--		--END +

--	--		---- nullable and non nullable 
--	--		--CASE 
--	--		--	WHEN col.is_nullable = 0
--	--		--		THEN 'not null'
--	--		--		ELSE 'null'
--	--		--END + 

--	--		---- lastly add optional note
--	--		--CASE 
--	--		--	WHEN 0 = 1
--	--		--		THEN 'note: ''blah blah blah'''
--	--		--		ELSE ''
--	--		--END + ']' 
--	--			--ELSE ''
--	--		--END
--		+ ']' 
--			+ @sql_crlf -- Now close the bracket
--	FROM 
--		sys.objects AS obj
--	INNER JOIN 
--		sys.tables AS tab
--		ON tab.object_id = obj.object_id
--	INNER JOIN 
--		sys.schemas AS sch
--		ON sch.schema_id = tab.schema_id
--	INNER JOIN 
--		sys.columns AS col
--		ON col.object_id = obj.object_id
--	INNER JOIN 
--		sys.types AS typ
--		ON typ.user_type_id = col.user_type_id
--	--WHERE
--	--	sch.name = 'BG'

--	----LEFT JOIN 
--	----	sys.computed_columns AS ccl
--	----	ON ccl.object_id = obj.object_id
--	--	LEFT JOIN	
--	--		sys.default_constraints AS dcs
--	--		ON dcs.parent_object_id = obj.object_id
--	--		AND dcs.parent_column_id = col.column_id

--	-- LEFT join sys.indexes idx
-- --       on tab.object_id = idx.object_id 
--	--	and  idx.object_id = col.object_id
-- --       and idx.is_primary_key = 1

-- --   LEFT join sys.index_columns idc
-- --       on idc.object_id = idx.object_id
-- --       and idc.index_id = idx.index_id
-- --       and col.column_id = idc.column_id
--	----LEFT JOIN 
--	----	sys.key_constraints AS kcs
--	----	ON kcs.parent_object_id = obj.object_id
--	----		AND kcs.parent_column_id = col.column_id
--	WHERE
--		sch.name = @schema_name
--	AND
--		obj.name = @table_name
--	AND
--		obj.is_ms_shipped = 0
--	ORDER BY 
--		col.column_id
	

--	/* TODO: Create index here */
--	SET @level1_tables += '}' + @sql_crlf + @sql_crlf

--	IF(@sql_debug = 1)
--		RAISERROR(@level1_tables, 0, 1) WITH NOWAIT


--	FETCH NEXT FROM @table_cursor
--	INTO @schema_name, @table_name

--END

---- Finishing up table definitions
--SET @level1_tables += @sql_crlf + '
--//==============================================//
--'



---- REFERENCES DEFINITION
--SET @level2_references = '
--//----------------------------------------------//
--// Level 2 - References
--//----------------------------------------------//

--'

--SELECT
--	@level2_references +=	'Ref:' + 
--							' "' + pk_tab.name + '"'	+ '.' + '"' + pk_col.name + '" ' + 			
--							'<' + 
--							' "' + tab.name + '"'	+ '.' + '"' + col.name + '"' + REPLICATE(@sql_crlf,2)

----select *
--FROM
--	sys.tables tab
--inner join 
--	sys.schemas AS sch
--	on sch.schema_id = tab.schema_id
--inner join 
--	sys.columns col 
--    on col.object_id = tab.object_id
--left outer join 
--	sys.foreign_key_columns fk_cols
--    on fk_cols.parent_object_id = tab.object_id
--    and fk_cols.parent_column_id = col.column_id
--left outer join 
--	sys.foreign_keys fk
--    on fk.object_id = fk_cols.constraint_object_id
--left outer join 
--	sys.tables pk_tab
--    on pk_tab.object_id = fk_cols.referenced_object_id
--inner join 
--	sys.schemas AS pk_sch
--	on pk_sch.schema_id = pk_tab.schema_id
--left outer join 
--	sys.columns pk_col
--    on pk_col.column_id = fk_cols.referenced_column_id
--    and pk_col.object_id = fk_cols.referenced_object_id
--WHERE 
--	pk_tab.object_id IS NOT NULL
--AND 
--	sch.name = @Schema_ToDiagram



---- Finishing up refrences definitions
--SET @level2_references += @sql_crlf + '
--//==============================================//
--'

----SELECT @level3_enum_index

--SET @level012_final =  ISNULL(@level00_project, '') + ISNULL(@level0_enums, '') + ISNULL(@level1_tables, '') + ISNULL(@level2_references, '')

--SELECT @level012_final

--DataVault@123
--END 
--GO

--EXEC #Generate_DbDiagram
--GO

--DROP PROCEDURE IF EXISTS #Generate_DbDiagram
--GO




---- PROJECT DEFINITION
--SET @Level00_project = '
--//----------------------------------------------//
--// Level 00 - Project
--//----------------------------------------------//
--Project project_name {
--  database_type: ''' + @DatabaseType + '''
--  Note: ''' + @ProjectDescription + '''
--}
--'

---- Finishing up project definitions
--SET @Level00_project += @sql_crlf + '
--//==============================================//
--'
---- ENUMS DEFINITION
--SET @level0_enums = '
--//----------------------------------------------//
--// Level 0 - Enums
--//----------------------------------------------//
--'

---- Finishing up enums definitions
--SET @level0_enums += @sql_crlf + '
--//==============================================//
--'
---- TABLE DEFINITION
--SET @level1_tables = '
--//----------------------------------------------//
--// Level 1 - Tables
--//----------------------------------------------//
--'


ISSUE: 
	SET @sql_message = '### ERROR ###' + @sql_crlf
	SET @sql_message += 'No ' + @ObjectName + '(' +  @ObjectType + ') found!'
	RAISERROR(@sql_message, 0, 1) WITH NOWAIT

END
GO
