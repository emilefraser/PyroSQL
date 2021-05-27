SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[ObjectClass_Entity]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [meta].[ObjectClass_Entity]
AS
	SELECT 
		[DatabaseId]
	  , [DatabaseName]
	  , [ObjectID]
	  , [SchemaID]
	  , [SchemaName]
	  , [DataObjectName] = [ViewName]
	  , [ObjectTypeName]
	  , [IsSystemObject]
	  ,	[ObjectType]
	  ,	[ObjectClass]
	  , [CreatedDT]	
	  , [ModifiedDT]
	FROM 
		[meta].[Object_View]

	UNION ALL

	SELECT 
		[DatabaseId]
	  , [DatabaseName]
	  , [ObjectID]
	  , [SchemaID]
	  , [SchemaName]
	  , [DataObjectName] = [TableName]
	  , [ObjectTypeName]
	  , [IsSystemObject]
	,	[ObjectType]
	,	[ObjectClass]
	  , [CreatedDT]	
	  , [ModifiedDT]
	FROM 
		[meta].[Object_Table]
' 
GO
