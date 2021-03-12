/*
SQL SERVER – 2008 – Find Relationship of Foreign Key and Primary Key using T-SQL 
– Find Tables With Foreign Key Constraint in Database

While searching for how to find Primary Key and Foreign Key relationship using T-SQL, 
I came across my own blog article written earlier SQL SERVER – 2005 
– Find Tables With Foreign Key Constraint in Database. 
It is really handy script and not found written on line anywhere. 
This is one really unique script and must be bookmarked. 
There may be situations when there is need to find out on 
relationship between Primary Key and Foreign Key.

I have modified my previous script to add schema name along with table name. 
It would be really great if any of you can improve on this script.

*/

USE AdventureWorks;
GO

SELECT f.name AS ForeignKey,
SCHEMA_NAME(f.SCHEMA_ID) SchemaName,
OBJECT_NAME(f.parent_object_id) AS TableName,
COL_NAME(fc.parent_object_id,fc.parent_column_id) AS ColumnName,
SCHEMA_NAME(o.SCHEMA_ID) ReferenceSchemaName,
OBJECT_NAME (f.referenced_object_id) AS ReferenceTableName,
COL_NAME(fc.referenced_object_id,fc.referenced_column_id) AS ReferenceColumnName
FROM sys.foreign_keys AS f
INNER JOIN sys.foreign_key_columns AS fc ON f.OBJECT_ID = fc.constraint_object_id
INNER JOIN sys.objects AS o ON o.OBJECT_ID = fc.referenced_object_id
GO 


/***************** Service Web *****************/


/*************************************************************************/
-- Find Constraints:

	SELECT OBJECT_NAME(OBJECT_ID) AS NameofConstraint, 
	SCHEMA_NAME(schema_id) AS SchemaName, 
	OBJECT_NAME(parent_object_id) AS TableName, 
	type_desc AS ConstraintType
	FROM sys.objects WHERE type_desc LIKE '%CONSTRAINT'  AND type_desc <> 'DEFAULT_CONSTRAINT' ORDER BY 3
	AND OBJECT_NAME(OBJECT_ID) LIKE 'FK_WorkQueueDistribution_WorkQueue'

/*************************************************************************/


	Select SysObjects.[Name] As [Contraint Name] ,Tab.[Name] as [Table Name],Col.[Name] As [Column Name]
	From SysObjects Inner Join (Select [Name],[ID] From SysObjects Where XType = 'U') As Tab
	On Tab.[ID] = Sysobjects.[Parent_Obj] 
	Inner Join sysconstraints On sysconstraints.Constid = Sysobjects.[ID] 
	Inner Join SysColumns Col On Col.[ColID] = sysconstraints.[ColID] And Col.[ID] = Tab.[ID]
	order by Tab.[Name]


SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS

/*************************************************************************/

select Referencing_Object_name, referencing_column_Name, Referenced_Object_name, Referenced_Column_Name from
(select Referenced_Column_Name = c.name, Referenced_Object_name = o.name, f.constid from sysforeignkeys f, sysobjects o, syscolumns c
where (f.rkeyid = o.id) and c.id = o.id and c.colid = f.rkey) r,
(select referencing_column_Name = c.name, Referencing_Object_name = o.name, f.constid from sysforeignkeys f, sysobjects o, syscolumns c
where (f.fkeyid = o.id) and c.id = o.id and c.colid = f.fkey) f
where r.Referenced_Column_Name = f.referencing_column_Name
and r.constid = f.constid
order by f.Referencing_Object_name

/*************************************************************************/


select
o1.name as Referencing_Object_name
, c1.name as referencing_column_Name
, o2.name as Referenced_Object_name
, c2.name as Referenced_Column_Name
, s.name as Constraint_name
from sysforeignkeys fk
inner join sysobjects o1 on fk.fkeyid = o1.id
inner join sysobjects o2 on fk.rkeyid = o2.id
inner join syscolumns c1 on c1.id = o1.id and c1.colid = fk.fkey
inner join syscolumns c2 on c2.id = o2.id and c2.colid = fk.rkey
inner join sysobjects s on fk.constid = s.id
inner join syscolumns c1 on c1.id = o1.id and c1.colid = fk.fkey
inner join syscolumns c2 on c2.id = o2.id and c2.colid = fk.rkey
inner join sysobjects s on fk.constid = s.id


select
o1.name as Referencing_Object_name
, c1.name as referencing_column_Name
, o2.name as Referenced_Object_name
, c2.name as Referenced_Column_Name
, s.name as Constraint_name
from sysforeignkeys fk
inner join sysobjects o1 on fk.fkeyid = o1.id
inner join sysobjects o2 on fk.rkeyid = o2.id
inner join syscolumns c1 on c1.id = o1.id and c1.colid = fk.fkey
inner join syscolumns c2 on c2.id = o2.id and c2.colid = fk.rkey
inner join sysobjects s on fk.constid = s.id

and o2.name='tblUserDetails' -- this predicate for a specific table


/*************************************************************************/

SELECT RO.NAME AS ParentTable, RC.NAME AS ParentColumn, FO.NAME AS ForeignTable, FC.NAME AS ForeignColumn
FROM sysforeignkeys F INNER JOIN sysobjects RO
ON F.rkeyid = RO.id INNER JOIN syscolumns RC
ON RC.id = RO.id AND RC.colid = F.rkey INNER JOIN sysobjects FO
ON F.fkeyid = FO.id INNER JOIN syscolumns FC
ON FC.id = FO.id AND FC.colid = F.fkey
ORDER BY RO.NAME, RC.NAME, FO.NAME, FC.NAME

/*************************************************************************/

SELECT OBJECT_NAME(PARENT_OBJECT_ID) TABLE_NAME,
COL_NAME (PARENT_OBJECT_ID, PARENT_COLUMN_ID)COLUMN_NAME ,
NAME DEFAULT_CONSTRAINT_NAME
FROM SYS.DEFAULT_CONSTRAINTS ORDER BY 1


/*************************************************************************/

select
Object_Id
,[name] [Default_Constraint_Name]
,schema_name (schema_id) [Schema_Name]
,object_name (parent_object_id)[Table_Name]
--,[Create_Date],[Modify_Date]
from sys.objects where type = 'D'


/*************************************************************************/