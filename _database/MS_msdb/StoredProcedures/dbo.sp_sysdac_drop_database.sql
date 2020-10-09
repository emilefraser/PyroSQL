SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysdac_drop_database]  
        @database_name sysname
AS  
SET NOCOUNT ON;
BEGIN  
    IF EXISTS(SELECT name FROM sys.databases WHERE name = @database_name)
    BEGIN
        DECLARE @engineEdition int = CAST(SERVERPROPERTY('EngineEdition') AS int);
        
        DECLARE @quoteddbname nvarchar(258)
        SET @quoteddbname = QUOTENAME(@database_name)
        
        DECLARE @sqlstatement nvarchar(1000)
        
        IF (@engineEdition != 5)
        BEGIN
            SET @sqlstatement = 'ALTER DATABASE ' + @quoteddbname + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE'
            EXEC (@sqlstatement)
        END 
        
        SET @sqlstatement = 'DROP DATABASE ' + @quoteddbname
        
        IF (@engineEdition = 5)
        BEGIN
			DECLARE @dbname SYSNAME 
			SET @dbname = db_name()
			
            RAISERROR (36012, 0, 1, @dbname, @sqlstatement);
            SELECT @dbname as databasename, @sqlstatement as sqlscript
        END
        ELSE
        BEGIN
            EXEC (@sqlstatement)
        END    
    END
    
    RETURN(@@error)
END

GO
