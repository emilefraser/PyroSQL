SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[mssql].[Metadata_DynamicManagementObject]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [mssql].[Metadata_DynamicManagementObject]
AS 
	SELECT 
		SchemaName				= sch.name
	,	ObjectName				= sobj.name
	,	ObjectType				= sobj.type
	,	ObjectTypeDescription	= sobj.type_desc
	FROM 
		sys.system_objects AS sobj
	INNER JOIN 
		sys.schemas AS sch
		ON sch.schema_id = sobj.schema_id
	WHERE
		sobj.name LIKE ''%dm_%''' 
GO
