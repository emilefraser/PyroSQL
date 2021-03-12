-- Goal = DBDIAGRAM READY IMPORT
/*

	Written by: Emile Fraser
	Date: 2020-05-27
	Function: Create code to copy paste to dbdiagram.io

*/
/*
//// -- LEVEL 1
//// -- Tables and References

// Creating tables
Table users as U {
  id int [pk, increment] // auto-increment
  full_name varchar
  created_at timestamp
  country_code int
}

Table merchants {
  id int [pk]
  merchant_name varchar
  country_code int
  "created at" varchar
  admin_id int [ref: > U.id] // inline relationship (many-to-one)
}

Table countries {
  code int [pk]
  name varchar
  continent_name varchar
 }

// Creating references
// You can also define relaionship separately
// > many-to-one; < one-to-many; - one-to-one
Ref: U.country_code > countries.code  
Ref: merchants.country_code > countries.code

//----------------------------------------------//

//// -- LEVEL 2
//// -- Adding column settings

Table order_items {
  order_id int [ref: > orders.id]
  product_id int    
  quantity int [default: 1] // default value
}

Ref: order_items.product_id > products.id

Table orders {
  id int [pk] // primary key
  user_id int [not null, unique]
  status varchar
  created_at varchar [note: 'When order created'] // add column note
}

//----------------------------------------------//

//// -- Level 3 
//// -- Enum, Indexes

// Enum for 'products' table below
Enum products_status {
  out_of_stock
  in_stock
  running_low [note: 'less than 20'] // add column note
}

// Indexes: You can define a single or multi-column index 
Table products {
  id int [pk]
  name varchar
  merchant_id int [not null]
  price int
  status products_status
  created_at datetime [default: `now()`]
  
  Indexes {
    (merchant_id, status) [name:'product_status']
    id [unique]
  }
}

Ref: products.merchant_id > merchants.id // many-to-one
*/

/*
	SYNTAX GUIDE:
		
	Table users {
	  id int [pk]
	  username varchar [not null, unique]
	  full_name type [not null]
	  .....
	}
      
	Table Alias
	Table longtablename as t_alias {
	  .....
	}
      
	Reference (Relationship) Syntax
	Long form:
	Ref name-optional {
	  table1.field1 < table2.field2
	}

	Short form:
	Ref name-optional: t1.f1 < t2.f2

	Inline form:
	Table posts {
	  id int  [pk, ref: < comments.post_id]
	  user_id int  [ref: > users.id]
	}

	 Ref type:
	< : One-to-many
	> : Many-to-one
	- : One-to-one

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
	There are 3 types of index definitions:

	Index with single field (with index name): CREATE INDEX on users (created_at)
	Index with multiple fields (composite index): CREATE INDEX on users (created_at, country)
	Index with an expression: CREATE INDEX ON films ( first_name + last_name )
	(bonus) Composite index with expression: CREATE INDEX ON users ( country, (lower(name)) )


	Index Settings
	type: type of index (btree, gin, gist, hash depending on DB). For now, only type btree and hash are accepted.
	name: name of index
	unique: unique index
	pk: primary key


*/
/*
	Examples:
		[ref: > U.id] // inline relationship (many-to-one)

		Ref: U.country_code > countries.code  
		Ref: merchants.country_code > countries.code

		order_id int [ref: > orders.id]

		quantity int [default: 1] // default value
		id int [pk] // primary key
		[note: 'When order created'] // add column note

		user_id int [not null, unique]
		Ref: order_items.product_id > products.id

		created_at datetime [default: `now()`]

		// Enum for 'products' table below
		Enum products_status {
		  out_of_stock
		  in_stock
		  running_low [note: 'less than 20'] // add column note
		}

		// Indexes: You can define a single or multi-column index 
		Table products {
		  id int [pk]
		  name varchar
		  merchant_id int [not null]
		  price int
		  status products_status
		  created_at datetime [default: `now()`]
  
		  Indexes {
			(merchant_id, status) [name:'product_status']
			id [unique]
		  }
		}



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

				Not nullable fieldds 
				notes?
				Default (date, bit, int)

				Ref type:
					< : One-to-many
					> : Many-to-one
					- : One-to-one

*/

