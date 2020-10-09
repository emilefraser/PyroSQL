SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
	SELECT [dbo].[udf_get_TableRowCounts]('LoadType', 'DMOD')
	SELECT [dbo].[udf_get_TableRowCounts]('[LoadType]', '[DMOD]')
	SELECT [dbo].[udf_get_TableRowCounts]('LoadType', 'DMOD', 'DataManager', DEFAULT)


*/

CREATE    FUNCTION [dbo].[udf_get_TableRowCounts]
(
    @TableName SYSNAME
,	@SchemaName SYSNAME
,	@DatabaseName SYSNAME = NULL
,	@ServerName SYSNAME = NULL
)
RETURNS INT
AS
BEGIN
	
	DECLARE @sql NVARCHAR(MAX)
	DECLARE @ReturnRows INT = 0

	-- ServerName Standardization
	IF (@ServerName IS NULL)
	BEGIN
		SET @ServerName = ''
	END
	ELSE
	BEGIN
		SET @ServerName = QUOTENAME(PARSENAME(@ServerName, 1)) + '.'
	END

	-- Standardized DatabaseName
	IF (@DatabaseName IS NULL)
	BEGIN
		SET @DatabaseName = ''
	END
	ELSE
	BEGIN
		SET @DatabaseName = QUOTENAME(PARSENAME(@DatabaseName, 1)) + '.'
	END

	-- Has to Supply SchemaName
	IF (@SchemaName IS NULL)
	BEGIN
		RETURN -1
	END
	ELSE
	BEGIN
		SET @SchemaName = QUOTENAME(PARSENAME(@SchemaName, 1)) + '.'
	END

	-- Has to Supply TableName
	IF (@TableName IS NULL)
	BEGIN
		RETURN -1
	END
	ELSE
	BEGIN
		SET @TableName = QUOTENAME(PARSENAME(@TableName, 1))
	END

	-- Preps select statement assigning it to @ReturnRows
	SET @sql = 'SELECT @ReturnRows = COUNT(1) FROM ' 
					+ CONVERT(VARCHAR, @ServerName) 
					+ CONVERT(VARCHAR, @DatabaseName) 
					+ CONVERT(VARCHAR, @SchemaName) 
					+ CONVERT(VARCHAR, @TableName)

	EXEC sp_executesql @sql, N'@ReturnRows INT OUT', @ReturnRows OUT

	RETURN @ReturnRows

END

GO
