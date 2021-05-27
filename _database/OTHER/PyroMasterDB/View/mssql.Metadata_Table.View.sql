SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[mssql].[Metadata_Table]'))
EXEC dbo.sp_executesql @statement = N'
CREATE      VIEW [mssql].[Metadata_Table]
AS
SELECT
	SchemaName				=	schema_name(aobj.schema_id)
  , TableName				=	aobj.name
  , CreatedDT				=	aobj.create_date
  , ModifiedDT				=   aobj.modify_date
FROM
	sys.all_objects AS aobj
WHERE
	aobj.type = ''T''
' 
GO