DECLARE 
	@sql_statement					NVARCHAR(MAX)
,	@sql_parameter					NVARCHAR(MAX)
,	@sql_message					NVARCHAR(MAX)
,	@sql_crlf						NVARCHAR(2) = CHAR(13) + CHAR(10)
,	@sql_tab						NVARCHAR(1) = CHAR(9)
,	@sql_debug						BIT = 0
,	@sql_execute					BIT = 0

DECLARE 
	@level1_tables			NVARCHAR(MAX)
,	@level2_col_settings	NVARCHAR(MAX)
,	@level3_enum_index		NVARCHAR(MAX)
,	@level123_final			NVARCHAR(MAX)

DECLARE
	@table_cursor			CURSOR
,	@schema_name			NVARCHAR(MAX)
,	@table_name				NVARCHAR(MAX)
,	@column_name			NVARCHAR(MAX)
,	@column_type			NVARCHAR(MAX)
,	@is_primarykey			NVARCHAR(MAX)


SET @level1_tables = '
//// -- LEVEL 1
//// -- Tables and References

// Creating tables

'

SET @table_cursor = CURSOR FOR 
SELECT TOP 4
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


OPEN @table_cursor

FETCH NEXT FROM @table_cursor
INTO @schema_name, @table_name

WHILE(@@FETCH_STATUS = 0)
BEGIN
	
	SET @level1_tables += 'Table ' + @table_name +  ' {' + @sql_crlf
	
	SELECT 
		@level1_tables = @level1_tables + @sql_tab + col.name + ' ' + typ.name + ' ' +

		-- Check for Identity and PRIMARY KEY
		CASE 
			WHEN col.is_identity = 1 OR idx.is_primary_key = 1
				THEN '[' + 
					CASE 
						WHEN idx.is_primary_key = 1
							THEN 'pk'
							ELSE ''
					END + 	
					CASE 
						WHEN col.is_identity = 1 AND idx.is_primary_key = 1
							THEN ', increment]'
						WHEN col.is_identity = 1 AND idx.is_primary_key = 0
							THEN '[increment]'
						WHEN col.is_identity = 0 AND idx.is_primary_key = 1
							THEN ']'
							ELSE ''
					END
				ELSE 
					CASE 
						WHEN col.is_nullable = 0 OR col.default_object_id <> 0
							THEN '[' +  CASE
											WHEN col.is_nullable = 0
												THEN 'non null'
												ELSE ''
											END +
										CASE
											WHEN col.default_object_id <> 0 AND col.is_nullable = 0
												THEN ', default: `now()`]'
											WHEN col.default_object_id <> 0 AND col.is_nullable = 1
												THEN '[default: `now()`]'
											WHEN col.default_object_id = 0 AND col.is_nullable = 0
												THEN ']'
												ELSE ''
										END 
							ELSE ''
					END
		END + @sql_crlf
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
		ON typ.system_type_id = col.system_type_id
	LEFT JOIN 
		sys.index_columns AS ixc
		ON ixc.object_id = obj.object_id
		AND ixc.column_id = col.column_id
	LEFT JOIN 
		sys.indexes AS idx
		ON idx.object_id = ixc.object_id
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

-- Finish up level 1
SET @level1_tables += @sql_crlf +
'
// Creating references
// You can also define relaionship separately
// > many-to-one; < one-to-many; - one-to-one

//----------------------------------------------//
'

--SELECT @level1_tables



SET @level2_col_settings = @sql_crlf +
'
//// -- LEVEL 2
//// -- Adding column settings

// Creating tables

//----------------------------------------------//
'

--SELECT @level2_col_settings


SET @level3_enum_index = @sql_crlf +
'
//// -- Level 3 
//// -- Enum, Indexes

// Enums

// Indexes: You can define a single or multi-column index 

//----------------------------------------------//
'

--SELECT @level3_enum_index

SET @level123_final =  @level1_tables + @level2_col_settings + @level3_enum_index

SELECT @level123_final

