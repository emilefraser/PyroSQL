SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[GetDefaultConstraint]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
Written By:		Emile Fraser
Date:			2020-01-13
Description: 
				Gets all the Default Constraints for an/all Object/Schema
*/

/*
	-- DF (Default Constraints) from Schema or Object
	SELECT * FROM tool.GetDefaultConstraint(''tool'', ''LoadConfig'')
*/

CREATE   FUNCTION [tool].[GetDefaultConstraint](
	@SchemaName				SYSNAME = NULL
,	@ObjectName				SYSNAME = NULL
)
RETURNS TABLE
AS 
RETURN
	SELECT 
		DefaultContraintObjectID	= defc.object_id
	,	DefaultContraintName		= defc.name
	,	SchemaName					= SCHEMA_NAME(defc.SCHEMA_ID)
	,	ObjectName					= OBJECT_NAME(defc.parent_object_id)
	,	ColumnName					= COL_NAME(defc.parent_object_id, defc.parent_column_id)
	,	ConstraintType				= defc.type
	,	ConstraintTypeDescription	= defc.type_desc
	,	ConstraintDefinition		= defc.definition
	,	CreatedDate					= obj.create_date
	,	ModifiedDate				= obj.modify_date
	FROM 
		sys.default_constraints AS defc
	INNER JOIN 
		sys.objects AS obj
		ON obj.object_id = defc.object_id
	WHERE
		obj.type = ''D''
	AND
		SCHEMA_NAME(defc.SCHEMA_ID) = COALESCE(@SchemaName, SCHEMA_NAME(defc.SCHEMA_ID))
	AND
		OBJECT_NAME(defc.parent_object_id) = COALESCE(@ObjectName, OBJECT_NAME(defc.parent_object_id))
' 
END
GO
