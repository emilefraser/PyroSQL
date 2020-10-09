SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysdac_is_login_creator]()
RETURNS int
BEGIN
    DECLARE @engineEdition int = CAST(SERVERPROPERTY('EngineEdition') AS int);
    DECLARE @islogincreator int;

    -- Check the engine edition
    IF (@engineEdition = 5)
    BEGIN
        -- Windows Azure SQL Database:
        --   is member of loginmanager or is superuser.

        SET @islogincreator = COALESCE(IS_MEMBER('loginmanager'), 0) | 
            dbo.fn_sysdac_is_currentuser_sa()

    END ELSE
    BEGIN
        -- Standalone, default:
        --   has ALTER ANY LOGIN permision

        SET @islogincreator = HAS_PERMS_BY_NAME(null, null, 'ALTER ANY LOGIN')
        
    END

    RETURN @islogincreator;
END

GO
