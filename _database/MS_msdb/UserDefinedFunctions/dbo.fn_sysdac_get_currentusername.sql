SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysdac_get_currentusername]()
RETURNS sysname
BEGIN
    DECLARE @engineEdition int;
    DECLARE @current_user_name sysname;

    SET @engineEdition = CAST(SERVERPROPERTY('EngineEdition') AS int);

    IF (@engineEdition = 5)
    BEGIN 
        --Windows Azure SQL Database does not have SUSER_SNAME. We need to look in sql_logins to get the user name.
        SELECT @current_user_name = dbo.fn_sysdac_get_username(SUSER_SID()) 
    END ELSE
    BEGIN
        --OnPremise engine has both sql and windows logins - We rely on SUSER_SNAME to find the current user name.
        SELECT @current_user_name = SUSER_SNAME()
    END

    RETURN @current_user_name;
END

GO
