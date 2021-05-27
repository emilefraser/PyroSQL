SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_SchemaObjectCount]'))
EXEC dbo.sp_executesql @statement = N'/*
	SELECT * FROM [meta].[Metadata_SchemaObjectCount]
	ORDER BY ObjectCount ASC
*/
CREATE    VIEW [meta].[Metadata_SchemaObjectCount]
AS

SELECT
	SchemaID			=	sch.schema_id
  ,	SchemaName			=	sch.name
  , ObjectCount			=	COUNT(1) - 1 --(to allow for schema object)
FROM
	sys.schemas AS sch
LEFT JOIN 
	sys.objects AS obj
	ON obj.schema_id = sch.schema_id
WHERE
	sch.schema_id > 4 AND sch.schema_id  < 16384
GROUP BY	
	sch.schema_id, sch.name
' 
GO
