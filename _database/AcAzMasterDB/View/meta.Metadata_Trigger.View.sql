SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Trigger]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [meta].[Metadata_Trigger]
AS
     SELECT 
		ObjectID			= obj.object_id
	,   SchemaName			= sch.name
	,	ObjectName			= obj.name
    ,   TriggerName			= tri.name
    ,   SqlType				= tri.type
	,	SqlTypeDescription	= tri.type_desc
	,	IsDisabled			= tri.is_disabled
	,	IsInsteadOfTrigger	= tri.is_instead_of_trigger
	,	CreatedDT			= tri.create_date
	,	ModifiedDT			= tri.modify_date
     FROM 
		sys.objects AS obj
	INNER JOIN 
		sys.triggers AS tri
		ON tri.object_id = obj.object_id
	INNER JOIN 
		sys.schemas AS sch
		ON sch.schema_id = obj.object_id
' 
GO
