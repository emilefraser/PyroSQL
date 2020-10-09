SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Francois Senekal
-- Create Date: 19 Oct 2018
-- Updated Date: 2019-11-26
-- Description: Creates DDL from a DataEntity ID.
-- =============================================
-- =======================================================================================================================================
-- Version Control
-- Creator:      Francois Senekal
-- Modified by:	 Emile Fraser (check existence) - 2019-11-26 - Check for existence before creation
--                                              - 2020-01-20 Added @IsDropAndRecreate Parameter and Functionality     
--                                              - 2020-01-20 Added BEGIN & END to @Sql2
--                                              - 2020-01-20 Added @sql_crlf to Proc
-- =======================================================================================================================================

/*

DECLARE @DDLScript VARCHAR(MAX)
DECLARE @DataEntityID INT
DECLARE @TargetDataBaseName VARCHAR(50)
DECLARE @IsDropAndRecreateTable BIT

SET @DataEntityID = 47694 --[#####]
SET @TargetDataBaseName = 'StageArea'
SET @IsDropAndRecreateTable = 1

EXECUTE [DMOD].[sp_ddl_CreateTableFromDC] 
		@DDLScript OUTPUT
	  , @DataEntityID
	  , @TargetDataBaseName
      , @IsDropAndRecreateTable

RAISERROR(@DDLScript,0,1)
*/
CREATE     PROCEDURE [DMOD].[sp_ddl_CreateTableFromDC] 
	@DDLScript                  NVARCHAR(MAX) OUTPUT
  , @DataEntityID               INT
  , @TargetDataBaseName         VARCHAR(50)
  , @IsDropAndRecreateTable     BIT = 0         -- EF Change, 201200120, To Facilicate Reloads after schema change
AS
BEGIN

    -- Dynamic Variable Block
    DECLARE @Sql NVARCHAR(MAX)
	DECLARE @Sql1 NVARCHAR(MAX)
	DECLARE @Sql2 NVARCHAR(MAX)
    DECLARE @Sql3 NVARCHAR(MAX)
    DECLARE @sql_crlf NVARCHAR(2) = CHAR(13) + CHAR(10)
    DECLARE @sql_eos NVARCHAR(4) = REPLICATE(CHAR(13), 2)

	DECLARE @InTable NVARCHAR(100) =
	(
		SELECT TOP 1 
			[DataEntityName]
		FROM 
			[dc].[dataentity]
		WHERE
			[dataentityid] = @DataEntityID
	)

	DECLARE @Schema VARCHAR(100) =
	(
		SELECT TOP 1 
			[SchemaName]
		FROM 
			[dc].[Schema] AS [s]
		INNER JOIN
			[dc].[DataEntity] AS [de]
		ON
			[de].[SchemaID] = [s].[SchemaID]
		WHERE
			[dataentityid] = @DataEntityID
	)

	DECLARE @Database VARCHAR(100) =
	(
		SELECT TOP 1 
			[DatabaseName]
		FROM 
			[DC].[Database] AS [db]
		INNER JOIN
			[dc].[Schema] AS [s]
		ON
			[s].[databaseid] = [db].[databaseid]
		INNER JOIN
			[dc].[DataEntity] AS [de]
		ON
			[de].[SchemaID] = [s].[SchemaID]
		WHERE
			[dataentityid] = @DataEntityID
	)



	SET @Sql = ('IF (NOT EXISTS (SELECT name 
						     FROM sys.schemas 
						     WHERE name = ''' + @Schema + '''
							  )
				 )
				BEGIN
					EXEC(''CREATE SCHEMA [' + @Schema + ']'')
				END			
				' + @sql_eos)

    -- Check for table existsence
	SET @Sql1 = ('IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@TargetDataBaseName) + '.sys.tables AS t
                INNER JOIN ' + QUOTENAME(@TargetDataBaseName) + '.sys.schemas AS s
                ON s.schema_id = t.schema_id
                WHERE t.name = ''' + @InTable + '''
                AND s.name = ''' + @Schema + ''')' + @sql_eos)


    -- Statement Gets Assigned but only used if IsDropAndRecreate set to 1


    SET @Sql3 = 'DROP TABLE IF EXISTS '  + QUOTENAME(@TargetDataBaseName) 
                                    + '.' + QUOTENAME(@Schema)  
                                    + '.' + QUOTENAME(@InTable) + @sql_crlf
                                    + @sql_eos


	SET @Sql2 =
	(
		SELECT 
			REPLICATE(CHAR(9), 4) + 'CREATE TABLE '     + QUOTENAME(@TargetDataBaseName) 
                                                + '.'   + QUOTENAME(@Schema) 
                                                + '.'   + QUOTENAME(@InTable) 
                                                +       '(' + [o].[list] + ')'
		FROM 
			[DC].[DataEntity] AS [de]
		CROSS APPLY
		(
			SELECT + 
				QUOTENAME([FieldName]) + ' ' + [DataType] + CASE [DataType]
															WHEN 'int'
																THEN ''
															WHEN 'image'
																THEN ''
															WHEN 'tinyint'
																THEN ''
															WHEN 'bigint'
																THEN ''
															WHEN 'bit'
																THEN ''
															WHEN 'smallint'
																THEN ''
															WHEN 'decimal'
																THEN '(' + CAST([precision] AS VARCHAR) + ', ' + CAST([scale] AS VARCHAR) + ')'
															WHEN 'numeric'
																THEN '(' + CAST([precision] AS VARCHAR) + ', ' + CAST([scale] AS VARCHAR) + ')'
															WHEN 'date'
																THEN ''
															WHEN 'datetime'
																THEN ''
															WHEN 'datetime2'
																THEN '(7)'
															WHEN 'real'
																THEN ''
															ELSE COALESCE('(' +
                                                                                CASE
																				WHEN
				[MaxLength] = -1
																						THEN 'MAX'
																					ELSE CAST([MaxLength] AS VARCHAR)
																				END + ')', '')
														END + ' NULL,'
			FROM 
				[DC].[Field] AS [f]
			WHERE
				[f].[DataEntityID] = [de].[DataEntityID]
			ORDER BY 
				[FieldSortOrder] ASC FOR
			XML PATH('')
		) AS [o]([list])
		LEFT JOIN
			[DC].[Field] AS [f]
		ON
			[f].[DataEntityID] = [de].[DataEntityID]
			AND
			[f].[IsPrimaryKey] = 1
		WHERE
			[de].[DataEntityID] = @DataEntityID
	)

    -- Added BEGIN END (EF)
    SET @Sql2 = 'BEGIN' + @sql_crlf + @Sql2 + @sql_crlf + 'END' + @sql_eos
    

	SET @DDLScript = @Sql +  IIF(@IsDropAndRecreateTable = 1, @Sql3, '') + @Sql1 + @Sql2
    SELECT(@DDLScript)
END

GO
