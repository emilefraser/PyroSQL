SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Object_View]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [meta].[Object_View]
AS
	SELECT 
		[DatabaseId]				= DB_ID()
	  , [DatabaseName]				= DB_NAME()
	  , [ObjectID]					= [obj].[object_id]
	  , [SchemaID]					= [sch].[schema_id]
	  , [SchemaName]				= [sch].[name]
	  , [ViewName]					= [vw].[name]
	  , [ObjectTypeName]			= [obj].[type_desc]
	  , [IsSystemObject]			= [obj].[is_ms_shipped]
	,	[ObjectType]				= ''V''
	,	[ObjectClass]				= ''DAT''
	  , [CreatedDT]					= [vw].[create_date]
	  , [ModifiedDT]				= [vw].[modify_date]
	FROM 
		[sys].[objects] AS [obj]
	INNER JOIN
		[sys].[views] AS [vw]
		ON [vw].object_id = [obj].object_id
	INNER JOIN 
		[sys].[schemas] AS [sch]
		ON [sch].[schema_id] = [obj].[schema_id]
	WHERE
		[obj].[type] = ''V''
' 
GO
