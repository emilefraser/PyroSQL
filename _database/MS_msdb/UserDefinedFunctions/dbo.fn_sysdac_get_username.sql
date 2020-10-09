SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysdac_get_username](@user_sid varbinary(85))
RETURNS sysname
WITH EXECUTE AS OWNER
BEGIN	
    DECLARE @engineEdition int = CAST(SERVERPROPERTY('EngineEdition') AS int);
    DECLARE @current_user_name sysname;

    IF (@engineEdition = 5)
    BEGIN 
        --Windows Azure SQL Database does not have syslogins. All the logins reside in sql_logins
        SELECT @current_user_name = name FROM sys.sql_logins where sid = @user_sid 
    END ELSE
    BEGIN
        --OnPremise engine has both sql and windows logins in syslogins
        SELECT @current_user_name = name FROM sys.syslogins where sid = @user_sid 
    END

    RETURN @current_user_name;
END

GO
