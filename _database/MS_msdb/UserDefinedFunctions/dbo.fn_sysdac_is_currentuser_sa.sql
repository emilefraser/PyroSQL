SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysdac_is_currentuser_sa]()
RETURNS int
BEGIN
    DECLARE @engineEdition int = CAST(SERVERPROPERTY('EngineEdition') AS int);
    DECLARE @is_sa int;
    
    -- Check the engine edition
    IF (@engineEdition = 5)
    BEGIN
        -- Windows Azure SQL Database:
    --   SID matches with the reserved offset.
        -- NOTE: We should get an inbuilt user function from Azure team instead of us querying based on SID.    
        SET @is_sa = 0
    
        IF((CONVERT(varchar(85), suser_sid(), 2) LIKE '0106000000000164%'))
            SET @is_sa = 1
            
    END ELSE
    BEGIN
        -- Standalone, default:
        --   is member of the serverrole 'sysadmin'
        SET @is_sa = COALESCE(is_srvrolemember('sysadmin'), 0)
    
    END
   
    RETURN @is_sa;
END

GO
