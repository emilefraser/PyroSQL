USE master;
GO
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: Script QuoteNamed Column names for a given table 
--#################################################################################################
IF OBJECT_ID('dbo.sp_colz') IS NOT NULL
  DROP PROCEDURE dbo.sp_colz;
GO
CREATE PROCEDURE sp_colz
  @Tablename SYSNAME
AS
  BEGIN
      IF LEFT(@Tablename, 1) = '['
         AND LEFT(REVERSE(@Tablename), 1) = ']'
        SET @Tablename = REPLACE(REPLACE(@Tablename, '[', ''), ']', '')

      IF LEFT(@Tablename, 1) = '#'
        BEGIN
            SELECT DISTINCT
              quotename(schema_name(t.schema_id))  + '.' + quotename(t.name) As QualifiedObjectName,
              schema_name(t.schema_id) As SchemaName,
              t.name,
              sq.Columns
            FROM   tempdb.sys.tables t
            JOIN   (SELECT
                      OBJECT_ID,
                      Columns = STUFF((SELECT
                                         ',' + QUOTENAME(name)
                                       FROM   tempdb.sys.columns sc
                                       WHERE  sc.object_id = s.object_id
                                       ORDER BY sc.column_id
                                       FOR XML PATH('')), 1, 1, '')
                                      
                    FROM   tempdb.sys.columns s) sq
              ON t.object_id = sq.object_id
            WHERE  t.object_id = object_id('tempdb.dbo.' + @Tablename)
        END
      ELSE
        BEGIN
            SELECT DISTINCT
            quotename(schema_name(t.schema_id))  + '.' + quotename(t.name) As QualifiedObjectName,
              schema_name(t.schema_id) As SchemaName,
              t.name,
              sq.Columns
            FROM   sys.objects t
            JOIN   (SELECT
                      OBJECT_ID,
                      Columns = STUFF((SELECT
                                         ',' + QUOTENAME(name)
                                       FROM   sys.columns sc
                                       WHERE  sc.object_id = s.object_id
                                       ORDER BY sc.column_id
                                       FOR XML PATH('')), 1, 1, '')
                    FROM   sys.columns s) sq
              ON t.object_id = sq.object_id
            WHERE  t.name = @Tablename
        END --ELSE
  END --PROC
GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject 'sp_colz'
GRANT EXECUTE ON dbo.sp_colz TO PUBLIC;
--#################################################################################################
GO