
C. Returning cross-database dependencies
The following example returns all cross-database dependencies. The example first creates the database db1 and two stored procedures that reference tables in the databases db2 and db3. The sys.sql_expression_dependencies table is then queried to report the cross-database dependencies between the procedures and the tables. Notice that NULL is returned in the referenced_schema_name column for the referenced entity t3 because a schema name was not specified for that entity in the definition of the procedure.


Copy
CREATE DATABASE db1;  
GO  
USE db1;  
GO  
CREATE PROCEDURE p1 AS SELECT * FROM db2.s1.t1;  
GO  
CREATE PROCEDURE p2 AS  
    UPDATE db3..t3  
    SET c1 = c1 + 1;  
GO  
SELECT OBJECT_NAME (referencing_id),referenced_database_name,   
    referenced_schema_name, referenced_entity_name  
FROM sys.sql_expression_dependencies  
WHERE referenced_database_name IS NOT NULL; 



GO  
USE master;  
GO  
DROP DATABASE db1;  
GO  
  