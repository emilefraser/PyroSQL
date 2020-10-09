SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON








/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [DMOD].[vw_SourceTables_to_LoadConfig_Validation] as 



select db.DatabaseName+'.'+s.SchemaName+'.'+de2.DataEntityName as SourceDataEntityName ,j.DataEntityID as SourceDataEntityID,  lc.SourceDataEntityID as SourceDEIDFromLoadConfig ,lc.LoadConfigID
from dmod.LoadConfig lc
full outer join (
select --k.f1,f.FieldID,
 distinct f.DataEntityID
from  (
select FieldID as f1 from dmod.HubBusinessKeyField
where IsActive =1
union all
select FieldID from dmod.SatelliteField
where IsActive =1
union all
select PrimaryKeyFieldID from dmod.PKFKLinkField
where IsActive =1
union all
select ForeignKeyFieldID from dmod.PKFKLinkField
where IsActive =1
) k
left join dc.Field f
on f.FieldID = k.f1) j
on j.DataEntityID = lc.SourceDataEntityID
left join dmod.LoadConfig lc2
on lc.SourceDataEntityID = lc2.TargetDataEntityID
left join dc.DataEntity de2
on de2.DataEntityID = j.DataEntityID
left join dc.[Schema] s
on s.SchemaID = de2.SchemaID
left join dc.[Database] db
on db.databaseid = s.databaseid
WHERE LC2.TargetDataEntityID IS NULL


GO
