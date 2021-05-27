SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[ValidatePrimaryKeyIsUnique]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [test].[ValidatePrimaryKeyIsUnique] AS' 
END
GO

/*
	CREATED BY: Emile Fraser
	DATE: 2020-10-01
	DECSRIPTION: Validate Business Key Uniqueness
	TODO: Ensure naming aligns to sap names

 EXEC [vs_lnd].[ValidateBusinessKeyIsUnique]
	@SchemaName_Modelling				= 'vs_lnd'
,	@SchemaName_Data					= 'lnd'
,	@ExcludeWildCard					= '_new'
*/
ALTER      PROCEDURE [test].[ValidatePrimaryKeyIsUnique]
	@SchemaName_Modelling	SYSNAME
,	@SchemaName_Data		SYSNAME
,	@ExcludeWildCard		NVARCHAR(100) = NULL
AS 
BEGIN
  DECLARE 
    @sql_debug			BIT = 1
  ,	@sql_execute		BIT = 1
  ,	@sql_log			BIT = 1
  , @sql_rc				INT = 0
  ,	@environment_suffix	NVARCHAR(MAX) = '_PROD_Staged'
  ,	@sql_statement		NVARCHAR(MAX)
  ,	@sql_message		NVARCHAR(MAX)
  ,	@sql_crlf			NVARCHAR(2) = CHAR(13) + CHAR(10)
  ,	@sql_tab			NVARCHAR(1) = CHAR(9)
  , @curor_validate		CURSOR
  ,	@entity_name		SYSNAME
  ,	@schema_name		SYSNAME
  , @column_names		NVARCHAR(MAX)

	-- GETS ALL THE MODELLING OBJECTS TO BE VALIDATED
	SET @curor_validate = CURSOR FOR
	SELECT sch.name, tab.name 
	FROM sys.tables AS tab 
	INNER JOIN sys.schemas AS sch ON sch.schema_id = tab.schema_id 
	WHERE sch.name = @SchemaName_Modelling 
	AND tab.name NOT LIKE '%' + @ExcludeWildCard + '%'
	AND tab.name LIKE '%AUFK%'


	DECLARE @log TABLE (
		LogID			INT IDENTITY(1,1)
	,	StepName		NVARCHAR(100)
	,	StepDefinition	NVARCHAR(MAX)
	,	StepResult		BIT
	,	StepMessage		NVARCHAR(MAX)
	)

	-- LOOPS THROUGH THEM CREATING VIEWS
	OPEN @curor_validate
	FETCH NEXT FROM @curor_validate
	INTO @schema_name, @entity_name

	WHILE(@@FETCH_STATUS = 0)
	BEGIN

	SET  @column_names= ''
	
	SELECT @column_names =
	   substring(column_names, 1, len(column_names) - 1)
	FROM
		sys.tables tab
	INNER JOIN
		sys.indexes pk
		ON tab.object_id = pk.object_id
		AND pk.is_primary_key = 1
	CROSS APPLY
		(
			SELECT col.[name] + ', '
			FROM
				sys.index_columns ic
				INNER JOIN
					sys.columns col
					ON ic.object_id = col.object_id
					AND ic.column_id = col.column_id
			WHERE
				ic.object_id = tab.object_id
				AND ic.index_id = pk.index_id
			ORDER BY
				col.column_id
			FOR XML PATH ('')
		) D (column_names)
	WHERE
		tab.name = @entity_name
	AND
		schema_name(tab.schema_id) = @schema_name

	SET @sql_statement = 'SELECT ' + @column_names + ' FROM ' + @sql_crlf
	SET @sql_statement += QUOTENAME(@SchemaName_Data) + '.' + QUOTENAME(@entity_name + @environment_suffix) + @sql_crlf
	SET @sql_statement += 'GROUP BY ' + @column_names + @sql_crlf
	SET @sql_statement += 'HAVING COUNT(1) > 1' + @sql_crlf + @sql_tab

	IF (@sql_debug = 1)
	BEGIN
		SET @sql_message = @sql_statement + @sql_crlf + @sql_crlf 
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
	END

	IF (@sql_execute = 1)
	BEGIN
		BEGIN TRY
		EXEC @sql_rc = sp_executesql
				@stmt = @sql_statement
		END TRY
		BEGIN CATCH
			;THROW
		END CATCH
	END

--INSERT INTO @log (
--	StepName
--  , StepDefinition
--  , StepResult
--  , StepMessage
--	)
--SELECT
--	QUOTENAME(@schema_name) + '.' + QUOTENAME(@entity_name)
--  , @sql_statement
--  , @sql_rc
--  , NULL
--END TRY
--BEGIN CATCH
--INSERT INTO @log (
--	StepName
--  , StepDefinition
--  , StepResult
--  , StepMessage
--	)
--SELECT
--	QUOTENAME(@schema_name) + '.' + QUOTENAME(@entity_name)
--  , @sql_statement
--  , @sql_rc
--  , ERROR_MESSAGE()
--END CATCH
--END

FETCH NEXT FROM @curor_validate
INTO @schema_name, @entity_name

END

--SELECT * FROM @log
END
GO
