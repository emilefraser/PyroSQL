- SQL Server 2016 is still applicable from SQL Server 2000, SQL Server 2016 is still applicable, and subsequent versions will no longer be supported
USE DB1
SELECT
	o.name
  , o.xtype
  , p.name AS referenced_name
  , p.xtype
FROM
	sysdepends d
INNER JOIN
	sysobjects o
	ON d.id = o.id
INNER JOIN
	sysobjects p
	ON d.depid = p.id

	- SQL Server 2016 is still applicable from SQL Server 2000, SQL Server 2016 is still applicable, and subsequent versions will no longer be supported
 Use <spa326 movie network
 http://www.326dy.com/
n style="margin: 0px; padding: 0px; line-height: 1.8;"> DB1
EXEC sp_depends
	'V1'
 
 - The expansion stored procedure recorded without a document can only check the objects referenced by themselves, SQL Server 2016 still applies

EXEC sp_msdependencies
	'V1'

- SQL Server 2016 is still applicable from SQL Server 2005, SQL Server 2016 is still applicable, and subsequent versions will no longer support
USE DB1
SELECT o.name, o.type_desc, p.name as referenced_name, p.type_desc
FROM sys.sql_dependencies d
INNER JOIN sys.objects o
    ON d.object_id = o.object_id
INNER JOIN sys.objects p
    ON d.referenced_major_id = p.object_id

	- System View from SQL Server 2008
USE DB1
SELECT
	o.name
  , o.type_desc
  , p.name AS referenced_name
  , p.type_desc
FROM
	sys.sql_expression_dependencies d
INNER JOIN
	sys.objects o
	ON Competition
 http://www.326ys.com/
d.referencing_id = o.object_id
INNER JOIN sys.objects p
    ON d.referenced_id = p.object_id

USE DB1
 - Reference My Object from SQL Server 2008

SELECT
	*
FROM
	sys.dm_sql_referencing_entities('dbo.V1', 'OBJECT')
 - System functions started with SQL Server 2008, objects I reference
SELECT
	*
FROM
	sys.dm_sql_referenced_entities('dbo.SP1', 'OBJECT')

USE DB2
 - Reference My Object from SQL Server 2008
SELECT
	*
FROM
	sys.dm_sql_referencing_entities('dbo.SP2', 'OBJECT')
 - System functions started with SQL Server 2008, objects I reference
SELECT
	*
FROM
	sys.dm_sql_referenced_entities('dbo.SP2', 'OBJECT')

note:

(1) sys.sql_expression_dependencies and these two new addresses, you can check the objects across databases across databases across databases, but current database objects are across databases, cross-server references Unable to check;

(2) New 2 system functions, more convenient check references and references, but the object name is complete, you must include Schema Name, otherwise you can't return the correct result;

(3) sys.dm_sql_referenced_entities can also view the object referenced by the database / server DDL trigger;

SELECT * FROM sys.dm_sql_referenced_entities ('ddl_database_trigger_name', 'DATABASE_DDL_TRIGGER');

(4) sys.dm_sql_referencing_entities can also view objects that reference the type / partition function.


1. Cross Database / Server Object

The object starts from SQL Server 2008, cross database, across server references, can be queried;

But the write is slightly adjusted, because there is no Object_ID of other database objects in the current database, so it cannot be associated with Object_ID. After the change, the script is as follows:

USE DB1
SELECT schema_name(o.schema_id) as schema_name, o.name as object_name, o.type_desc, 
       d.referenced_server_name, d.referenced_database_name, isnull(d.referenced_schema_name,'dbo') as referenced_schema_name, d.referenced_entity_name
FROM sys.sql_expression_dependencies d
INNER JOIN sys.objects o
    ON d.referencing_id = o.object_id


	y object

For temporary tables used during stored procedures, you can only check the non # startup table created by Create Table, and use function checks to report error because the table does not exist in advance.


2. Temporary object

For temporary tables used during stored procedures, you can only check the non # startup table created by Create Table, and use function checks to report error because the table does not exist in advance.

USE DB1
- You can only check the non # temporary table created by CREATE TABLE
SELECT schema_name(o.schema_id) as schema_name, o.name as object_name, o.type_desc, 
       d.referenced_server_name, d.referenced_database_name, isnull(d.referenced_schema_name,'dbo') as referenced_schema_name, d.referenced_entity_name
FROM sys.sql_expression_dependencies d
INNER JOIN sys.objects o
    ON d.referencing_id = o.object_id
 
 - And use function checks will also report an error because the table does not exist in advance.
select * from sys.dm_sql_referenced_entities('dbo.SP5','OBJECT');
/*
Msg 2020, Level 16, State 1, Line 4
The dependencies reported for entity "dbo.SP5" might not include references to all columns. This is either because the entity references an object that does not exist or because of an error in one or more statements in the entity.  Before rerunning the query, ensure that there are no errors in the entity and that all objects referenced by the entity exist.
*/

