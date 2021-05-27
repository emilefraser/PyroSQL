SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[dd_PopulateDataDictionary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[dd_PopulateDataDictionary] AS' 
END
GO

ALTER PROC [dba].[dd_PopulateDataDictionary]
AS

/**************************************************************************************************************
**  Purpose: RUN THIS TO POPULATE DATA DICTIONARY PROCESS TABLES
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  11/06/2012		Michael Rounds			1.0					Comments creation
***************************************************************************************************************/

    SET NOCOUNT ON
    DECLARE @TableCount INT,
        @FieldCount INT
    INSERT  INTO dba.DataDictionary_Tables ( SchemaName, TableName )
            SELECT  SRC.TABLE_SCHEMA,
                    TABLE_NAME
            FROM    INFORMATION_SCHEMA.TABLES AS SRC
                    LEFT JOIN dba.DataDictionary_Tables AS DEST
                        ON SRC.table_Schema = DEST.SchemaName
                           AND SRC.table_name = DEST.TableName
            WHERE   DEST.SchemaName IS NULL
                    AND SRC.table_Type = 'BASE TABLE'
                    AND OBJECTPROPERTY(OBJECT_ID(QUOTENAME(SRC.TABLE_SCHEMA)
                                                 + '.'
                                                 + QUOTENAME(SRC.TABLE_NAME)),
                                       'IsMSShipped') = 0
    SET @TableCount = @@ROWCOUNT
    INSERT  INTO dba.DataDictionary_Fields
            (
              SchemaName,
              TableName,
              FieldName
            )
            SELECT  C.TABLE_SCHEMA,
                    C.TABLE_NAME,
                    C.COLUMN_NAME
            FROM    INFORMATION_SCHEMA.COLUMNS AS C
                    INNER JOIN dba.DataDictionary_Tables AS T
                        ON C.TABLE_SCHEMA = T.SchemaName
                           AND C.TABLE_NAME = T.TableName
                    LEFT JOIN dba.DataDictionary_Fields AS F
                        ON C.TABLE_SCHEMA = F.SchemaName
                           AND C.TABLE_NAME = F.TableName
                           AND C.COLUMN_NAME = F.FieldName
            WHERE   F.SchemaName IS NULL
                    AND OBJECTPROPERTY(OBJECT_ID(QUOTENAME(C.TABLE_SCHEMA)
                                                 + '.'
                                                 + QUOTENAME(C.TABLE_NAME)),
                                       'IsMSShipped') = 0
    SET @FieldCount = @@ROWCOUNT
    RAISERROR ( 'DATA DICTIONARY: %i tables & %i fields added', 10, 1,
        @TableCount, @FieldCount ) WITH NOWAIT
GO
