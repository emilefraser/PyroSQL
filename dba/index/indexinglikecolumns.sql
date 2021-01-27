/* 

Script for creating indexes of a certain type when multiple tables are involved (the more tables, the more useful if one rule can be applied).

*/

-- 1. Find all the tables and information of a certain type that need to be indexed
/*

SELECT 'IX_' + COLUMN_NAME AS [IndexName]
  , TABLE_SCHEMA AS [SchemaName]
  , TABLE_NAME AS [TableName]
  , COLUMN_NAME AS [ColumnName]
FROM   
  INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE LIKE 'date%'  -- Use this for the SELECT statement in the INSERT below this

*/


-- 2. Insert those into the variable table for creating indexes

DECLARE @CreateIndex TABLE(
	IndexID INT IDENTITY(1,1),
	IndexName VARCHAR(100),
	SchemaName VARCHAR(50),
	TableName VARCHAR(100),
	ColumnName VARCHAR(100)
)

INSERT INTO @CreateIndex (IndexName,SchemaName,TableName,ColumnName)
SELECT 'IX_' + COLUMN_NAME AS [IndexName]
	, TABLE_SCHEMA AS [SchemaName]
	, TABLE_NAME AS [TableName]
	, COLUMN_NAME AS [ColumnName]
FROM   
  INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE LIKE 'date%' -- Change this to match the above SELECT


-- 3. A loop will build indexes on columns matching the definition defined above this
DECLARE @begin INT = 1
DECLARE @max INT
SELECT @max = MAX(IndexID) FROM @CreateIndex
DECLARE @IndexName VARCHAR(100), @SchemaName VARCHAR(50), @TableName VARCHAR(100), @ColumnName VARCHAR(100)

WHILE @begin <= @max
BEGIN

	SELECT @IndexName = IndexName FROM @CreateIndex WHERE IndexID = @begin
	SELECT @SchemaName = SchemaName FROM @CreateIndex WHERE IndexID = @begin
	SELECT @TableName = TableName FROM @CreateIndex WHERE IndexID = @begin
	SELECT @ColumnName = ColumnName FROM @CreateIndex WHERE IndexID = @begin
	
	SELECT @IndexName, @SchemaName, @TableName, @ColumnName
	
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'BEGIN TRAN
	CREATE NONCLUSTERED INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + ']
	(
		' + @ColumnName + ' ASC
	)WITH (STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	IF @@ERROR <> 0
	BEGIN
		SELECT @@ERROR
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		COMMIT TRAN
	END'

	EXECUTE(@sql)
	
	PRINT 'Index created on ' + @TableName
	
	SET @begin = @begin + 1
	
END
