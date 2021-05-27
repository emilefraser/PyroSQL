SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_SpacePerTable]'))
EXEC dbo.sp_executesql @statement = N'/*
	SELECT * FROM [meta].[Metadata_SpacePerTable]
*/
CREATE   VIEW [meta].[Metadata_SpacePerTable]
AS
select schema_name(tab.schema_id) + ''.'' + tab.name as [table], 
    cast(sum(spc.used_pages * 8)/1024.00 as numeric(36, 2)) as used_mb,
    cast(sum(spc.total_pages * 8)/1024.00 as numeric(36, 2)) as allocated_mb
from sys.tables tab
    inner join sys.indexes ind 
        on tab.object_id = ind.object_id
    inner join sys.partitions part 
        on ind.object_id = part.object_id and ind.index_id = part.index_id
    inner join sys.allocation_units spc
        on part.partition_id = spc.container_id
group by schema_name(tab.schema_id) + ''.'' + tab.name;
' 
GO
