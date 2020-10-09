SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysdac_rename_database]  
        @database_name sysname,
        @new_name sysname
AS  
SET NOCOUNT ON;
BEGIN  
    DECLARE @sqlstatement nvarchar(1000)

    -- Alter the database to single user mode    
    DECLARE @quoted_database_name nvarchar(258)
    SET @quoted_database_name = QUOTENAME(@database_name)
    SET @sqlstatement = 'ALTER DATABASE ' + @quoted_database_name + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE'
    EXEC (@sqlstatement)

    -- Rename the database
    EXEC sp_rename @objname=@quoted_database_name, @newname=@new_name, @objtype='DATABASE'

    -- Revert the database back to multi user mode
    DECLARE @quoted_new_name nvarchar(258)
    SET @quoted_new_name = QUOTENAME(@new_name)
    SET @sqlstatement = 'ALTER DATABASE ' + @quoted_new_name + ' SET MULTI_USER WITH ROLLBACK IMMEDIATE'
    EXEC (@sqlstatement)
            
    RETURN(@@error)
END

GO
