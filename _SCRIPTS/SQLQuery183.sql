USE [OpsReporting];  
GO  
--Create two temporary principals  
CREATE LOGIN login1 WITH PASSWORD = 'J345#$)thb';  
CREATE LOGIN login2 WITH PASSWORD = 'Uor80$23b';  
GO  
CREATE USER user1 FOR LOGIN login1;  
CREATE USER user2 FOR LOGIN login2;  
GO  


CREATE LOGIN mhuman WITH PASSWORD = 'Uor80$23b'
CREATE USER mhuman FOR LOGIN mhuman

--Give IMPERSONATE permissions on user2 to user1  
--so that user1 can successfully set the execution context to user2.  
GRANT IMPERSONATE ON USER:: [THARISA\mhuman] TO [THARISA\efraser];  
GO  


--Display current execution context.  
SELECT SUSER_NAME(), USER_NAME();  

-- Set the execution context to login1.   
EXECUTE AS LOGIN = 'THARISA\mhuman'  
--Verify the execution context is now login1.  
SELECT SUSER_NAME(), USER_NAME();  

select db_name()
USE AdventureWorks2017
GO 



EXECUTE AS LOGIN = 'mhuman'  
GO

SELECT SUSER_NAME(), USER_NAME();  
GO

CREATE VIEW dbo.vw_test
AS
	SELECT 'marceltest' AS MarcelTest
GO

SELECT * FROM dbo.vw_test
GO 

DROP VIEW dbo.vw_test
GO

--Login1 sets the execution context to login2.  
EXECUTE AS USER = 'user2';  
EXECUTE AS USER  ='user1' 

SELECT SUSER_NAME(), USER_NAME();  




-- The execution context stack now has three principals: the originating caller, login1 and login2.  
--The following REVERT statements will reset the execution context to the previous context.  
REVERT;  
--Display current execution context.  
SELECT SUSER_NAME(), USER_NAME();  
REVERT;  
--Display current execution context.  
SELECT SUSER_NAME(), USER_NAME();  
  
--Remove temporary principals.  
DROP LOGIN login1;  
DROP LOGIN login2;  
DROP USER user1;  
DROP USER user2;  
GO 

USE [OpsReporting]
GRANT CREATE VIEW TO [THARISA\mhuman] 
GO