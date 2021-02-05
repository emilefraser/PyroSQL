DECLARE @NonUniqueCount INT
DECLARE @sql VARCHAR(MAX)
DECLARE @sqlStatement NVARCHAR(MAX)
DECLARE @sqlValues NVARCHAR(MAX)
DECLARE @sqlParams NVARCHAR(MAX)

DECLARE @schemaID int = 4

SET @sqlStatement  = N'SET @NonUniqueCount = (SELECT COUNT(1) AS CNT FROM sys.objects AS o WHERE schema_id = @schemaID)'
SET @sqlParams = N'@schemaID INT, @NonUniqueCount INT OUTPUT'
EXEC sp_executeSQL @sqlStatement, @sqlParams, @schemaID = @schemaID, @NonUniqueCount = @NonUniqueCount output

SELECT @NonUniqueCount


--DECLARE @Parmdef nvarchar (500)
--DECLARE @SQL nvarchar (max)
--DECLARE @xTxt1  nvarchar (100) = 'test1'
--DECLARE @xTxt2  nvarchar (500) = 'test2' 
--SET @parmdef = '@text1 nvarchar (100), @text2 nvarchar (500)'
--SET @SQL = 'PRINT @text1 + '' '' + @text2'
--EXEC sp_executeSQL @SQL, @Parmdef, @xTxt1, @xTxt2