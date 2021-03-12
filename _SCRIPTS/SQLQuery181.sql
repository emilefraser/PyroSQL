EXECUTE AS


CREATE LOGIN TestLogin1 WITH PASSWORD='********', CHECK_POLICY = OFF;
CREATE LOGIN TestLogin2 WITH PASSWORD='********', CHECK_POLICY = OFF;
CREATE USER TestUser1 FOR LOGIN TestLogin1;
CREATE USER TestUser2 FOR LOGIN TestLogin2;


--Now, to be le to execute the EXECUTE AS statement, you need to have impersonation permission on the account you want to switch to.
-- So we need to grant that permission:

GRANT IMPERSONATE ON LOGIN::TestLogin2 TO TestLogin1;

--As any grant or deny of server level permissions, this statement needs to be executed in master.

--Now that we have the permissions out of the way, let's try the EXECUTE AS statement. Login to SQL Server using the TestLogin1 login and then execute this statement block:

SELECT 'login' AS token_type,* FROM sys.login_token AS LT
UNION ALL
SELECT 'user' AS token_type,* FROM sys.user_token AS UT;
GO

EXECUTE AS LOGIN='TestLogin2';
GO
SELECT 'login' AS token_type,* FROM sys.login_token AS LT
UNION ALL
SELECT 'user' AS token_type,* FROM sys.user_token AS UT;



--I introduced the two DMVs sys.login_token and sys.user_token yesterday in The Secret of the Security Token.


[sql]
GO
REVERT;
GO
SELECT 'login' AS token_type,* FROM sys.login_token AS LT
UNION ALL
SELECT 'user' AS token_type,* FROM sys.user_token AS UT;
[/sql]