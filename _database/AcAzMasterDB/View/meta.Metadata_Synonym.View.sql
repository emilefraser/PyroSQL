SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Synonym]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [meta].[Metadata_Synonym]
AS
     SELECT 
		ObjectID			= obj.object_id
	,   SchemaName			= sch.name
	,	ObjectName			= obj.name
    ,   SynonymName			= syn.name
    ,   SqlType				= syn.type
	,	SqlTypeDescription	= syn.type_desc
	,	BaseObjectName		= syn.base_object_name
     FROM 
		sys.objects AS obj
	INNER JOIN 
		sys.synonyms AS syn
		ON syn.object_id = obj.object_id
	INNER JOIN 
		sys.schemas AS sch
		ON sch.schema_id = obj.object_id
' 
GO