3. Objects referenced in dynamic SQL

USE DB1
 - No matter the system view / function, you can't find it.

SELECT
	SCHEMA_NAME(o.schema_id)				AS schema_name
  , o.name									AS object_name
  , o.type_desc
  , d.referenced_server_name
  , d.referenced_database_name
  , ISNULL(d.referenced_schema_name, 'dbo') AS referenced_schema_name
  , d.referenced_entity_name
FROM
	sys.sql_expression_dependencies d
INNER JOIN
	sys.objects o
	ON d.referencing_id = o.object_id
	- No matter the system view / function, you can't find it.
select * from sys.dm_sql_referenced_entities('dbo.SP6','OBJECT');


Objects referenced in dynamic SQL, no matter whether the system view / function is not checked; maybe you can only try the text definition of the programmable object:

- Information_schema object defined in theansi SQL standard
select * from INFORMATION_SCHEMA.ROUTINES 
where ROUTINE_DEFINITION like '%T2%'
 
 --SQL Server 2000 definitions along the programmable object text
select * from syscomments
where text like '%T2%'
 
 - SQL Server 2005 Programmable Object Text Definition
select * from sys.sql_modules 
where definition like '%T2%'


vNote: This method, for the Hard Coding object name, very easy to use, but (1) sometimes the name of the object in dynamic SQL is not Hard Coding, so it is not necessarily found; for example:

EXEC('
SELECT * FROM dbo.table' + '_name') 
EXEC('SELECT * FROM ' + @table)




(2) Other written uncommon SQL, and cannot be positioned to the object name, such as:
Select * from dbo. Table_name - This syntax can also pass
 Select * from dbo.table_name_2 - The name is only partially similar, Table_name_2 is not Table_Name


4. Delayed name analysis

If the referenced database object is created later, then use 2000 or 2005 to check, the derred name resolution will appear, and after 2008, there is no this problem.
- Deferred Name Resolution: Stored Procedure SP_2nd reference object, unable to get
USE DB2
SELECT o.name, o.xtype, p.name as referenced_name, p.xtype
FROM sysdepends d
INNER JOIN sysobjects o
    ON d.id = o.id
INNER JOIN sysobjects p
    ON d.depid = p.id
 
exec sp_depends 'SP_1st'
exec sp_depends 'SP_2nd'
 
USE DB2
SELECT o.name, o.type_desc, p.name as referenced_name, p.type_desc
FROM sys.sql_dependencies d
INNER JOIN sys.objects o
    ON d.object_id = o.object_id
INNER JOIN sys.objects p
    ON d.referenced_major_id = p.object_id
 
 - Refresh the object definition, you can solve
exec sp_refreshsqlmodule 'SP_2nd'
 - If it is a view, you can also refresh this
exec sp_refreshview 'view_name'
 
 - Use the 2008 system view, no this problem, it saves the name of the reference object, Object_ID can be set first as NULL
USE DB2
SELECT schema_name(o.schema_id) as schema_name, o.name as object_name, o.type_desc, 
       d.referenced_server_name, d.referenced_database_name, isnull(d.referenced_schema_name,'dbo') as referenced_schema_name, d.referenced_entity_name
FROM sys.sql_expression_dependencies d
INNER JOIN sys.objects o
    ON d.referencing_id = o.object_id


5. How to get multiple layers of nesting references

Sometimes a multi-layer nested reference database object, especially view / stored procedures, etc., which acquires all nested modes under certain scenarios. For example: To update the statistics on the table in a stored procedure.


use DB2
GO
declare @entity_name varchar(512)
set @entity_name = 'dbo.sp13'
 
;with tmp
as
(
SELECT *
FROM sys.sql_expression_dependencies d
WHERE d.referencing_id = object_id(@entity_name)
union all
SELECT d.*
FROM sys.sql_expression_dependencies d
INNER JOIN tmp t
   ON t.referenced_id = d.referencing_id
)
--select * from tmp
SELECT schema_name(o.schema_id) as schema_name, o.name as object_name, o.type_desc, 
       d.referenced_server_name, d.referenced_database_name, isnull(d.referenced_schema_name,'dbo') as referenced_schema_name, d.referenced_entity_name
  FROM tmp d
 INNER JOIN sys.objects o
    ON d.referencing_id = o.object_id
 -- LEFT JOIN sys.objects ro
 --   ON d.referenced_id = ro.object_id
 --WHERE ro.type_desc = 'USER_TABLE' or ro.type_desc is null


 summary:

1. View which object references, Sys.sql_expression_dependencies, sys.dm_sql_referencing_entities, sys.sql_modules, no matter which way is cited across database references;

2. View which objects they haveSys.sql_expression_dependencies, sys.dm_sql_referenced_entities can find objects across database references, if they view nested modified objects, or recursively query sys.sql_expression_dependencies compare directly.









