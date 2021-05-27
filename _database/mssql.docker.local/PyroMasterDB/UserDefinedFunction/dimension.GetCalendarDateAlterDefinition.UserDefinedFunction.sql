SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[GetCalendarDateAlterDefinition]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE   FUNCTION [dimension].[GetCalendarDateAlterDefinition] (
		@entity_name		SYSNAME
	,	@schema_name		SYSNAME
	,	@column_name		SYSNAME
	,   @calculated_value	NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS 

BEGIN

DECLARE @sql_template_altertable NVARCHAR(MAX)

--SET @sql_template_altertable = ''SET DATEFIRST 1'' + CHAR(13) + CHAR(10)

SET @sql_template_altertable = ''ALTER TABLE '' + QUOTENAME(''{{SchemaName}}'') + ''.'' + QUOTENAME(''{{EntityName}}'') + CHAR(13) + CHAR(10) +
												 ''ADD '' + QUOTENAME(''{{ColumnName}}'') + '' AS {{CalculatedValue}}''

SET  @sql_template_altertable = REPLACE(@sql_template_altertable, ''{{SchemaName}}'', @schema_name)
SET  @sql_template_altertable = REPLACE(@sql_template_altertable, ''{{EntityName}}'', @entity_name)
SET  @sql_template_altertable = REPLACE(@sql_template_altertable, ''{{ColumnName}}'', @column_name)
SET  @sql_template_altertable = REPLACE(@sql_template_altertable, ''{{CalculatedValue}}'', @calculated_value)

--PRINT(@sql_template_altertable)

RETURN @sql_template_altertable

END' 
END
GO
