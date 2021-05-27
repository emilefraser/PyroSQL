SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[mssql].[Metadata_View]'))
EXEC dbo.sp_executesql @statement = N'
CREATE     VIEW [mssql].[Metadata_View]
AS 
	SELECT
	    ObjectID				= aobj.object_id
	  , DatabaseName			= ''USER_DB''
	  , SchemaName				= SCHEMA_NAME(aobj.schema_id) 
	  , ViewName				= aobj.name
	  , ObjectType				= aobj.type
	  , ObjectTypeDescription	= aobj.type_desc
	  , CreatedDT				= aobj.create_date
	  , ModifiedDT				= aobj.modify_date
	FROM
		sys.all_objects AS aobj
	INNER JOIN 
		sys.all_views AS avw
		ON avw.object_id = aobj.object_id
	WHERE
		aobj.is_ms_shipped = 1
	AND
		aobj.type = ''V''

		
' 
GO
