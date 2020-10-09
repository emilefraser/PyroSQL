SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE   PROC [dbo].[dd_TestDataDictionaryTables]
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
    EXEC dbo.dd_PopulateDataDictionary -- Ensure the dbo.DataDictionary tables are up-to-date.
    INSERT  INTO @TableList ( SchemaName, TableName )
            SELECT  SchemaName,
                    TableName
            FROM    dbo.DataDictionary_Tables
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
