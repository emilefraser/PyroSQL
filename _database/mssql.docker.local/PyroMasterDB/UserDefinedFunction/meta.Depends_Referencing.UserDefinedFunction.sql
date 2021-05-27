SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[meta].[Depends_Referencing]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
	DEPENDS Referencing TVP
*/
CREATE   FUNCTION [meta].[Depends_Referencing] (
	@ReferencingObjectName VARCHAR(200)
,	@ReferencingSchemaName BIT
)
RETURNS TABLE
AS
RETURN
SELECT OBJECT_SCHEMA_NAME ( referencing_id ) AS referencing_schema_name,  
    OBJECT_NAME(referencing_id) AS referencing_entity_name,   
    obj.type_desc AS referencing_desciption,   
    COALESCE(COL_NAME(referencing_id, referencing_minor_id), ''(n/a)'') AS referencing_minor_id,   
    referencing_class_desc, referenced_class_desc,  
    referenced_server_name, referenced_database_name, referenced_schema_name,  
    referenced_entity_name,   
    COALESCE(COL_NAME(referenced_id, referenced_minor_id), ''(n/a)'') AS referenced_column_name,  
    is_caller_dependent, is_ambiguous  
FROM 
	sys.sql_expression_dependencies AS sed  
INNER JOIN 
	sys.objects AS obj ON sed.referencing_id = obj.object_id  
INNER JOIN 
	sys.schemas AS sch
	ON sch.schema_id = obj.schema_id
WHERE 
	referenced_id = OBJECT_ID(@ReferencingObjectName)
AND 
	sch.name = @ReferencingSchemaName
' 
END
GO
