SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_View]'))
EXEC dbo.sp_executesql @statement = N'
CREATE   VIEW [meta].[Metadata_View]
AS 
	SELECT
		ObjectId								= obj.object_id
	,	ViewName								= vw.name
	,	SchemaId								= obj.schema_id
	,	SchemaName								= sch.name
	,	DatabaseId								= DB_ID()
	,	DatabaseName							= DB_NAME()
	,	ObjectType								= obj.type
	,	ObjectTypeDescription					= obj.type_desc
	,	CreatedDT								= vw.create_date
	,	ModifiedDT								= vw.modify_date
	FROM
		sys.objects AS obj
	INNER JOIN
		sys.views AS vw
		ON vw.object_id = obj.object_id
	INNER JOIN
		sys.schemas sch
		ON obj.schema_id = sch.schema_id' 
GO
