Example to Identify Object Dependencies

Advertisement

Let us go through an example to understand how the SQL Server 2008 database engine tracks object dependencies.

Use the below T-SQL script to create a table named Employee.

Use SampleDB
GO
/* Create Employee Table */
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Employee]') AND type in (N'U'))
DROP TABLE [dbo].[Employee]
GO
CREATE TABLE [dbo].[Employee]
(
[Emp_ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
[Last_Name] [nvarchar](50) NULL,
[First_Name] [nvarchar](50) NULL,
[Age] [int] NULL,
)
GO

--Execute the below T-SQL script to create usp_GetEmployeeName stored procedure. This procedure refers to Employee table which was created using the above script.

/* Create Stored Procedure "usp_GetEmployeeName" to return Employee Name */
CREATE PROCEDURE dbo.usp_GetEmployeeName
AS
BEGIN
SELECT Last_Name + ' ' + First_Name AS EmployeeName
FROM dbo.Employee 
END
GO
Now that we have a sample table and stored procedure setup, the following queries can be used to find the referenced and referencing information.

Execute the below scripts which queries "sys.dm_sql_referencing_entities" dynamic management function to find out all objects which are referencing to "Employee" table.

Advertisement

/* Find all object which are referencing to "Employee" table */
SELECT 
referencing_schema_name +'.'+ referencing_entity_name AS ReferencedEntityName,
referencing_class_desc AS ReferencingEntityDescription 
FROM sys.dm_sql_referencing_entities ('dbo.Employee', 'OBJECT');
GO
Execute the below scripts which queries "sys.dm_sql_referenced_entities" dynamic management function to find out all objects which are referenced to "usp_GetEmployeeName" stored procedure.

/* Find all object which are referenced by "usp_GetEmployeeName" stored procedure */
SELECT 
referenced_schema_name +'.'+ referenced_entity_name AS ReferencedEntityName, 
referenced_minor_name AS ReferencedMinorName
FROM sys.dm_sql_referenced_entities ('dbo.usp_GetEmployeeName', 'OBJECT');
GO
Execute the below scripts which queries "sys.sql_expression_dependencies" system view to find out all the objects which are referenced by "usp_GetEmployeeName" stored procedure.

 /* Identifying Object Dependencies */
SELECT 
SCHEMA_NAME(O.SCHEMA_ID) +'.'+ o.name AS ReferencingObject, 
SED.referenced_schema_name +'.'+SED.referenced_entity_name AS ReferencedObject
FROM sys.all_objects O INNER JOIN sys.sql_expression_dependencies SED 
ON O.OBJECT_ID=SED.REFERENCING_ID 
WHERE O.name = 'usp_GetEmployeeName'