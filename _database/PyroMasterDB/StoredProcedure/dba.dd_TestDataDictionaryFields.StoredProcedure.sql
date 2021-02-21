SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[dd_TestDataDictionaryFields]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[dd_TestDataDictionaryFields] AS' 
END
GO

ALTER PROC [dba].[dd_TestDataDictionaryFields]
AS

/**************************************************************************************************************
**  Purpose: RUN THIS TO FIND TABLES AND/OR FIELDS THAT ARE MISSING DATA
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  11/06/2012		Michael Rounds			1.0					Comments creation
***************************************************************************************************************/

    SET NOCOUNT ON
    DECLARE @RecordCount INT
    DECLARE @FieldList TABLE
        (
          SchemaName sysname NOT NULL,
          TableName SYSNAME NOT NULL,
          FieldName sysname NOT NULL,
          PRIMARY KEY CLUSTERED ( SchemaName, TableName, FieldName )
        )
    EXEC dba.dd_PopulateDataDictionary -- Ensure the dba.DataDictionary tables are up-to-date.
    INSERT  INTO @FieldList
            (
              SchemaName,
              TableName,
              FieldName
            )
            SELECT  SchemaName,
                    TableName,
                    FieldName
            FROM    dba.DataDictionary_Fields
            WHERE   TableName NOT LIKE 'MSp%' -- ???
                    AND TableName NOT LIKE 'sys%' -- Exclude standard system tables.
                    AND FieldDescription = ''
    SET @RecordCount = @@ROWCOUNT
    IF @RecordCount > 0 
        BEGIN
            PRINT ''
            PRINT 'The following recordset shows the tables/fields for which data dictionary descriptions are missing'
            PRINT ''
            SELECT  LEFT(SchemaName, 15) AS SchemaName,
                    LEFT(TableName, 30) AS TableName,
                    LEFT(FieldName, 30) AS FieldName
            FROM    @FieldList
            UNION ALL
            SELECT  '',
                    '',
                    '' -- Used to force a blank line
            RAISERROR ( '%i field(s) lack descriptions', 16, 1, @RecordCount )
                WITH NOWAIT
        END
GO
