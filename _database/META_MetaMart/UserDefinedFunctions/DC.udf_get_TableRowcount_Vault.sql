SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [DC].[udf_get_TableRowcount_Vault] (
	@SchemaName	nvarchar(100)
	, @TableName	nvarchar(100))  
RETURNS int
BEGIN
	DECLARE
		  @Counts		int
		, @sql			nvarchar(max)

SELECT @Counts = SUM(PART.rows)
FROM (SELECT t.[object_id], t.[name], s.[name] as SchemaName, t.schema_id FROM [DataVault].sys.tables t INNER JOIN [DataVault].sys.schemas s ON t.schema_id = s.schema_id WHERE t.[type] = 'U') AS TBL
INNER JOIN [DataVault].sys.partitions AS PART	ON TBL.object_id = PART.object_id 
INNER JOIN [DataVault].sys.indexes AS IDX		ON PART.object_id = IDX.object_id AND PART.index_id = IDX.index_id 
WHERE IDX.index_id < 2 AND TBL.SchemaName = @SchemaName AND TBL.[name] = @TableName
GROUP BY TBL.SchemaName, TBL.[name]

RETURN @Counts

END


GO
