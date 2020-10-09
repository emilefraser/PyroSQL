SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DMOD].[vw_rpt_validate_Incremental_Date_Status] AS

select
	COALESCE(d.DatabaseName, J.DatabaseName) As DatabaseName
	, COALESCE(d.SchemaName, J.SchemaName) As SchemaName
	, d.DataEntityName as HasCreated
	, j.DataEntityName as HasModified
	, COALESCE(d.DataEntityID, J.DataEntityID) AS DataEntityID
from
	(
	select
		db.DatabaseName 
		, s.SchemaName 
		, de.DataEntityID
		, de.DataEntityName 
	from
		dc.dataentity de
			left join dc.field f
				on f.DataEntityID = de.DataEntityID
			left join dc.[Schema] s
				on s.schemaid = de.schemaid
			left join dc.[database] db
				on db.databaseid = s.databaseid
	where
		f.FieldName like 'CREATEDDATETIME1%'
	) d

full outer join
	
	(
	select
		db.DatabaseName 
		, s.SchemaName 
		, de.DataEntityID
		, de.DataEntityName
	from
		dc.dataentity de
			left join dc.field f
				on f.DataEntityID = de.DataEntityID
			left join dc.[Schema] s
				on s.schemaid = de.schemaid
			left join dc.[database] db
				on db.databaseid = s.databaseid
	where
		f.FieldName like 'MODIFIEDDATETIME1%'
	) j
	on j.DataEntityID = d.DataEntityID

GO
