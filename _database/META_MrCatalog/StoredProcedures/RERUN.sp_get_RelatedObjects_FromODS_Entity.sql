SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE RERUN.sp_get_RelatedObjects_FromODS_Entity
	@DatabaseName SYSNAME
,	@SchemaName SYSNAME
,	@TableName SYSNAME
,	@StoreProceduresOnly BIT = 0
,	@TablesOnly BIT = 0
AS
BEGIN




SELECT
	*
FROM STAGEAREA.sys.sql_expression_dependencies AS sed
LEFT JOIN STAGEAREA.sys.objects AS o
ON o.object_id = sed.referencing_id
WHERE referenced_database_name IS NOT NULL
AND referenced_database_name = @DatabaseName
AND referenced_schema_name = @SchemaName
AND referenced_entity_name = @TableName
AND o.name LIKE '%' + 'SalesInvoice_EMS' + '%'
AND o.name LIKE '%FullLoad%'


--sp_StageFullLoad_KEYS_EMS_dbo_SalesInvoice_EMS_KEYS
--sp_StageFullLoad_MVD_EMS_dbo_SalesInvoice_EMS_MVD
SELECT
	*
FROM STAGEAREA.sys.sql_expression_dependencies AS sed
LEFT JOIN STAGEAREA.sys.objects AS o
ON o.object_id = sed.referencing_id
WHERE referenced_database_name IS NOT NULL
AND referenced_database_name = 'STAGEAREA'
AND referenced_schema_name = 'EMS'
--AND referenced_entity_name = 'sp_StageFullLoad_KEYS_EMS_dbo_SalesInvoice_EMS_KEYS'





/*
SELECT OBJECT_NAME(referencing_id) AS referencing_entity_name,   
    o.type_desc AS referencing_desciption,   
    COALESCE(COL_NAME(referencing_id, referencing_minor_id), '(n/a)') AS referencing_minor_id,   
    referencing_class_desc,  
    referenced_server_name, referenced_database_name, referenced_schema_name,  
    referenced_entity_name,   
    COALESCE(COL_NAME(referenced_id, referenced_minor_id), '(n/a)') AS referenced_column_name,  
    is_caller_dependent, is_ambiguous  
FROM sys.sql_expression_dependencies AS sed  
INNER JOIN sys.objects AS o ON sed.referencing_id = o.object_id  
  
  */
END

GO
