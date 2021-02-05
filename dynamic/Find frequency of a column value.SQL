-----------
-- Find frequency of a column value (800) in all tables with column ProductID
------------
DECLARE @DynamicSQL nvarchar(MAX) = '',  @ProductID int = '800'; 
DECLARE @ColumnName sysname = N'ProductID', @Parms nvarchar(32) = N'@pProductID int';
SELECT @DynamicSQL = @DynamicSQL +
       CASE WHEN LEN(@DynamicSQL) <> 0 THEN char(13)+'UNION ALL' ELSE '' END +
       ' SELECT '''+ t.TABLE_SCHEMA+'.'+ t.TABLE_NAME +
       ''' AS TableName, Frequency=COUNT(*) FROM ' +
       QUOTENAME(t.TABLE_SCHEMA) +'.' + QUOTENAME(t.TABLE_NAME) +
       ' WHERE CONVERT(INT, ' + QUOTENAME(c.COLUMN_NAME) + ') = @pProductID'
FROM [AdventureWorks2008].[INFORMATION_SCHEMA].[TABLES] t
  INNER JOIN [AdventureWorks2008].[INFORMATION_SCHEMA].[COLUMNS] c
    ON  t.TABLE_SCHEMA = c.TABLE_SCHEMA
      AND t.TABLE_NAME = c.TABLE_NAME
WHERE TABLE_TYPE='BASE TABLE'
  AND c.COLUMN_NAME = @ColumnName;
SET @DynamicSQL = @DynamicSQL + N' ORDER BY Frequency DESC;';
PRINT @DynamicSQL;
EXEC sp_executeSQL @DynamicSQL, @Parms, @pProductID = @ProductID;
/*    TableName                           Frequency
      Sales.SalesOrderDetail              495
      Production.TransactionHistory       418             ....*/