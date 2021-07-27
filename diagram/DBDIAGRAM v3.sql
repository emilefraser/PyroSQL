-- Goal = DBDIAGRAM READY IMPORT
/*

	Written by: Emile Fraser
	Date: 2020-05-27
	Function: Create code to copy paste to dbdiagram.io

*/
/*
		Done:	Table Structure
				Primary Key
				Identities 
				Loop through entire DB and Create
				DataTypes
				Column Names

		To do:
				Indexes (Type, Name, Uniuqe)
				Nullable Fields
				Not nullable fieldds 
				notes? - Straigh from Extended Properties
				Default (date, bit, int)

				Ref type:
					< : One-to-many
					> : Many-to-one
					- : One-to-one

				UNIQUE
				

*/
/*
	#SYNTAX REFERENCE
	
	## PROJECTS
	Project project_name {
	  database_type: 'PostgreSQL'
	  Note: 'Description of the project'
	}

	## TABLES
		Table table_name {
		column_name column_type [column_settings]
	}

	### TABLE ALIAS
	Table very_long_user_table as U {
    ...
	}

	Ref: U.id < posts.user_id

	### TABLE ALIAS
	Table users {
		id integer
		status varchar [note: 'status']

		Note: 'Stores user data'
	}


	#### TABLE SETTINGS
		Settings are all defined within square brackets: [setting1: value1, setting2: value2, setting3, setting4]
		Each setting item can take in 2 forms: Key: Value or keyword, similar to that of Python function parameters.
		headercolor: <color_code>: change the table header color (coming soon)
	
		Example, [headercolor: #3498db]

	## COLUMNS
		Each column can take have optional settings, defined in square brackets like:

		Table buildings {
			...
			address varchar(255) [unique, not null, note: 'to include unit number']
			id integer [ pk, unique, default: 123, note: 'Number' ]
		}
	
	### COLUMN SETTINGS
		note: 'string to add notes': add a metadata note to this column
		primary key or pk: mark a column as primary key. For composite primary key, refer to the 'Indexes' section
		null or not null: mark a column null or not null
		unique: mark the column unique
		default: some_value: set a default value of the column, please refer to the 'Default Value' section below
		increment: mark the column as auto-increment
		#Default Value
	
	#### DEFAULT VALUES
		number value starts blank: default: 123 or default: 123.456
		string value starts with single quotes: default: 'some string value'
		expression value is wrapped with parenthesis: default: `now() - interval '5 days'`
		boolean (true/false/null): default: false or default: null

		Table users {
			id integer [primary key]
			username varchar(255) [not null, unique]
			full_name varchar(255) [not null]
			gender varchar(1) [default: 'm']
			created_at timestamp [default: `now()`]
			rating integer [default: 10]
		}

	## INDEXES 
		Indexes allow users to quickly locate and access the data. Users can define single or multi-column indexes.

		Table bookings {
		  id integer
		  country varchar
		  booking_date date
		  created_at timestamp

		  indexes {
			  (id, country) [pk] // composite primary key
			  created_at [note: 'Date']
			  booking_date
			  (country, booking_date) [unique]
			  booking_date [type: hash]
			  (`id*2`)
			  (`id*3`,`getdate()`)
			  (`id*3`,id)
		  }
		}

	### INDEX TYPES 
		Index with single field (with index name)		: CREATE INDEX on users (created_at)
		Index with multiple fields (composite index)	: CREATE INDEX on users (created_at, country)
		Index with an expression						: CREATE INDEX ON films ( first_name + last_name )
			Composite index with expression				: CREATE INDEX ON users ( country, (lower(name)) )
	
	
	### INDEX SETTINGS
		type: type of index (btree, gin, gist, hash depending on DB). For now, only type btree and hash are accepted.
		name: name of index
		unique: unique index
		pk: primary key

	## RELATIONSHIPS
		Relationships are used to define foreign key constraints between tables.

		Table posts {
			id integer [primary key]
			user_id integer [ref: > users.id] // many-to-one
		}

		Table users {
			id integer [ref: < posts.user_id, ref: < reviews.user_id] // one to many
		}

	### RELATIONSHIP TYPES
		// The space after '<' is optional
		There are 3 types of relationships: one-to-one, one-to-many, and many-to-one

		<: one-to-many. E.g: users.id < posts.user_id
		>: many-to-one. E.g: posts.user_id > users.id
		-: one-to-one. E.g: users.id - user_infos.user_id
		In DBML, there are 3 syntaxes to define relationships:

		//Long form
		Ref name_optional {
		  table1.column1 < table2.column2
		}

		//Short form:
		Ref name_optional: table1.column1 < table2.column2

		// Inline form
		Table posts {
			id integer
			user_id integer [ref: > users.id]
		}

	## RELATIONSHIP SETTINGS
		Ref: products.merchant_id > merchants.id [delete: cascade, update: no action]
		delete / update: cascade | restrict | set null | set default | no action
	
		Define referential actions. Similar to ON DELETE/UPDATE CASCADE/... in SQL.
		Relationship settings are not supported for inline form ref.

	## #Many-to-many relationship
	For many-to-many relationship, we don't have a syntax for it as we believe it should be represented as 2 many-to-one relationships. For more information, please refer to https://www.holistics.io/blog/dbdiagram-io-many-to-many-relationship-diagram-generator-script/

	## COMMENTS
		You can comment in your code using //
		Note's value is a string. If your note spans over multiple lines, you can use multi-line string to define your note.

		Example,
		// order_items refer to items from that order
		
		Table users {
		  id int [pk]
		  name varchar

		  Note: 'This is a note of this table'
		  // or
		  Note {
			'This is a note of this table'
		  }
		}
	

		### PROJECT NOTES
		Project DBML {
		  Note: '''
			# DBML - Database Markup Language
			DBML (database markup language) is a simple, readable DSL language designed to define database structures.
			* It is simple, flexible and highly human-readable
		  '''
		}

		### Table Notes
		Table users {
		  id int [pk]
		  name varchar

		  Note: 'Stores user data'
		}

		#Column Notes
		You can add notes to your columns, so you can easily refer to it when hovering over the column in the diagram canvas.

		column_name column_type [note: 'replace text here']
		Example,

		Table orders {
			status varchar [
			note: '
			💸 1 = processing, 
			✔️ 2 = shipped, 
			']
		} 
	
	### Multi-line String
		Multiline string will be defined between triple single quote '''
		Line breaks: <enter> key
		Line continuation: \ backslash
		\: using double backslash \\
		''': using \'''
		The number of spaces you use to indent a block string will be the minimum number of leading spaces among all lines

		Note: '''
		  This is a block string
		  This string can spans over multiple lines.
		'''
	
	## ENUMS
	Enum allows users to define different values of a particular column. When hovering over the column in the canvas, the enum values will be displayed.

	enum job_status {
		created [note: 'Waiting to be processed']
		running
		done
		failure
	}

	Table jobs {
		id integer
		status job_status
	} 
	#TableGroup
	TableGroup allows users to group the related or associated tables together.

	TableGroup tablegroup_name { // tablegroup is case-insensitive.
		table1 
		table2 
		table3
	}

	//example
	TableGroup e-commerce1 {
		merchants
		countries
	} 
	#Syntax Consistency
	DBML is the standard language for database and the syntax is consistent to provide clear and extensive functions.

	curly brackets {}: grouping for indexes, constraints and table definitions
	square brackets []: settings
	forward slashes //: comments
	column_name is stated in just plain text
	single quote as 'string': string value
	double quote as "column name": quoting variable
	triple quote as '''multi-line string''': multi-line string value
	backtick `: function expression






*/

