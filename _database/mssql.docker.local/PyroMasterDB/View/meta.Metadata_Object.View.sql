SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Object]'))
EXEC dbo.sp_executesql @statement = N'

/*
	SELECT * FROM [meta].[Metadata_Object]
*/
CREATE     VIEW [meta].[Metadata_Object]
AS



SELECT
	DatabaseName							= DB_NAME()
,	ObjectId								= obj.object_id
,	ObjectName								= obj.name
,	SchemaId								= obj.schema_id
,	SchemaName								= sch.name
,	ObjectType								= obj.type
,	ObjectTypeDesription					= obj.type_desc
,	CreatedDT								= obj.create_date
,	ModifiedDT								= obj.modify_date
FROM 
	sys.objects AS obj
INNER JOIN
	sys.schemas sch
	ON obj.schema_id = sch.schema_id
WHERE
	obj.is_ms_shipped = 0




' 
GO
