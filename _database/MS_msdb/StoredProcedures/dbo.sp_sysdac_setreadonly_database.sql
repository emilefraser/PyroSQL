SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysdac_setreadonly_database]  
        @database_name sysname,
        @readonly bit = 0
AS  
SET NOCOUNT ON;
BEGIN  
    DECLARE @sqlstatement nvarchar(1000)
    
    DECLARE @quoted_database_name nvarchar(258)   
    SET @quoted_database_name = QUOTENAME(@database_name)
    
    IF (@readonly = 0)
        SET @sqlstatement = 'ALTER DATABASE ' + @quoted_database_name + ' SET READ_ONLY WITH ROLLBACK IMMEDIATE'
    ELSE IF (@readonly = 1)
        SET @sqlstatement = 'ALTER DATABASE ' + @quoted_database_name + ' SET READ_WRITE WITH ROLLBACK IMMEDIATE'    

    EXEC (@sqlstatement)
            
    RETURN(@@error)
END

GO
