/*
sys.dm_sql_referenced_entities (  
    ' [ schema_name. ] referencing_entity_name ' ,
    ' <referencing_class> ' )  
  
<referencing_class> ::=  
{  
    OBJECT  
  | DATABASE_DDL_TRIGGER  
  | SERVER_DDL_TRIGGER  
}  
*/

--A. Return entities that are referenced by a database-level DDL trigger
USE DataVault;  
GO  
SELECT
        referenced_schema_name,
        referenced_entity_name,
        referenced_minor_name,
        referenced_minor_id,
        referenced_class_desc
    FROM
        sys.dm_sql_referenced_entities (
            'ddlDatabaseTriggerLog',
            'DATABASE_DDL_TRIGGER')
;
GO  

--B. Return entities that are referenced by an object
USE DataVault;  
GO  
SELECT
        referenced_schema_name,
        referenced_entity_name,
        referenced_minor_name,
        referenced_minor_id,
        referenced_class_desc,
        is_caller_dependent,
        is_ambiguous
    FROM
        sys.dm_sql_referenced_entities (
            'dbo.ufnGetContactInformation',
            'OBJECT')
;
GO  

C. Return column dependencies

CREATE TABLE dbo.Table1 (a int, b int, c AS a + b);  
GO  
SELECT
        referenced_schema_name AS schema_name,  
        referenced_entity_name AS table_name,  
        referenced_minor_name  AS referenced_column,  
        COALESCE(
            COL_NAME(OBJECT_ID(N'dbo.Table1'),
            referencing_minor_id),
            'N/A') AS referencing_column_name  
    FROM
        sys.dm_sql_referenced_entities ('dbo.Table1', 'OBJECT')
;
GO

-- Remove the table.  
DROP TABLE dbo.Table1;  
GO  


--D. Returning non-schema-bound column dependencies
--The following example drops Table1 and creates Table2 and stored procedure Proc1. The procedure references Table2 and the nonexistent table Table1. The view sys.dm_sql_referenced_entities is run with the stored procedure specified as the referencing entity. The result set shows one row for Table1 and 3 rows for Table2. Because Table1 does not exist, the column dependencies cannot be resolved and error 2020 is returned. The is_all_columns_found column returns 0 for Table1 indicating that there were columns that could not be discovered.

DROP TABLE IF EXISTS dbo.Table1;
GO  
CREATE TABLE dbo.Table2 (c1 int, c2 int);  
GO  
CREATE PROCEDURE dbo.Proc1 AS  
    SELECT a, b, c FROM Table1;  
    SELECT c1, c2 FROM Table2;  
GO  
SELECT
        referenced_id,
        referenced_entity_name AS table_name,
        referenced_minor_name  AS referenced_column_name,
        is_all_columns_found
    FROM
        sys.dm_sql_referenced_entities ('raw.HUB_Customer', 'OBJECT');
GO  


--E. Demonstrating dynamic dependency maintenance
--This Example E assumes that Example D has been run. Example E shows that dependencies are maintained dynamically. The example does the following things:

--Re-creates Table1, which was dropped in Example D.
--Run Then sys.dm_sql_referenced_entities is run again with the stored procedure specified as the referencing entity.
--The result set shows that both tables, and their respective columns defined in the stored procedure, are returned. In addition, the is_all_columns_found column returns a 1 for all objects and columns.

CREATE TABLE Table1 (a int, b int, c AS a + b);  
GO   
SELECT
        referenced_id,
        referenced_entity_name AS table_name,
        referenced_minor_name  AS column_name,
        is_all_columns_found
    FROM
        sys.dm_sql_referenced_entities ('dbo.Proc1', 'OBJECT');
GO  
DROP TABLE Table1, Table2;  
DROP PROC Proc1;  
GO  

F. Returning object or column usage
The following example returns the objects and column dependencies of the stored procedure HumanResources.uspUpdateEmployeePersonalInfo. This procedure updates the columns NationalIDNumber, BirthDate,``MaritalStatus, and Gender of the Employee table based on a specified BusinessEntityID value. Another stored procedure, upsLogError is defined in a TRY...CATCH block to capture any execution errors. The is_selected, is_updated, and is_select_all columns return information about how these objects and columns are used within the referencing object. The table and columns that are modified are indicated by a 1 in the is_updated column. The BusinessEntityID column is only selected and the stored procedure uspLogError is neither selected nor modified.

SQL

Copy
USE AdventureWorks2012;
GO
SELECT
        referenced_entity_name AS table_name,
        referenced_minor_name  AS column_name,
        is_selected,  is_updated,  is_select_all
    FROM
        sys.dm_sql_referenced_entities(
            'HumanResources.uspUpdateEmployeePersonalInfo',
            'OBJECT')
;



