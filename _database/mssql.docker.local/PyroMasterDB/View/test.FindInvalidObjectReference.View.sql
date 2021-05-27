SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[test].[FindInvalidObjectReference]'))
EXEC dbo.sp_executesql @statement = N'/*
	SELECT * FROM test.FindInvalidObjectReference
*/
CREATE   VIEW [test].[FindInvalidObjectReference]
AS
SELECT
	  DatabaseName				= DB_NAME()
	, SchemaName				= SCHEMA_NAME(obj.[schema_id])
	, ObjectName				= obj.name
	, ObjectType				= obj.type 
	, ObjectTypeName			= obj.type_desc
	, DatabaseNameReferenced	= COALESCE(sed.referenced_database_name, DB_NAME())
	, SchemaNameRefereneced		= COALESCE(sed.referenced_schema_name, ''dbo'')
	, ObjectNameReferenced		= sed.referenced_entity_name
FROM 
	sys.sql_expression_dependencies AS sed
INNER JOIN
	sys.objects AS obj ON sed.referencing_id = obj.object_id
WHERE 
	sed.is_ambiguous = 0
	AND sed.referenced_id IS NULL
	AND sed.referenced_server_name IS NULL -- Ignored Linked Server Objects
	AND CASE sed.referenced_class -- IF DOES NOT EXISTS
		WHEN 1 -- OBJECT
			THEN OBJECT_ID(
				ISNULL(QUOTENAME(sed.referenced_database_name), DB_NAME()) 
				+ ''.'' 
				+ ISNULL(QUOTENAME(sed.referenced_schema_name), SCHEMA_NAME()) 
				+ ''.'' 
				+ QUOTENAME(sed.referenced_entity_name))
		WHEN 6 -- USER DataType
			THEN TYPE_ID(
				ISNULL(sed.referenced_schema_name, SCHEMA_NAME()) + ''.'' + sed.referenced_entity_name) 
		WHEN 10 -- XML Schema
			THEN (
				SELECT 1 FROM sys.xml_schema_collections AS sxml 
				WHERE sxml.name = sed.referenced_entity_name
					AND sxml.[schema_id] = ISNULL(SCHEMA_ID(sed.referenced_schema_name), SCHEMA_ID())
			)
		END IS NULL' 
GO
