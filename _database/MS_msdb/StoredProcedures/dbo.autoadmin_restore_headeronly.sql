SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE autoadmin_restore_headeronly    
	@backupFile NVARCHAR(260),
	@credName SYSNAME,
	@blocksize INT = 65536
AS    
BEGIN    
    -- Validations    
    IF(@backupFile IS NULL)    
    BEGIN    
        RAISERROR ('@backupFile cannot be NULL', -- Message text    
           17, -- Severity,    
           1); -- State    
        RETURN    
    END    
     
    IF(@credName IS NULL)    
    BEGIN    
        RAISERROR ('@credName cannot be NULL', -- Message text    
           17, -- Severity,    
           1); -- State    
        RETURN    
    END    
     
 DECLARE @restore_sql  NVARCHAR(MAX);    
    
    -- Check if we are using SAS based credentials    
    IF EXISTS ( SELECT name FROM sys.credentials    
        WHERE name = @credName     
        AND  credential_identity = 'Shared Access Signature')    
    BEGIN    
        -- for SAS based credentials, it is not required to specify credential name in restore statement    
        SET @restore_sql = 'RESTORE HEADERONLY FROM URL = @backupFile WITH BLOCKSIZE = @blocksize'    
  EXEC sp_executesql @restore_sql, N'@backupFile NVARCHAR(260),  @blocksize INT', @backupFile, @blocksize    
    END    
    ELSE    
    BEGIN    
        -- Backup to Url - requires credential name to be specificed in RESTORE statement    
        SET @restore_sql = 'RESTORE HEADERONLY FROM URL = @backupFile WITH CREDENTIAL = @@credName, BLOCKSIZE = @@blocksize'    
  EXEC sp_executesql @restore_sql, N'@backupFile NVARCHAR(260), @@credName SYSNAME, @@blocksize INT', @backupFile, @credName, @blocksize    
    END    
    
    RETURN    
END    

GO
