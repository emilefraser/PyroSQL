SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:     Emile Fraser
-- Create Date: 2019-07-17
-- Description: Creating External Table 
-- =============================================
--SELECT [DC].[udf_generate_DDL_AZSQL_ExternalTable_Create](47064)
--SELECT [DC].[udf_generate_DDL_AZSQL_ExternalTable_Create](47325)
CREATE FUNCTION [DC].[udf_generate_DDL_AZSQL_ExternalTable_Create](
	@Source_DataEntityID AS INT
)

RETURNS VARCHAR(MAX) 
AS
BEGIN
    -- Declare the return variable here
    DECLARE @CreateExternalDataTableSQL AS VARCHAR(MAX) = ''
	DECLARE @ExternalDatasource_Prefix AS VARCHAR(MAX) = 'ExtDsrc_'
	DECLARE @ExternalTableName_Prefix AS VARCHAR(MAX) = 'ext_'
	
    DECLARE @Source_DataSourceName AS VARCHAR(MAX)
    DECLARE @Source_SchemaName AS VARCHAR(MAX)
	DECLARE @Source_DatabaseName AS VARCHAR(MAX)
	DECLARE @Source_DataEntityName AS VARCHAR(MAX)

    DECLARE @Target_SchemaName AS VARCHAR(MAX) = QUOTENAME('dbo')
	DECLARE @Target_ExternalTableName AS VARCHAR(MAX)	
	
	SET @Source_SchemaName =  
	(
		SELECT 
			SchemaName 
		FROM 
			DC.[Schema] 
		WHERE 
			SchemaID = DC.udf_GetSchemaIDForDataEntityID(@Source_DataEntityID)
	)

	SET @Source_DatabaseName =
	(
		SELECT
			   [db].[DatabaseName]
		FROM
			 [DC].[Database] AS [db]
		INNER JOIN
			[DC].[Schema] AS [s]
			ON [db].[DatabaseID] = [s].[DatabaseID]
		WHERE 
			[s].[SchemaID] = [DC].[udf_GetSchemaIDForDataEntityID](@Source_DataEntityID)
	)

	SET @Source_DataEntityName =
	(
		SELECT [DC].[udf_GetDataEntityNameForDataEntityID](@Source_DataEntityID)
	)
	
	
	SET @Source_DataSourceName = @ExternalDatasource_Prefix + @Source_DatabaseName

	SET @Target_ExternalTableName =  QUOTENAME(@ExternalTableName_Prefix + @Source_DatabaseName + '_' + @Source_SchemaName + '_' + @Source_DataEntityName)
	
	SELECT @CreateExternalDataTableSQL = @CreateExternalDataTableSQL +
		'CREATE EXTERNAL TABLE ' + @Target_SchemaName + '.' + @Target_ExternalTableName + CHAR(13) +
		    '(' + CHAR(13)
		   + [DC].[udf_FieldListForCreateExternalTable](@Source_DataEntityID) + CHAR(13) 
		   + ')' + CHAR(13)
		   + 'WITH ' + CHAR(13)
		   + '(' + CHAR(13)
		   + REPLICATE(CHAR(9),3) + 'DATA_SOURCE = ' + @Source_DataSourceName + ',' + CHAR(13)
		   + REPLICATE(CHAR(9),3) + 'SCHEMA_NAME = ''' + @Source_SchemaName + ''',' + CHAR(13)
		   + REPLICATE(CHAR(9),3) + 'OBJECT_NAME = ''' + @Source_DataEntityName + '''' + CHAR(13)
		   + ');' + CHAR(10) + CHAR(13)


    -- Return the result of the function
    RETURN @CreateExternalDataTableSQL
END


GO
