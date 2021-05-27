SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[dd_TestDataDictionaryTables]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[dd_TestDataDictionaryTables] AS' 
END
GO

ALTER PROC [dba].[dd_TestDataDictionaryTables]
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
    DECLARE @TableList TABLE
        (
          SchemaName sysname NOT NULL,
          TableName SYSNAME NOT NULL,
          PRIMARY KEY CLUSTERED ( SchemaName, TableName )
        )
    DECLARE @RecordCount INT
    EXEC dba.dd_PopulateDataDictionary -- Ensure the dba.DataDictionary tables are up-to-date.
    INSERT  INTO @TableList ( SchemaName, TableName )
            SELECT  SchemaName,
                    TableName
            FROM    dba.DataDictionary_Tables
            WHERE   TableName NOT LIKE 'MSp%' -- ???
                    AND TableName NOT LIKE 'sys%' -- Exclude standard system tables.
                    AND TableDescription = ''
    SET @RecordCount = @@ROWCOUNT
    IF @RecordCount > 0 
        BEGIN
            PRINT ''
            PRINT 'The following recordset shows the tables for which data dictionary descriptions are missing'
            PRINT ''
            SELECT  LEFT(SchemaName, 15) AS SchemaName,
                    LEFT(TableName, 30) AS TableName
            FROM    @TableList
            UNION ALL
            SELECT  '',
                    '' -- Used to force a blank line
            RAISERROR ( '%i table(s) lack descriptions', 16, 1, @RecordCount )
                WITH NOWAIT
        END
GO
