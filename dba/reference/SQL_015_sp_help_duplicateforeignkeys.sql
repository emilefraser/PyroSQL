USE [master]

GO

IF Object_id('[dbo].[sp_help_duplicateforeignkeys]') IS NOT NULL
  DROP PROCEDURE [dbo].[sp_help_duplicateforeignkeys]

GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE PROCEDURE sp_help_duplicateforeignkeys
AS
    ; WITH FKS
         AS (SELECT Object_name(constid)                      AS ConstraintName,
                    Object_schema_name(rkeyid)                AS SchemaName,
                    Object_name(rkeyid)                       AS TableName,
                    Col_name(rkeyid, rkey)                    AS ColumnName,
                    Object_schema_name(fkeyid)                AS FKSchemaName,
                    Object_name(fkeyid)                       AS FKTableName,
                    Col_name(fkeyid, fkey)                    AS FKColumnName,
                    ' ALTER TABLE '
                    + Quotename(Object_schema_name(fkeyid)) + '.'
                    + Quotename(Object_name(fkeyid))
                    + ' DROP CONSTRAINT '
                    + Quotename(Object_name(constid)) + ';'   AS FKSQLDrop,
                    ' ALTER TABLE '
                    + Quotename(Object_schema_name(fkeyid)) + '.'
                    + Quotename(Object_name(fkeyid))
                    + ' ADD CONSTRAINT '
                    + Quotename(Object_name(constid))
                    + ' FOREIGN KEY ('
                    + Quotename(Col_name(fkeyid, fkey))
                    + ') REFERENCES '
                    + Quotename(Object_name(rkeyid)) + '('
                    + Quotename(Col_name(rkeyid, rkey)) + ')' AS FKSQLAdd
             --SELECT *
             FROM   sysforeignkeys),
         IdentifiedDupes
         AS (SELECT Row_number()
                      OVER (
                        PARTITION BY FKS.SchemaName, FKS.TableName, FKS.ColumnName, FKS.FKSchemaName, FKS.FKTableName, FKS.FKColumnName
                        ORDER BY FKS.ConstraintName) AS RW,
                    FKS.ConstraintName,
                    FKS.SchemaName,
                    FKS.TableName,
                    FKS.ColumnName,
                    FKS.FKSchemaName,
                    FKS.FKTableName,
                    FKS.FKColumnName,
                    FKSQLDrop,
                    FKSQLAdd
             --X.SchemaName,
             --X.TableName,
             --X.ColumnName,
             --X.FKSchemaName,
             --X.FKTableName,
             --X.FKColumnName
             FROM   FKS
                    INNER JOIN (SELECT SchemaName,
                                       TableName,
                                       ColumnName,
                                       FKSchemaName,
                                       FKTableName,
                                       FKColumnName
                                FROM   FKS
                                GROUP  BY SchemaName,
                                          TableName,
                                          ColumnName,
                                          FKSchemaName,
                                          FKTableName,
                                          FKColumnName
                                HAVING Count(*) > 1) X
                            ON FKS.SchemaName = X.SchemaName
                               AND FKS.TableName = X.TableName
                               AND FKS.ColumnName = X.ColumnName
                               AND FKS.FKSchemaName = X.FKSchemaName
                               AND FKS.FKTableName = X.FKTableName
                               AND FKS.FKColumnName = X.FKColumnName)
    SELECT [RW],
           [ConstraintName],
           [SchemaName],
           [TableName],
           [ColumnName],
           [FKSchemaName],
           [FKTableName],
           [FKColumnName],
           CASE
             WHEN RW = 1 THEN ''
             ELSE [FKSQLDrop]
           END AS [FKSQLDrop],
           [FKSQLAdd]
    FROM   IdentifiedDupes
    ORDER  BY SchemaName,
              TableName,
              ColumnName,
              FKTableName,
              FKColumnName

GO

--#################################################################################################
--Mark as a system object
EXECUTE Sp_ms_marksystemobject
  '[dbo].[sp_help_duplicateforeignkeys]'
--#################################################################################################
