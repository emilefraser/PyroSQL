SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Constraint_ForeignKey]'))
EXEC dbo.sp_executesql @statement = N'/*
Written By:		Emile Fraser
Date:			2020-01-13
Description: 
				While searching for how to find Primary Key and Foreign Key relationship using T-SQL
				– Find Tables With Foreign Key Constraint in Database. 
				It is really handy script and not found written on line anywhere. 
				This is one really unique script and must be bookmarked. 
				There may be situations when there is need to find out on 
				relationship between Primary Key and Foreign Key.
*/

/*
	-- FK FROM MARC
	SELECT * FROM dm.GetForeignKey(''vs_lnd'', ''MARC_plant_data_for_material'' ,NULL, NULL)

	-- FK TO MARC
	SELECT * FROM dm.GetForeignKey(NULL, NULL, ''vs_lnd'', ''MARC_plant_data_for_material'')

*/

CREATE    VIEW [meta].[Metadata_Constraint_ForeignKey]
AS
	SELECT 
		ForeignKeyObjectID		= fkey.object_id
	,	ForeignKeyName			= fkey.name
	,	SchemaName				= SCHEMA_NAME(fkey.SCHEMA_ID)
	,	ObjectName				= OBJECT_NAME(fkey.parent_object_id)
	,	ColumnName				= COL_NAME(fcol.parent_object_id, fcol.parent_column_id)
	,	ReferencedSchemaName	= SCHEMA_NAME(obj.SCHEMA_ID)
	,	ReferencedObjectName	= OBJECT_NAME (fkey.referenced_object_id)
	,	ReferencedColumnName	= COL_NAME(fcol.referenced_object_id, fcol.referenced_column_id) 
	FROM 
		sys.foreign_keys AS fkey
	INNER JOIN 
		sys.foreign_key_columns AS fcol
		ON fkey.OBJECT_ID = fcol.constraint_object_id
	INNER JOIN 
		sys.objects AS obj 
		ON obj.OBJECT_ID = fcol.referenced_object_id
	
' 
GO
