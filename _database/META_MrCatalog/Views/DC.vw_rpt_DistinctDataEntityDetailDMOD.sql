SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create view [DC].[vw_rpt_DistinctDataEntityDetailDMOD]
as
(
SELECT        db.DatabaseID, db.DatabaseName, serv.ServerName, serv.ServerLocation, dbinst.DatabaseInstanceID, 
                         CASE WHEN dbinst.IsDefaultInstance = 1 THEN 'Default' ELSE dbinst.DatabaseInstanceName END AS DatabaseInstanceName, s.SchemaID, s.SchemaName, s.DBSchemaID, de.DataEntityID, de.DataEntityName, de.DBObjectID,
                          de.IsActive AS IsActive_DE, de.CreatedDT AS DataEntity_CreatedDT, db.IsActive, db.SystemID, sn.SystemName
FROM            DC.[Database] AS db LEFT OUTER JOIN
                         DC.DatabaseInstance AS dbinst ON dbinst.DatabaseInstanceID = db.DatabaseInstanceID LEFT OUTER JOIN
                         DC.Server AS serv ON serv.ServerID = dbinst.ServerID LEFT OUTER JOIN
                         DC.[Schema] AS s ON s.DatabaseID = db.DatabaseID LEFT OUTER JOIN
                         DC.DataEntity AS de ON de.SchemaID = s.SchemaID LEFT OUTER JOIN
						 DC.[System] AS sn ON db.SystemID = sn.SystemID

						)

GO
