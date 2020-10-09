SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE   PROC [dbo].[dd_ApplyDataDictionary]
AS
/**************************************************************************************************************
**  Purpose: RUN THIS WHEN YOU ARE READY TO APPLY DATA DICTIONARY TO THE EXTENDED PROPERTIES TABLES
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  11/06/2012		Michael Rounds			1.0					Comments creation
***************************************************************************************************************/
    SET NOCOUNT ON
    DECLARE @SQLVersion VARCHAR(30),
        @SchemaOrUser sysname

    SET @SQLVersion = CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion'))
    IF CAST(LEFT(@SQLVersion, CHARINDEX('.', @SQLVersion) - 1) AS TINYINT) < 9 
        SET @SchemaOrUser = 'User'
    ELSE 
        SET @SchemaOrUser = 'Schema'

    DECLARE @SchemaName sysname,
        @TableName sysname,
        @FieldName sysname,
        @ObjectDescription VARCHAR(7000)
	
    DECLARE csr_dd CURSOR FAST_FORWARD
        FOR SELECT  DT.SchemaName,
                    DT.TableName,
                    DT.TableDescription
            FROM    dbo.DataDictionary_Tables AS DT
                    INNER JOIN INFORMATION_SCHEMA.TABLES AS T
                        ON DT.SchemaName COLLATE DATABASE_DEFAULT = T.TABLE_SCHEMA COLLATE DATABASE_DEFAULT
                           AND DT.TableName COLLATE DATABASE_DEFAULT = T.TABLE_NAME COLLATE DATABASE_DEFAULT
            WHERE   DT.TableDescription <> ''
	
    OPEN csr_dd
    FETCH NEXT FROM csr_dd INTO @SchemaName, @TableName, @ObjectDescription
    WHILE @@FETCH_STATUS = 0
        BEGIN
            IF EXISTS ( SELECT  1
                        FROM    ::fn_listextendedproperty(NULL, @SchemaOrUser,
                                                        @SchemaName, 'table',
                                                        @TableName, default,
                                                        default) ) 
                EXECUTE sp_updateextendedproperty N'MS_Description',
                    @ObjectDescription, @SchemaOrUser, @SchemaName, N'table',
                    @TableName, NULL, NULL
            ELSE 
                EXECUTE sp_addextendedproperty N'MS_Description',
                    @ObjectDescription, @SchemaOrUser, @SchemaName, N'table',
                    @TableName, NULL, NULL
	
            RAISERROR ( 'DOCUMENTED TABLE: %s', 10, 1, @TableName ) WITH NOWAIT
            FETCH NEXT FROM csr_dd INTO @SchemaName, @TableName,
                @ObjectDescription
        END
    CLOSE csr_dd
    DEALLOCATE csr_dd
    DECLARE csr_ddf CURSOR FAST_FORWARD
        FOR SELECT  DT.SchemaName,
                    DT.TableName,
                    DT.FieldName,
                    DT.FieldDescription
            FROM    dbo.DataDictionary_Fields AS DT
                    INNER JOIN INFORMATION_SCHEMA.COLUMNS AS T
                        ON DT.SchemaName COLLATE DATABASE_DEFAULT = T.TABLE_SCHEMA COLLATE DATABASE_DEFAULT
                           AND DT.TableName COLLATE DATABASE_DEFAULT = T.TABLE_NAME COLLATE DATABASE_DEFAULT
                           AND DT.FieldName COLLATE DATABASE_DEFAULT = T.COLUMN_NAME COLLATE DATABASE_DEFAULT
            WHERE   DT.FieldDescription <> ''
    OPEN csr_ddf
    FETCH NEXT FROM csr_ddf INTO @SchemaName, @TableName, @FieldName,
        @ObjectDescription
    WHILE @@FETCH_STATUS = 0
        BEGIN
            IF EXISTS ( SELECT  *
                        FROM    ::fn_listextendedproperty(NULL, @SchemaOrUser,
                                                        @SchemaName, 'table',
                                                        @TableName, 'column',
                                                        @FieldName) ) 
                EXECUTE sp_updateextendedproperty N'MS_Description',
                    @ObjectDescription, @SchemaOrUser, @SchemaName, N'table',
                    @TableName, N'column', @FieldName
            ELSE 
                EXECUTE sp_addextendedproperty N'MS_Description',
                    @ObjectDescription, @SchemaOrUser, @SchemaName, N'table',
                    @TableName, N'column', @FieldName
            RAISERROR ( 'DOCUMENTED FIELD: %s.%s', 10, 1, @TableName,
                @FieldName ) WITH NOWAIT
            FETCH NEXT FROM csr_ddf INTO @SchemaName, @TableName, @FieldName,
                @ObjectDescription
        END
    CLOSE csr_ddf
    DEALLOCATE csr_ddf

GO