DECLARE
	@DatabaseType					NVARCHAR(MAX)	= 'SQL Server'
,	@ProjectDescription				NVARCHAR(MAX)	= 'Metrics Vault ERD'

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
Project project_name {
  database_type: ''' + @DatabaseType + '''
  Note: ''' + @ProjectDescription + ''' 
}
'

-- ENUMS DEFINITION
SET @level0_enums = '
// Level 0 - Enums

//----------------------------------------------//
'

-- TABLE DEFINITION
SET @level1_tables = '
// Level 1 - Tables

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
--AND	
--	tab.name = 'Ensamble_Element'

OPEN @table_cursor

FETCH NEXT FROM @table_cursor
INTO @schema_name, @table_name

WHILE(@@FETCH_STATUS = 0)
BEGIN
	
	-- Kicks off the Table Definition
	SET @level1_tables += 'Table ' + @table_name +  ' {' + @sql_crlf
	
	SELECT 
		-- Combine existing string with Column Name, Column Type and Open Square Bracket for the Column Definition
		@level1_tables += @sql_tab + col.name + ' ' + typ.name + ' ' + '[' + 

		-- Now set the different column settings
		CASE 
			-- First Primary Key
			WHEN idc.object_id IS NOT NULL
				THEN CASE 
						WHEN idc.object_id IS NOT NULL AND col.is_identity = 1
							THEN 'pk, increment'
						WHEN idc.object_id IS NOT NULL AND col.is_identity = 0
							THEN 'pk'
							ELSE ''
					END

			-- Now Unique Column Constraint
			WHEN idx.is_unique_constraint = 1 
				THEN CASE 
						WHEN idx.is_unique_constraint = 1 AND col.is_identity = 1
							THEN 'unique, increment'
						WHEN idx.is_unique_constraint = 1 AND col.is_identity = 0
							THEN 'unique'
							ELSE ''
					END
			
			-- No the Increment that fell through	
			WHEN col.is_identity = 1 
				THEN 'increment'		

			-- Now Get default values 
			WHEN col.default_object_id <> 0 
				THEN 'default: `' + ISNULL(dcs.[Definition],'') + '`'
				ELSE ''
			END +
		
			-- Add comma in case one of above was true
			CASE 
				WHEN  (idc.object_id IS NOT NULL OR idx.is_unique_constraint = 1 OR col.is_identity = 1 OR col.default_object_id <> 0 )
					THEN ', '
					ELSE ''
			END +

			-- nullable and non nullable 
			CASE 
				WHEN col.is_nullable = 0
					THEN 'not null'
					ELSE 'null'
			END + 

			-- lastly add optional note
			CASE 
				WHEN 0 = 1
					THEN 'note: ''blah blah blah'''
					ELSE ''
			END + ']' + @sql_crlf -- Now close the bracket

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


	--LEFT JOIN 
	--	sys.computed_columns AS ccl
	--	ON ccl.object_id = obj.object_id
		LEFT JOIN	
			sys.default_constraints AS dcs
			ON dcs.parent_object_id = obj.object_id
			AND dcs.parent_column_id = col.column_id

	

	 LEFT join sys.indexes idx
        on tab.object_id = idx.object_id 
		and  idx.object_id = col.object_id
        and idx.is_primary_key = 1

    LEFT join sys.index_columns idc
        on idc.object_id = idx.object_id
        and idc.index_id = idx.index_id
        and col.column_id = idc.column_id
	--LEFT JOIN 
	--	sys.key_constraints AS kcs
	--	ON kcs.parent_object_id = obj.object_id
	--		AND kcs.parent_column_id = col.column_id
	WHERE
		sch.name = @schema_name
	AND
		tab.name = @table_name
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

//----------------------------------------------//
'



-- REFERENCES DEFINITION
SET @level2_references = '
// Level 2 - References


//----------------------------------------------//
'


--SELECT @level3_enum_index

SET @level012_final =  @level00_project + @level0_enums + @level1_tables + @level2_references 

SELECT @level012_final

