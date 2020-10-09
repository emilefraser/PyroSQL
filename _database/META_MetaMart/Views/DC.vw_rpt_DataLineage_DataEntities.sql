SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*

select	*
from	DC.vw_rpt_DataLineage_DataEntities
where	Target_DataEntityID = 90

*/

CREATE VIEW [DC].[vw_rpt_DataLineage_DataEntities] AS

select	distinct 
		  desource.ServerName			as Source_ServerName
		, desource.DatabaseInstanceName	as Source_DatabaseInstanceName
		, desource.DatabaseName			as Source_DatabaseName
		, desource.SchemaName			as Source_SchemaName
		, desource.DataEntityID			as Source_DataEntityID
		, desource.DataEntityName		as Source_DataEntity
		
		, detarget.ServerName			as Target_ServerName
		, detarget.DatabaseInstanceName as Target_DatabaseInstanceName
		, detarget.DatabaseName			as Target_DatabaseName
		, detarget.SchemaName			as Target_SchemaName
		, detarget.DataEntityID			as Target_DataEntityID
		, detarget.DataEntityName		as Target_DataEntity
from	
		(
			select	serversource.ServerName
					, ISNULL(dbisource.DatabaseInstanceName, 'Default') DatabaseInstanceName
					, dbsource.DatabaseName
					, schemasource.SchemaName
					, desource.DataEntityID, desource.DataEntityName
					, frsource.FieldRelationID
			from	DC.FieldRelation frsource
				inner join DC.Field fsource on frsource.SourceFieldID = fsource.FieldID
				inner join DC.DataEntity desource on desource.DataEntityID = fsource.DataEntityID
				inner join DC.[Schema] schemasource on schemasource.SchemaID = desource.SchemaID
				inner join DC.[Database] dbsource on dbsource.DatabaseID = schemasource.DatabaseID
				inner join DC.DatabaseInstance dbisource on dbisource.DatabaseInstanceID = dbsource.DatabaseInstanceID
				inner join DC.[Server] serversource on serversource.ServerID = dbisource.ServerID
			where	frsource.FieldRelationTypeID = 2
		) desource
	inner join 
		(
			select	servertarget.ServerName
					, ISNULL(dbitarget.DatabaseInstanceName, 'Default') DatabaseInstanceName
					, dbtarget.DatabaseName
					, schematarget.SchemaName
					, detarget.DataEntityID, detarget.DataEntityName
					, frtarget.FieldRelationID
			from	DC.FieldRelation frtarget
				inner join DC.Field ftarget on frtarget.TargetFieldID = ftarget.FieldID
				inner join DC.DataEntity detarget on detarget.DataEntityID = ftarget.DataEntityID
				inner join DC.[Schema] schematarget on schematarget.SchemaID = detarget.SchemaID
				inner join DC.[Database] dbtarget on dbtarget.DatabaseID = schematarget.DatabaseID
				inner join DC.DatabaseInstance dbitarget on dbitarget.DatabaseInstanceID = dbtarget.DatabaseInstanceID
				inner join DC.[Server] servertarget on servertarget.ServerID = dbitarget.ServerID
			where	frtarget.FieldRelationTypeID = 2
		) detarget 
		ON desource.FieldRelationID = detarget.FieldRelationID;

GO
