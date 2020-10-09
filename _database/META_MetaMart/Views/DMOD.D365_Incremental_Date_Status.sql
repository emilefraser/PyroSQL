SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DMOD].[D365_Incremental_Date_Status] AS
select d.DataEntityName as HasCreated, j.DataEntityName as HasModified, J.DataEntityID from (
select de.DataEntityID, de.DataEntityName from dc.dataentity de
left join dc.field f
on f.DataEntityID = de.DataEntityID
left join dc.[Schema] s
on s.schemaid = de.schemaid
left join dc.[database] db
on db.databaseid = s.databaseid
where db.DatabaseName like 'ods_d365%'
and f.FieldName like 'CREATEDDATETIME1%'
) d

full outer join (

select de.DataEntityID, de.DataEntityName from dc.dataentity de
left join dc.field f
on f.DataEntityID = de.DataEntityID
left join dc.[Schema] s
on s.schemaid = de.schemaid
left join dc.[database] db
on db.databaseid = s.databaseid
where db.DatabaseName like 'ods_d365%'
and f.FieldName like 'MODIFIEDDATETIME1%'
) j
on j.DataEntityID = d.DataEntityID

GO
