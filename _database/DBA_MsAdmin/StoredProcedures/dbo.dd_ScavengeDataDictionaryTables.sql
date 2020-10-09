SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE   PROC [dbo].[dd_ScavengeDataDictionaryTables]
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
    IF OBJECT_ID('tempdb..#DataDictionaryTables') IS NOT NULL 
        DROP TABLE #DataDictionaryTables
    DECLARE @SchemaOrUser sysname,
        @SQLVersion VARCHAR(30),
        @SchemaName sysname 
    SET @SQLVersion = CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion'))
    SET @SchemaName = ''
    DECLARE @SchemaList TABLE
        (
          SchemaName sysname NOT NULL
                             PRIMARY KEY CLUSTERED
        )
    INSERT  INTO @SchemaList ( SchemaName )
            SELECT DISTINCT
                    TABLE_SCHEMA
            FROM    INFORMATION_SCHEMA.TABLES
            WHERE   TABLE_TYPE = 'BASE TABLE'
    IF CAST(LEFT(@SQLVersion, CHARINDEX('.', @SQLVersion) - 1) AS TINYINT) < 9 
        SET @SchemaOrUser = 'User'
    ELSE 
        SET @SchemaOrUser = 'Schema'
	
    DROP TABLE IF EXISTS #DataDictionaryTables
 CREATE TABLE  #DataDictionaryTables
        (
          objtype sysname NOT NULL,
          TableName sysname NOT NULL,
          PropertyName sysname NOT NULL,
          TableDescription VARCHAR(7000) NULL
        )
    WHILE @SchemaName IS NOT NULL
        BEGIN
            TRUNCATE TABLE #DataDictionaryTables
		
            SELECT  @SchemaName = MIN(SchemaName)
            FROM    @SchemaList
            WHERE   SchemaName > @SchemaName
		
            IF @SchemaName IS NOT NULL 
                BEGIN
                    RAISERROR ( 'Scavenging schema %s', 10, 1, @SchemaName )
                        WITH NOWAIT
                    INSERT  INTO #DataDictionaryTables
                            (
                              objtype,
                              TableName,
                              PropertyName,
                              TableDescription
						
                            )
                            SELECT  objtype,
                                    objname,
                                    name,
                                    CONVERT(VARCHAR(7000), value)
                            FROM    ::fn_listextendedproperty(NULL,
                                                            @SchemaOrUser,
                                                            @SchemaName,
                                                            'table', default,
                                                            default, default)
                            WHERE   name = 'MS_DESCRIPTION'
                    UPDATE  DT_DEST
                    SET     DT_DEST.TableDescription = DT_SRC.TableDescription
                    FROM    #DataDictionaryTables AS DT_SRC
                            INNER JOIN dbo.DataDictionary_Tables AS DT_DEST
                                ON DT_SRC.TableName COLLATE DATABASE_DEFAULT = DT_DEST.TableName COLLATE DATABASE_DEFAULT
                    WHERE   DT_DEST.SchemaName COLLATE DATABASE_DEFAULT = @SchemaName COLLATE DATABASE_DEFAULT
                            AND DT_SRC.TableDescription IS NOT NULL
                            AND DT_SRC.TableDescription <> ''
                END
        END
    IF OBJECT_ID('tempdb..#DataDictionaryTables') IS NOT NULL 
        DROP TABLE #DataDictionaryTables

GO
