SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



--exec [DC].[sp_Validate_Hubs_Links_Sats_Dont_HAVE_loadconfig] 37
CREATE PROCEDURE  [DC].[sp_Validate_Hubs_Links_Sats_Dont_HAVE_loadconfig]
@DatabaseEnvironmentTypeID int
AS
-- Brings back Hubs that do not have a load config for itself 
select distinct h.HubName, 
de.DataEntityName
, lc.LoadConfigID 
from dmod.hub h
left join dc.DataEntity de
on de.DataEntityName = h.HubName
inner join dmod.LoadConfig lc
on lc.TargetDataEntityID = de.DataEntityID
left join dc.[schema] s
on s.SchemaID = de.SchemaID
left join dc.[Database] db
on db.DatabaseID = s.DatabaseID
where  lc.LoadConfigID IS NULL
and h.IsActive = 1
and db.DatabaseEnvironmentTypeID = @DatabaseEnvironmentTypeID


-- Brings back satellites that do not have a load config for itself 
select distinct s.SatelliteName, 
de.DataEntityName
, lc.LoadConfigID 
from dmod.Satellite s
left join dc.DataEntity de
on de.DataEntityName = s.SatelliteName
LEFT join dmod.LoadConfig lc
on lc.TargetDataEntityID = de.DataEntityID
left join dc.[schema] s1
on s1.SchemaID = de.SchemaID
left join dc.[Database] db
on db.DatabaseID = s1.DatabaseID


where  lc.LoadConfigID IS NULL
and s.IsActive = 1
and db.DatabaseEnvironmentTypeID = @DatabaseEnvironmentTypeID


-- Brings back Links that do not have a load config for itself 
select distinct l.LinkName, 
de.DataEntityName
, lc.LoadConfigID 
from dmod.PKFKLink l
left join dc.DataEntity de
on de.DataEntityName = l.LinkName
inner join dmod.LoadConfig lc
on lc.TargetDataEntityID = de.DataEntityID
left join dc.[schema] s
on s.SchemaID = de.SchemaID
left join dc.[Database] db
on db.DatabaseID = s.DatabaseID
where  lc.LoadConfigID IS NULL
and l.IsActive = 1
and db.DatabaseEnvironmentTypeID = @DatabaseEnvironmentTypeID




GO
