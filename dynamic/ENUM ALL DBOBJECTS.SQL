- Return objects count in all databases on the server
-- Dynamic SQL stored procedure - SQL quotename used to build valid db object names
USE AdventureWorks;
GO
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = Object_id(N'[dbo].[sprocObjectCountsAllDBs]')
                  AND TYPE IN (N'P',N'PC'))
  DROP PROCEDURE [dbo].[sprocObjectCountsAllDBs]
GO
CREATE PROC sprocObjectCountsAllDBs
AS
  BEGIN
    DECLARE  @dbName      SYSNAME,
             @ObjectCount INT
    DECLARE  @SQL NVARCHAR(MAX)
    DECLARE  @DBObjectStats  TABLE(
                                   DBName    SYSNAME,
                                   DBObjects INT
                                   )
    DECLARE curAllDBs CURSOR  FOR
    SELECT   name
    FROM     MASTER.dbo.sysdatabases
    WHERE    name NOT IN ('master','tempdb','model','msdb')
    ORDER BY name
    OPEN curAllDBs
    FETCH  curAllDBs
    INTO @dbName
  
    WHILE (@@FETCH_STATUS = 0) -- loop through all db-s
      BEGIN
        -- Build valid yet hard-wired SQL statement
        -- SQL QUOTENAME is used for valid identifier formation
        SET @SQL = 'select @dbObjects = count(*)' + Char(13) + 'from ' + Quotename(@dbName)+ '.dbo.sysobjects'
        
        PRINT @SQL -- Use it for debugging
        
        -- Dynamic SQL call with output parameter(s)
        EXEC Sp_executesql
          @SQL ,
          N'@dbObjects int output' ,
          @dbObjects = @ObjectCount OUTPUT
        
        INSERT @DBObjectStats
        SELECT @dbName,  @ObjectCount
        
        FETCH  curAllDBs INTO @dbName
      END -- while
    CLOSE curAllDBs
    DEALLOCATE curAllDBs
    -- Return results
    SELECT *
    FROM   @DBObjectStats
  END
GO
 
-- Execute stored procedure with dynamic SQL
EXEC sprocObjectCountsAllDBs
GO