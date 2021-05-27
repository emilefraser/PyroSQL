SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[dd_ScavengeDataDictionaryFields]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[dd_ScavengeDataDictionaryFields] AS' 
END
GO

ALTER PROC [dba].[dd_ScavengeDataDictionaryFields]
AS

/**************************************************************************************************************
**  Purpose:
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  11/06/2012		Michael Rounds			1.0					Comments creation
***************************************************************************************************************/

SET NOCOUNT ON
IF OBJECT_ID('tempdb..#DataDictionaryFields') IS NOT NULL
     DROP TABLE #DataDictionaryFields
IF OBJECT_ID('tempdb..#TableList') IS NOT NULL
     DROP TABLE #TableList
DECLARE 
    @SchemaOrUser sysname,
    @SQLVersion VARCHAR(30),
    @SchemaName sysname ,
    @TableName sysname
SET @SQLVersion = CONVERT(VARCHAR,SERVERPROPERTY('ProductVersion'))

CREATE TABLE #TableList(SchemaName sysname NOT null,TableName sysname NOT NULL)
INSERT INTO #TableList(SchemaName,TableName)
SELECT TABLE_SCHEMA,TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE='BASE TABLE'

IF CAST(LEFT(@SQLVersion,CHARINDEX('.',@SQLVersion)-1) AS TINYINT) <9
    SET @SchemaOrUser = 'User'
ELSE
    SET @SchemaOrUser='Schema'

CREATE TABLE #DataDictionaryFields (
    objtype sysname  NOT NULL,
    FieldName sysname NOT NULL,
    PropertyName sysname NOT NULL,
    FieldDescription VARCHAR(7000) NULL
)
DECLARE csr_dd CURSOR FAST_FORWARD FOR
    SELECT SchemaName,TableName
    FROM #TableList
OPEN csr_dd

FETCH NEXT FROM csr_dd INTO @SchemaName, @TableName
WHILE @@FETCH_STATUS = 0
    BEGIN
        TRUNCATE TABLE #DataDictionaryFields

        RAISERROR('Scavenging schema.table %s.%s',10,1,@SchemaName,@TableName) WITH NOWAIT
    INSERT INTO #DataDictionaryFields
                ( objtype ,
                  FieldName ,
                  PropertyName ,
                  FieldDescription
                )
        SELECT objtype ,
                objname ,
                   name ,
                   CONVERT(VARCHAR(7000),value )
        FROM   ::fn_listextendedproperty(NULL, @SchemaOrUser, @SchemaName, 'table', @TableName, 'column', default)
        WHERE name='MS_DESCRIPTION'

        UPDATE DT_DEST
        SET DT_DEST.FieldDescription = DT_SRC.FieldDescription
        FROM #DataDictionaryFields AS DT_SRC
            INNER JOIN dba.DataDictionary_Fields AS DT_DEST
            ON DT_SRC.FieldName COLLATE Latin1_General_CI_AS = DT_DEST.FieldName COLLATE Latin1_General_CI_AS
        WHERE DT_DEST.SchemaName COLLATE Latin1_General_CI_AS = @SchemaName	COLLATE Latin1_General_CI_AS
        AND DT_DEST.TableName COLLATE Latin1_General_CI_AS = @TableName	COLLATE Latin1_General_CI_AS
        AND DT_SRC.FieldDescription IS NOT NULL AND DT_SRC.FieldDescription<>''
        FETCH NEXT FROM csr_dd INTO @SchemaName, @TableName
    END
CLOSE csr_dd
DEALLOCATE csr_dd
IF OBJECT_ID('tempdb..#DataDictionaryFields') IS NOT NULL
     DROP TABLE #DataDictionaryFields
IF OBJECT_ID('tempdb..#TableList') IS NOT NULL
     DROP TABLE #TableList
GO
