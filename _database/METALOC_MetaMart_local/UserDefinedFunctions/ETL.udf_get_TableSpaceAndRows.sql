SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Emile Fraser
-- Create Date: 16 Oct 2018
-- Description: Returns a field list from the Data Catalog for an INSERT or		`
-- =============================================
-- Sample Execution: SELECT [ETL].[udf_get_TableSpaceAndRows]('[ODS_EMS]', '[dbo]', '[sales_header_order]')
--SELECT * FROM DC.DataEntity

CREATE FUNCTION [ETL].[udf_get_TableSpaceAndRows]
(
    @DatabaseName SYSNAME
,	@SchemaName SYSNAME
,	@DataEntityName varchar(50)
)

RETURNS VARCHAR(MAX)
AS
BEGIN

DECLARE @sql VARCHAR(MAX) 

-- Removes unneccesary []
SET @SchemaName = PARSENAME(@SchemaName, 1)
SET @DataEntityName = PARSENAME(@DataEntityName, 1)

SET @SQL = 
'SELECT 
    t.name AS TableName,
    p.rows AS RowCounts,
    SUM(a.used_pages) * 8 AS UsedSpaceKB
FROM 
    '+ @DatabaseName +'.sys.tables t
INNER JOIN      
    '+ @DatabaseName +'.sys.indexes i 
	ON t.OBJECT_ID = i.object_id
INNER JOIN 
    '+ @DatabaseName +'.sys.partitions p 
	ON i.object_id = p.OBJECT_ID 
	AND i.index_id = p.index_id
INNER JOIN 
    '+ @DatabaseName +'.sys.allocation_units a 
	ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    '+ @DatabaseName +'.sys.schemas s 
	ON t.schema_id = s.schema_id
WHERE 
    t.name = '''+ @DataEntityName +'''
    AND s.name = '''+ @SchemaName +'''
GROUP BY 
    t.name
,	s.name
,	p.rows
'
RETURN @SQL
END


GO
