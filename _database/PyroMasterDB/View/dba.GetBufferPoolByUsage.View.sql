SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dba].[GetBufferPoolByUsage]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dba].[GetBufferPoolByUsage]
AS

SELECT 
	ISNULL(CASE bd.database_id 
		WHEN 32767 THEN ''resource'' 
		ELSE db.name END, ''TOTAL'') as database_name,
	count(*) * 8./1024./1024. as page_GB,
	sum(free_space_in_bytes) /1024./1024./1024. as free_space_MB
FROM sys.dm_os_buffer_descriptors as bd
LEFT OUTER JOIN sys.databases as db on bd.database_id = db.database_id
GROUP BY 
	CASE bd.database_id WHEN 32767 THEN ''resource'' ELSE db.name END
WITH ROLLUP

' 
GO
