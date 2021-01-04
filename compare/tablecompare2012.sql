/* 

Compares tables quickly and finds non matching data for SQL Server 2012 and beyond only (more info, see: http://gallery.technet.microsoft.com/scriptcenter/T-SQL-Script-to-compare-aaae99a7)

Instructions:

1.  Replace the table names.
2.  Replace the alias name zz1 (TableOne) and zz2 (TableTwo).
3.  Replace column names ZZOneZ (TableOne) and ZZTwoZ (TableTwo).
4.  See the instructions below the code if needing an example.

*/


SELECT zz1.name [ZZOneZColumns], 
	zz2.name [ZZTwoZColumns], 
	zz1.is_nullable [ZZOneZNullable], 
	zz2.is_nullable [ZZTwoZNullable], 
	zz1.system_type_name [ZZOneZDataType], 
	zz2.system_type_name [ZZTwoZDataType], 
	zz1.collation_name [ZZOneZCollation], 
	zz2.collation_name [ZZTwoZCollation], 
	zz1.is_identity_column [ZZOneZIdentity], 
	zz2.is_identity_column [ZZTwoZIdentity], 
	zz1.is_updateable [ZZOneZUpdateable], 
	zz2.is_updateable [ZZTwoZUpdateable], 
	zz1.is_part_of_unique_key [ZZOneZPartUniqueKey], 
	zz2.is_part_of_unique_key [ZZTwoZPartUniqueKey], 
	zz1.is_computed_column [ZZOneZComputed], 
	zz2.is_computed_column [ZZTwoZComputed], 
	zz1.is_xml_document [ZZOneZXML], 
	zz2.is_xml_document [ZZTwoZXML]      
FROM sys.dm_exec_describe_first_result_set ('SELECT * FROM TableOne', NULL, 0) zz1 
	FULL OUTER JOIN sys.dm_exec_describe_first_result_set ('SELECT * FROM TableTwo', NULL, 0) zz2 ON zz1.name = zz2.name
WHERE zz1.name <> zz2.name
	OR zz1.is_nullable <> zz2.is_nullable
	OR zz1.system_type_name <> zz2.system_type_name
	OR zz1.collation_name <> zz2.collation_name
	OR zz1.is_identity_column <> zz2.is_identity_column
	OR zz1.is_updateable <> zz2.is_updateable
	OR zz1.is_part_of_unique_key <> zz2.is_part_of_unique_key
	OR zz1.is_computed_column <> zz2.is_computed_column
	OR zz1.is_xml_document <> zz2.is_xml_document
	
	
/*

Example:

*/


CREATE TABLE TableOne(
	ID INT IDENTITY(1,1),
	Name VARCHAR(250),
	EmailData XML,
	EmailDate DATE,
	Encrypted VARCHAR(3) NOT NULL,
	Premium VARCHAR(25)
)


CREATE TABLE TableTwo(
	ID INT IDENTITY(1,1),
	Name VARCHAR(100),
	EmailData XML,
	EmailDate DATETIME,
	Encrypted VARCHAR(3) NULL,
	Premium VARCHAR(25)
)


SELECT zz1.name [ZZOneZColumns], 
	zz2.name [ZZTwoZColumns], 
	zz1.is_nullable [ZZOneZNullable], 
	zz2.is_nullable [ZZTwoZNullable], 
	zz1.system_type_name [ZZOneZDataType], 
	zz2.system_type_name [ZZTwoZDataType], 
	zz1.collation_name [ZZOneZCollation], 
	zz2.collation_name [ZZTwoZCollation], 
	zz1.is_identity_column [ZZOneZIdentity], 
	zz2.is_identity_column [ZZTwoZIdentity], 
	zz1.is_updateable [ZZOneZUpdateable], 
	zz2.is_updateable [ZZTwoZUpdateable], 
	zz1.is_part_of_unique_key [ZZOneZPartUniqueKey], 
	zz2.is_part_of_unique_key [ZZTwoZPartUniqueKey], 
	zz1.is_computed_column [ZZOneZComputed], 
	zz2.is_computed_column [ZZTwoZComputed], 
	zz1.is_xml_document [ZZOneZXML], 
	zz2.is_xml_document [ZZTwoZXML]      
FROM sys.dm_exec_describe_first_result_set ('SELECT * FROM TableOne', NULL, 0) zz1 
	FULL OUTER JOIN sys.dm_exec_describe_first_result_set ('SELECT * FROM TableTwo', NULL, 0) zz2 ON zz1.name = zz2.name
WHERE zz1.name <> zz2.name
	OR zz1.is_nullable <> zz2.is_nullable
	OR zz1.system_type_name <> zz2.system_type_name
	OR zz1.collation_name <> zz2.collation_name
	OR zz1.is_identity_column <> zz2.is_identity_column
	OR zz1.is_updateable <> zz2.is_updateable
	OR zz1.is_part_of_unique_key <> zz2.is_part_of_unique_key
	OR zz1.is_computed_column <> zz2.is_computed_column
	OR zz1.is_xml_document <> zz2.is_xml_document


/*

DROP TABLE TableOne
DROP TABLE TableTwo

*/

