SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/***********************************************************************************************************************************************
Autor:		 Michał Gołoś http://toolien.pl/sp_genmerge/
Description: Quickly and efficiently generate a MERGE statement with data,
			 which will execute INSERT / UPDATE / DELETE on the basis of the source key from the source in the target table.
Typical use cases:
•	Generate scripts for static dictionaries, save the .sql file in the code repository and continue to use it for Dev / Test / Prod implementations
•	Generate data from the Prod environment to reproduce them in your Dev/Test environment.
•	Generated scripts can be modified and restarted to migrate changes between environments.
•	Enter the test data into the Dev environment and then generate the script,  
	so that you can always restore the test database with the correct sample data
The PrintMAX procedure by Ben Dill's was used: https://weblogs.asp.net/bdill/sql-server-print-max
If the data lines are not too long (<3500 characters), you can run the procedure with result to text.
If the lines are too large and SSMS crops the text, copy the print text and paste the data from the grid into the appropriate place.
Example of use:
EXEC sp_GenMerge 'Sales.Currency'
EXEC sp_GenMerge
     @source_table           = 'Person.Person'
   , @skip_columns           = 'AdditionalContactInfo, ModifiedDate'
   , @update_only_if_changed = 0
EXEC sp_GenMerge
     @source_table  = 'Production.ScrapReason'
   , @skip_identity = 0
EXEC sp_GenMerge
     @source_query  = 'SELECT ScrapReasonID, ''DEV_'' + Name AS Name, GETDATE() AS ModifiedDate  FROM Production.ScrapReason'
   , @target_table  = 'Production.ScrapReason'
   , @on_condition  = 'Target.ScrapReasonID = Source.ScrapReasonID'
   , @skip_computed = 0
EXEC dbo.sp_GenMerge
     @source_table           = N'Production.ScrapReason'  
   , @target_table           = NULL
   , @source_query           = NULL
   , @target_query           = NULL
   , @on_condition           = NULL
   , @skip_columns           = NULL
   , @skip_insert            = 0
   , @skip_update            = 0
   , @skip_delete            = 1
   , @skip_identity          = 1
   , @skip_computed          = 0
   , @skip_timestamp         = 0
   , @skip_images            = 0
   , @skip_data              = 0
   , @update_only_if_changed = 1
   , @debug                  = 0
***********************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[sp_GenMerge](
                 @source_table              SYSNAME       = NULL -- the source table from which the data will be generated can be replaced by @source_query
		       , @target_table              SYSNAME       = NULL -- the name of the target table, if the same as @source_table can be omitted
		       , @source_query              NVARCHAR(MAX) = NULL -- query supplying source data
		       , @target_query              NVARCHAR(MAX) = NULL -- query limiting the target data for comparison
		       , @on_condition              NVARCHAR(MAX) = NULL -- connection condition of the source with the target, required when there are no PK keys
		       , @skip_columns              NVARCHAR(MAX) = NULL -- list of columns to skip
               , @skip_insert               BIT           = 0	 -- whether to skip the INSERT block
		       , @skip_update               BIT           = 0	 -- whether to skip the UPDATE block
		       , @skip_delete               BIT           = 1	 -- whether to skip the DELETE block
		       , @skip_identity             BIT           = 1	 -- Whether to skip the identity columns
		       , @skip_computed             BIT           = 0	 -- Whether to skip the computed columns
		       , @skip_timestamp            BIT           = 0	 -- Whether to skip the timestamp and rowversion columns
		       , @skip_images               BIT           = 0	 -- Whether to skip the image columns
               , @skip_data                 BIT           = 0	 -- whether to skip data, will generate a merge query of two tables
		       , @update_only_if_changed    BIT           = 1	 -- whether to generate a check whether changes have taken place before the UPDATE execution
		       , @debug                     BIT           = 0	 -- auxiliary parameter, provides information about detected columns and query retrieving batch data
)
AS
BEGIN
SET NOCOUNT ON;

EXEC (N'IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE object_id = OBJECT_ID(N''tempdb..#PrintMax'') AND type in (N''P'', N''PC''))
	DROP PROCEDURE #PrintMax;');
EXEC (N'CREATE PROCEDURE #PrintMax(@iInput NVARCHAR(MAX))
AS
BEGIN
    IF @iInput IS NULL
    RETURN;
    DECLARE @ReversedData NVARCHAR(MAX)
          , @LineBreakIndex INT
          , @SearchLength INT;
    SET @SearchLength = 4000;
     
    WHILE LEN(@iInput) > @SearchLength
    BEGIN
    SET @ReversedData = LEFT(@iInput COLLATE DATABASE_DEFAULT, @SearchLength);
    SET @ReversedData = REVERSE(@ReversedData COLLATE DATABASE_DEFAULT);
    SET @LineBreakIndex = CHARINDEX(CHAR(10) + CHAR(13), @ReversedData COLLATE DATABASE_DEFAULT);
    PRINT LEFT(@iInput, @SearchLength - @LineBreakIndex + 1);
    SET @iInput = RIGHT(@iInput, LEN(@iInput) - @SearchLength + @LineBreakIndex - 1);
    END;
    IF LEN(@iInput) > 0
    PRINT @iInput;
END;');

BEGIN TRY
    -----------------------------------------------------------------
    -------- check whether the specified source ---------------------
    IF @source_table IS NULL AND @source_query IS NULL
        RAISERROR ('You must enter the @source_table or @source_query parameter.', 16, 1);
    -----------------------------------------------------------------
    -------- check whether the specified target ---------------------
    IF @source_table IS NULL AND @target_table IS NULL AND @target_query IS NULL
        RAISERROR ('You must enter the parameter @target_table, @target_query or @source_table.', 16, 1);
    -----------------------------------------------------------------
    -------- check whether the object exists ------------------------
    IF @source_table IS NOT NULL AND OBJECT_ID(@source_table) IS NULL
        RAISERROR ('The @source_table object is missing in the current database.', 16, 1);
    -----------------------------------------------------------------

    DECLARE @ColTbl TABLE (
            side CHAR(1)
          , column_id INT
          , name SYSNAME
          , is_PK BIT
          , tp VARCHAR(128)
          , is_computed BIT
          , is_identity BIT
          , name_clear AS REPLACE(name, ' ', '_'));

    DECLARE @br CHAR(2) = CHAR(13) + CHAR(10)
          , @sql NVARCHAR(MAX) = ''
          , @delimiter NVARCHAR(1) = ',';
    DECLARE @skip_columns_table TABLE (skip_column SYSNAME COLLATE DATABASE_DEFAULT);

    IF @skip_columns IS NOT NULL
    BEGIN;
        WITH cte AS (
            SELECT SUBSTRING(@skip_columns, 0, CHARINDEX(@delimiter, @skip_columns)) AS val
                 , CAST(STUFF(@skip_columns + @delimiter, 1, CHARINDEX(@delimiter, @skip_columns), '') AS NVARCHAR(MAX)) AS stval
             UNION ALL
            SELECT SUBSTRING(cte.stval, 0, CHARINDEX(@delimiter, cte.stval))
                 , CAST(STUFF(cte.stval, 1, CHARINDEX(@delimiter, cte.stval), '') AS NVARCHAR(MAX)) AS stval
              FROM cte
             WHERE stval <> ''
        )
        INSERT INTO @skip_columns_table
        SELECT REPLACE(val, ' ', '') AS val
          FROM cte
         WHERE val LIKE '%[a-zA-Z0-9]%';
    END;

    INSERT INTO @ColTbl(side, column_id, name, is_PK, tp, is_computed, is_identity)
    SELECT 'S' AS side
            , c.column_ordinal
            , c.name
            , c.is_part_of_unique_key
            , COALESCE(c.system_type_name + '(' + IIF(c.is_xml_document = 1, 'DOCUMENT ', '') + QUOTENAME(c.xml_collection_schema) + '.' + QUOTENAME(c.xml_collection_name) + ')', c.system_type_name, QUOTENAME(c.user_type_schema) + '.' + QUOTENAME(c.user_type_name))
            , c.is_computed_column
            , c.is_identity_column                      
        FROM sys.dm_exec_describe_first_result_set(COALESCE(@source_query, 'SELECT * FROM ' + @source_table), NULL, 1) AS c
        LEFT JOIN @skip_columns_table AS sk ON c.name = sk.skip_column COLLATE DATABASE_DEFAULT
        WHERE (@skip_computed = 0 OR c.is_computed_column = 0)
        AND (@skip_timestamp = 0 OR ISNULL(c.system_type_name, 'user_type') NOT IN ('timestamp', 'rowversion'))
        AND (@skip_images = 0 OR ISNULL(c.system_type_name, 'user_type') NOT IN ('image'))
        AND (c.is_part_of_unique_key = 1 OR sk.skip_column IS NULL);

    INSERT INTO @ColTbl(side, column_id, name, is_PK, tp, is_computed, is_identity)
    SELECT 'T' AS side
            , c.column_ordinal
            , c.name
            , c.is_part_of_unique_key
            , COALESCE(c.system_type_name + '(' + IIF(c.is_xml_document = 1, 'DOCUMENT ', '') + QUOTENAME(c.xml_collection_schema) + '.' + QUOTENAME(c.xml_collection_name) + ')', c.system_type_name, QUOTENAME(c.user_type_schema) + '.' + QUOTENAME(c.user_type_name))
            , c.is_computed_column
            , c.is_identity_column                      
        FROM sys.dm_exec_describe_first_result_set(COALESCE(@target_query, 'SELECT * FROM ' + COALESCE(@target_table, @source_table)), NULL, 1) AS c
        LEFT JOIN @skip_columns_table AS sk ON c.name = sk.skip_column COLLATE DATABASE_DEFAULT
        WHERE (@skip_computed = 0 OR c.is_computed_column = 0)
        AND (@skip_timestamp = 0 OR ISNULL(c.system_type_name, 'user_type') NOT IN ('timestamp', 'rowversion'))
        AND (@skip_images = 0 OR ISNULL(c.system_type_name, 'user_type') NOT IN ('image'))
        AND (c.is_part_of_unique_key = 1 OR sk.skip_column IS NULL);

    IF @debug = 1
        SELECT * FROM @ColTbl ORDER BY side, column_id;

    -------- checking if there are columns in S and T ---------------
    IF NOT EXISTS (SELECT TOP (1) * FROM @ColTbl AS t1 JOIN @ColTbl AS t2 ON t1.name = t2.name AND t1.side = 'S' AND t2.side = 'T')
        RAISERROR ('There are no columns to be mapped, the source and target must have the same column names.', 16, 1);
    -----------------------------------------------------------------
    -------- checking if there are PK columns in S and T ------------
    IF NOT EXISTS (SELECT TOP (1) * FROM @ColTbl AS t1 JOIN @ColTbl AS t2 ON t1.name = t2.name AND t1.side = 'S' AND t2.side = 'T' AND t1.is_PK = 1) AND @on_condition IS NULL
        RAISERROR ('There must be a PK key on the source and destination table or a defined @on_condition parameter.', 16, 1);
    -----------------------------------------------------------------

    IF @skip_identity = 0 AND EXISTS(SELECT 1 FROM @ColTbl WHERE side = 'T' AND is_PK = 1 AND is_identity = 1)
        SET @sql = @sql + 'SET IDENTITY_INSERT ' + COALESCE(@target_table, @source_table) + ' ON;' + @br + @br;

    EXEC #PrintMax @sql;
    SET @sql = '';

    IF @skip_data = 0
    BEGIN
        EXEC #PrintMax 'DECLARE @xml XML = N''';
	    EXEC #PrintMax '<!-- Insert the generated data here -->';

        SELECT @sql = 'SELECT (SELECT ';
        SELECT @sql = @sql + CASE WHEN ROW_NUMBER() OVER (ORDER BY column_id) = 1 THEN '' ELSE '             , ' END
                           + CASE WHEN tp IN ('date', 'datetimeoffset', 'datetime2', 'smalldatetime', 'datetime', 'time') OR tp LIKE '%time%([0-7])' THEN 'CONVERT(NVARCHAR(MAX), ' + QUOTENAME(name) + ', 121)'
                                  WHEN tp IN ('geography', 'geometry') THEN QUOTENAME(name) + '.STAsText()'       
                                  ELSE 'REPLACE(CONVERT(NVARCHAR(MAX), ' + QUOTENAME(name) + '), '''''''', '''''''''''')' END 
                           + ' AS "@' + name_clear + '"'  + @br
          FROM @ColTbl
         WHERE side = 'S'
         ORDER BY column_id;

        SELECT @sql = @sql + 'FOR XML PATH(''v''),TYPE)' + @br + 'FROM ' + CASE WHEN @source_table IS NOT NULL THEN @source_table ELSE '(' + @source_query + ')' END + ' AS [v]' + @br;

        IF @debug = 1
        BEGIN
            EXEC #PrintMax '---------------------------------------------------------------------------';
            EXEC #PrintMax @sql;
            EXEC #PrintMax '---------------------------------------------------------------------------';
        END;

        IF @debug = 0
            EXEC (@sql);

        EXEC #PrintMax ''';';

        SET @sql = '' + @br;
    END

    IF @target_query IS NOT NULL
        SET @sql = @sql + 'WITH target_query AS (' + @br + '    ' + @target_query + @br + ')';

    IF @skip_data = 1 AND @source_query IS NOT NULL
        SET @sql = @sql + IIF(@target_query IS NOT NULL, ', source_query AS (', 'WITH source_query AS (') + @br + '    ' + @source_query + @br + ')';

    SET @sql = @sql + @br + 'MERGE INTO '
                    + IIF(@target_query IS NOT NULL, 'target_query', COALESCE(@target_table, @source_table)) + ' AS Target' + @br 
                    + 'USING ' + CASE WHEN @skip_data = 1 AND @source_query IS NOT NULL THEN 'source_query AS Source'
                                      WHEN @skip_data = 1 AND @source_query IS NULL THEN @source_table + ' AS Source'
                                      ELSE '(SELECT ' END;

    IF @skip_data = 0
    BEGIN                                    
        SELECT @sql = @sql + CASE WHEN ROW_NUMBER() OVER (ORDER BY column_id) = 1 THEN '' ELSE '            , ' END
                           + CASE WHEN tp LIKE 'XML%' THEN 'CONVERT(' + tp + ', x.value(''(@' + name_clear + ')'', ''NVARCHAR(MAX)'')'
                                  WHEN tp IN ('date', 'datetimeoffset', 'datetime2', 'smalldatetime', 'datetime', 'time') OR tp LIKE '%time%([0-7])' THEN 'CONVERT(' + tp + ', x.value(''(@' + name_clear + ')'', ''NVARCHAR(36)''), 121'
                                  WHEN tp IN ('hierarchyid', 'geography', 'geometry') THEN 'CONVERT(' + tp + ', x.value(''(@' + name_clear + ')'', ''NVARCHAR(MAX)'')'
                                  ELSE 'x.value(''(@' + name_clear + ')'', ''' + tp + '''' END + ') AS [' + name + ']' + @br
          FROM @ColTbl
         WHERE side = 'S'
         ORDER BY column_id;

        SET @sql = @sql + '	    FROM @xml.nodes(''v'') AS t(x)';

    SELECT @sql = @sql + ') AS Source (' + LEFT(cols, LEN(cols) - 1) + ')' + @br
      FROM (SELECT '[' + name + '], ' AS [text()]
              FROM @ColTbl
             WHERE side = 'S'
             ORDER BY column_id
            FOR XML PATH ('')
        ) AS t1 (cols);
    END

    IF @on_condition IS NOT NULL
        SET @sql = @sql + '  ON (' + @on_condition + ')' + @br;
    ELSE
        SELECT @sql = @sql + '  ON (' + LEFT(cols, LEN(cols) - 4) + ')' + @br
          FROM (SELECT 'Target.[' + t1.name + '] = Source.[' + t2.name + '] AND ' AS [text()]
                  FROM @ColTbl AS t1
                  JOIN @ColTbl AS t2
                       ON t1.name = t2.name
                 WHERE t1.side = 'T'
                   AND t2.side = 'S'
                   AND t1.is_PK = 1
                   AND t2.is_PK = 1
                 ORDER BY t1.column_id
                FOR XML PATH ('')) AS t1 (cols);

    IF @skip_insert = 0
    BEGIN
        SELECT @sql = @sql + 'WHEN NOT MATCHED BY TARGET' + @br + 'THEN INSERT('
    
        SELECT @sql = @sql + CASE WHEN ROW_NUMBER() OVER (ORDER BY t1.column_id) = 1 THEN '' ELSE @br + '	      , ' END
                           + '[' + t1.name + ']'
          FROM @ColTbl AS t1
          JOIN @ColTbl AS t2
               ON t1.name = t2.name
         WHERE t1.side = 'T'
           AND t2.side = 'S'
           AND (@skip_identity = 0 OR t1.is_identity = 0)
         ORDER BY t1.column_id;

        SELECT @sql = @sql + ')' + @br + '	 VALUES(';

        SELECT @sql = @sql + CASE WHEN ROW_NUMBER() OVER (ORDER BY t1.column_id) = 1 THEN '' ELSE @br + '	      , ' END
                           + 'Source.[' + t1.name + ']'
          FROM @ColTbl AS t1
          JOIN @ColTbl AS t2
               ON t1.name = t2.name
         WHERE t1.side = 'S'
           AND t2.side = 'T'
           AND (@skip_identity = 0 OR t1.is_identity = 0)
         ORDER BY t2.column_id;

        SELECT @sql = @sql + ')' + @br;
    END

    IF @skip_update = 0
    BEGIN
        IF @update_only_if_changed = 0
        BEGIN
            SET @sql = @sql + 'WHEN MATCHED' + @br + 'THEN UPDATE SET ';

            SELECT @sql = @sql + CASE WHEN ROW_NUMBER() OVER (ORDER BY t1.column_id) = 1 THEN '' ELSE @br + '	          , ' END
                               + 'Target.[' + t1.name + '] = Source.[' + t2.name + ']'
              FROM @ColTbl AS t1
              JOIN @ColTbl AS t2
                   ON t1.name = t2.name
             WHERE t1.side = 'T'
               AND t2.side = 'S'
               AND t1.is_PK = 0
               AND t2.is_PK = 0
               AND (t1.name NOT IN (SELECT skip_column COLLATE DATABASE_DEFAULT FROM @skip_columns_table) OR @skip_columns IS NULL)
             ORDER BY t1.column_id;
        END;
        ELSE IF @update_only_if_changed = 1
        BEGIN
            SET @sql = @sql + 'WHEN MATCHED AND EXISTS (SELECT ';
            SELECT @sql = @sql + CASE WHEN ROW_NUMBER() OVER (ORDER BY t1.column_id) = 1 THEN '' ELSE @br + '	                          , ' END 
                               + CASE WHEN t1.tp LIKE 'XML%' THEN 'CAST(Target.[' + t1.name + '] AS NVARCHAR(MAX))'
                                      WHEN t1.tp IN ('geography', 'geometry') THEN 'Target.[' + t1.name + '].STAsText()' ELSE 'Target.[' + t1.name + ']' END
              FROM @ColTbl AS t1
              JOIN @ColTbl AS t2 ON t1.name = t2.name
             WHERE t1.side = 'T'
               AND t2.side = 'S'
               AND t1.is_PK = 0
               AND t2.is_PK = 0
             ORDER BY t1.column_id;

            SET @sql = @sql + @br 
                            + '                         EXCEPT' + @br
                            + '                         SELECT ';

            SELECT @sql = @sql + CASE WHEN ROW_NUMBER() OVER (ORDER BY t1.column_id) = 1 THEN '' ELSE @br + '	                          , ' END 
                               + CASE WHEN t1.tp LIKE 'XML%' THEN 'CAST(Source.[' + t1.name + '] AS NVARCHAR(MAX))'
                                      WHEN t1.tp IN ('geography', 'geometry') THEN 'Target.[' + t1.name + '].STAsText()' ELSE 'Source.[' + t1.name + ']' END
              FROM @ColTbl AS t1
              JOIN @ColTbl AS t2 ON t1.name = t2.name
             WHERE t1.side = 'S'
               AND t2.side = 'T'
               AND t1.is_PK = 0
               AND t2.is_PK = 0
             ORDER BY t2.column_id;

            SET @sql = @sql + ')' + @br;

            SET @sql = @sql + 'THEN UPDATE SET ';

            SELECT @sql = @sql + CASE WHEN ROW_NUMBER() OVER (ORDER BY t1.column_id) = 1 THEN '' ELSE @br + '	          , ' END
                               + 'Target.[' + t1.name + '] = Source.[' + t2.name + ']'
              FROM @ColTbl AS t1
              JOIN @ColTbl AS t2
                   ON t1.name = t2.name
             WHERE t1.side = 'T'
               AND t2.side = 'S'
               AND t1.is_PK = 0
               AND t2.is_PK = 0
             ORDER BY t1.column_id;
        END;
    END;
    IF @skip_delete = 0
        SET @sql = @sql + @br + 'WHEN NOT MATCHED BY SOURCE' + @br + 'THEN DELETE';

    SET @sql = @sql + ';' + @br;

    IF @skip_identity = 0 AND EXISTS(SELECT 1 FROM @ColTbl WHERE side = 'T' AND is_PK = 1 AND is_identity = 1)
        SET @sql = @sql + @br + 'SET IDENTITY_INSERT ' + COALESCE(@target_table, @source_table) + ' OFF' + @br;

    SET @sql = @sql + 'GO' + @br + @br;

    EXEC #PrintMax @sql;
END TRY
BEGIN CATCH
    EXEC #PrintMax @sql;
    THROW;
END CATCH;

IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE object_id = OBJECT_ID(N'tempdb..#PrintMax') AND type IN (N'P', N'PC'))
    DROP PROCEDURE #PrintMax;
END;

GO
