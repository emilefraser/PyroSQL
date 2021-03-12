USE [OpsReporting];  
GO  
--Create two temporary principals  
CREATE LOGIN login1 WITH PASSWORD = 'J345#$)thb';  
CREATE LOGIN login2 WITH PASSWORD = 'Uor80$23b';  
GO  
CREATE USER user1 FOR LOGIN login1;  
CREATE USER user2 FOR LOGIN login2;  
GO  


--Give IMPERSONATE permissions on user2 to user1  
--so that user1 can successfully set the execution context to user2.  
GRANT IMPERSONATE ON USER:: user2 TO user1;  
GO  


--Display current execution context.  
SELECT SUSER_NAME(), USER_NAME();  

-- Set the execution context to login1.   
EXECUTE AS LOGIN = 'login1';  
--Verify the execution context is now login1.  
SELECT SUSER_NAME(), USER_NAME();  

--Login1 sets the execution context to login2.  
EXECUTE AS USER = 'user2';  
--Display current execution context.  
SELECT SUSER_NAME(), USER_NAME();  

SELECT 'login' AS token_type,* FROM sys.login_token AS LT
UNION ALL
SELECT 'user' AS token_type,* FROM sys.user_token AS UT;
GO


-- The execution context stack now has three principals: the originating caller, login1 and login2.  
--The following REVERT statements will reset the execution context to the previous context.  
REVERT;  
--Display current execution context.  
SELECT SUSER_NAME(), USER_NAME();  
REVERT;  
--Display current execution context.  
SELECT SUSER_NAME(), USER_NAME();  
  
--Remove temporary principals.  
DROP LOGIN [THARISA\mhuman];  
DROP LOGIN login2;  
DROP USER  [THARISA\mhuman];    
DROP USER user2;  
GO 

select
permission_name, 
state_desc,
object_name(major_id) as securable,
user_name(grantor_principal_id) as grantor
from sys.database_permissions
where grantee_principal_id = user_id('THARISA\mhuman')


select
*
from sys.database_permissions
where grantee_principal_id = user_id('THARISA\mhuman')

SELECT s.name
FROM sys.schemas s
WHERE s.principal_id = USER_ID('THARISA\mhuman');



setuser 'THARISA\MHuman'
go
SELECT SUSER_NAME(), USER_NAME(); 

SELECT * FROM OccupationMappings


CREATE VIEW dbo.vw_test
AS
	SELECT 'marceltest' AS MarcelTest
GO

DROP VIEW dbo.vw_test


setuser

Use OpsReporting
GRANT CREATE ANY VIEW TO [THARISA\mhuman]

--Display current execution context.  
SELECT SUSER_NAME(), USER_NAME();  

SELECT     DBPRINCIPAL_1.NAME AS ROLE, DBPRINCIPAL_1.NAME AS OWNER
FROM         SYS.DATABASE_PRINCIPALS AS DBPRINCIPAL_1 I

NNER JOIN
                 SYS.DATABASE_PRINCIPALS AS DBPRINCIPAL_2 
		    ON DBPRINCIPAL_1.PRINCIPAL_ID = DBPRINCIPAL_2.OWNING_PRINCIPAL_ID
WHERE     (DBPRINCIPAL_1.NAME = 'THARISA\mhuman' ) 

EXECUTE AS LOGIN = 'THARISA\mhuman'  
GO

CREATE VIEW dbo.vw_test
AS
	SELECT 'marceltest' AS MarcelTest
GO

DROP VIEW dbo.vw_test

SELECT * FROM fn_my_permissions(NULL, 'SERVER');  
GO  
B. Listing effective permissions on the database
The following example returns a list of the effective permissions of the caller on the AdventureWorks2012 database.



USE OpsReporting;  
SELECT * FROM fn_my_permissions (NULL, 'DATABASE');  
GO  


EXECUTE AS USER = 'THARISA\mhuman' 
SELECT * FROM fn_my_permissions (NULL, 'DATABASE');  
    ORDER BY subentity_name, permission_name ;    
REVERT;  
GO  


SELECT        
USER_NAME(dppriper.grantee_principal_id) AS UserName, 
sppri.is_disabled, 
dppri.type_desc AS principal_type_desc, 
dppriper.class_desc, 
OBJECT_NAME(dppriper.major_id) AS object_name, 
dppriper.permission_name, 
dppriper.state_desc AS permission_state_desc
FROM            
sys.database_permissions AS dppriper INNER JOIN
sys.database_principals AS dppri 
ON dppriper.grantee_principal_id = dppri.principal_id LEFT OUTER JOIN
sys.server_principals AS sppri 
ON sppri.sid = dppri.sid 
Where USER_NAME(dppriper.grantee_principal_id)= 'THARISA\mhuman' 

C. Listing effective permissions on a view
The following example returns a list of the effective permissions of the caller on the vIndividualCustomer view in the Sales schema of the AdventureWorks2012 database.


Copy
USE AdventureWorks2012;  
SELECT * FROM fn_my_permissions('Sales.vIndividualCustomer', 'OBJECT')   
    ORDER BY subentity_name, permission_name ;   






SELECT        
USER_NAME(dppriper.grantee_principal_id) AS UserName, 
sppri.is_disabled, 
dppri.type_desc AS principal_type_desc, 
dppriper.class_desc, 
OBJECT_NAME(dppriper.major_id) AS object_name, 
dppriper.permission_name, 
dppriper.state_desc AS permission_state_desc

select *
FROM            
sys.database_permissions AS dppriper INNER JOIN
sys.database_principals AS dppri 
ON dppriper.grantee_principal_id = dppri.principal_id LEFT OUTER JOIN
sys.server_principals AS sppri 
ON sppri.sid = dppri.sid 
Where USER_NAME(dppriper.grantee_principal_id)= 'THARISA\MHuman' 


SELECT SUSER_NAME(), USER_NAME()
GO

USE [OpsReporting]
GRANT CREATE VIEW TO mhuman
GRANT CREATE PROCEDURE TO mhuman
GRANT ALTER ON SCHEMA::[dbo] TO mhuman

GRANT ALTER ON SCHEMA :: dbo TO mhuman

SETUSER 'THARISA\MHuman'
GO

SELECT SUSER_NAME(), USER_NAME()
GO

CREATE VIEW dbo.vw_test
AS
	SELECT *
	FROM [OpsReporting].XT.OccupationMappings
GO

DROP VIEW dbo.vw_test
GO

SETUSER
GO

SELECT SUSER_NAME(), USER_NAME()
GO


 SELECT 'login' AS token_type,* FROM sys.login_token AS LT
UNION ALL
SELECT 'user' AS token_type,* FROM sys.user_token AS UT;