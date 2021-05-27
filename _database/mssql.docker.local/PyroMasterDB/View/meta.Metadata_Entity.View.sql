SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Entity]'))
EXEC dbo.sp_executesql @statement = N'
CREATE   VIEW [meta].[Metadata_Entity]
AS
SELECT 
	[ObjectId]
,	[TableName] AS EntityName
,	[SchemaId]
,	[SchemaName]
,	[DatabaseId]
,	[DatabaseName]
,	[ObjectType]
,	[ObjectTypeDesription]
,	[CreatedDT]
,	[ModifiedDT]
FROM 
	[meta].[Metadata_Table]

UNION ALL 

SELECT
	[ObjectId]
,	[ViewName] AS EntityName
,	[SchemaId]
,	[SchemaName]
,	[DatabaseId]
,	[DatabaseName]
,	[ObjectType]
,	[ObjectTypeDescription]
,	[CreatedDT]
,	[ModifiedDT]
FROM 
	[meta].[Metadata_View]
' 
GO
