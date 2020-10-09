SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Emile Fraser
-- Create Date: 16 Oct 2018
-- Description: Returns a field list from the Data Catalog for an INSERT or		`
-- =============================================
-- Sample Execution: SELECT DC.[udf_FieldListForCreateTable](191)
--SELECT * FROM DC.DataEntity

-- SELECT DC.[udf_FieldListForCreateTable](9619)


CREATE FUNCTION [DC].[udf_get_TableSpaceAndRows]
(
    @DatabaseName varchar(50)
	,@SchemaName varchar(50)
    ,@DataEntityName varchar(50)
)

RETURNS VARCHAR(MAX)
AS
BEGIN
DECLARE @SQL varchar(max) 
SET @SQL = 
'SELECT 
    t.NAME AS TableName,
    p.rows AS RowCounts,
    SUM(a.used_pages) * 8 AS UsedSpaceKB
FROM 
    '+@DatabaseName+'.sys.tables t --SET DATABASE
INNER JOIN      
    '+@DatabaseName+'.sys.indexes i ON t.OBJECT_ID = i.object_id --SET DATABASE
INNER JOIN 
    '+@DatabaseName+'.sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id --SET DATABASE
INNER JOIN 
    '+@DatabaseName+'.sys.allocation_units a ON p.partition_id = a.container_id --SET DATABASE
LEFT OUTER JOIN 
    '+@DatabaseName+'.sys.schemas s ON t.schema_id = s.schema_id --SET DATABASE
WHERE 
    t.NAME = '''+@DataEntityName+''' --SET DATAENTITY
   AND s.NAME = '''+@SchemaName+''' --SET SCHEMA
   AND i.index_id < 2
   AND a.type = 1
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    t.Name
'
RETURN @SQL
END




GO
