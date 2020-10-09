SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [DMOD].[vw_rpt_LineageRowCount_RowCount_MissMatch_STAGE] AS
select 1 test/*
SELECT * FROM 
(
select distinct 
VaultTableName, 
VaultRowCount,
StageTableName,
StageRowCount,
ODSTableName,
ODSRowCount 
from [DC].[vw_rpt_LineageRowCount] 
where VaultTableName not like 'Link%'
union all
select distinct 
lrc.VaultTableName, 
lrc.VaultRowCount,
lrc.StageTableName,
lrc.StageRowCount,
lrc.ODSTableName,
lrc.ODSRowCount 
from [DC].[vw_rpt_LineageRowCount] lrc
where VaultTableName like 'Link%'
and 
lrc.StageTableName like '%'+ SUBSTRING(replace(lrc.VaultTableName,'LINK_',''), charindex('_', replace(lrc.VaultTableName,'LINK_',''))+1, LEN(replace(lrc.VaultTableName,'LINK_','')))+'%'
) K
WHERE-- VaultRowCount != ODSRowCount


StageRowCount != ODSRowCount
*/

GO
