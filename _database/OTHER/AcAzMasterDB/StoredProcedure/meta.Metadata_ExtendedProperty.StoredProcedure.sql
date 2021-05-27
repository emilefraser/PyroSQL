SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[meta].[Metadata_ExtendedProperty]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [meta].[Metadata_ExtendedProperty] AS' 
END
GO
ALTER   PROCEDURE [meta].[Metadata_ExtendedProperty]
AS

SELECT
	ObjectID								= obj.object_id
  , SchemaName								= sch.name
  , ObjectType								= obj.type
  , ObjectTypeDesription					= obj.type_desc
  , ExternalPropertyType					= ep.class
  , ExternalPropertyTypeDescription			= ep.class_desc
  , ExtendedPropertyName					= ep.name
  , ExtendedPropertyValu					= ep.value
  , CreatedDT								= obj.create_date
  , ModifiedDT								= obj.modify_date
FROM
	sys.all_objects AS obj
INNER JOIN
	sys.extended_properties AS ep
	ON EP.major_id = obj.object_id
LEFT JOIN
	sys.schemas AS sch
	ON sch.schema_id = obj.schema_id
GO
