SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[adf].[vw_LoadDependency]'))
EXEC dbo.sp_executesql @statement = N'CREATE   VIEW [adf].[vw_LoadDependency]
AS
SELECT  
	DB_NAME() AS referencing_database_nem
,	obj_1.name AS referencing_entity_name
,	sch_1.name AS referencing_schema_name
,	ref.referencing_id
,	ref.referencing_class_desc
,	obj_1.type AS referencing_type
,	obj_1.type_desc AS referencing_type_desc
,	obj_1.schema_id AS  referencing_schema_id
,	ref.referenced_entity_name
,	ref.referenced_schema_name
,	ref.referenced_id
,	ref.referenced_class_desc
,	obj_2.type  AS referenced_type
,	obj_2.type_desc AS referenced_type_desc
,	obj_2.schema_id AS  referenced_schema_id 
FROM sys.sql_expression_dependencies AS ref
INNER JOIN sys.objects AS obj_1
ON obj_1.object_id = ref.referencing_id
INNER JOIN sys.schemas AS sch_1
ON sch_1.schema_id = obj_1.schema_id
INNER JOIN sys.objects AS obj_2
ON obj_2.object_id = ref.referenced_id
INNER JOIN sys.schemas AS sch_2
ON sch_2.schema_id = obj_2.schema_id
' 
GO
