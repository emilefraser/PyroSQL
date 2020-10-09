SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create view [DC].[vw_rpt_DatabaseFieldDetailDMOD]
as
(
SELECT        db.DatabaseID, db.DatabaseName, serv.ServerName, serv.ServerLocation, dbinst.DatabaseInstanceID, 
                         CASE WHEN dbinst.IsDefaultInstance = 1 THEN 'Default' ELSE dbinst.DatabaseInstanceName END AS DatabaseInstanceName, system.SystemAbbreviation, system.SystemName, s.SchemaID, s.SchemaName, s.DBSchemaID, 
                         de.DataEntityID, de.DataEntityName, de.DBObjectID, de.IsActive AS IsActive_DE, de.CreatedDT AS DataEntity_CreatedDT, f.FieldID, f.FieldName, f.DBColumnID, f.DataType, f.MaxLength, f.Precision, f.Scale, f.IsPrimaryKey, 
                         f.IsForeignKey, f.FieldSortOrder, db.IsActive
FROM            DC.[Database] AS db LEFT OUTER JOIN
                         DC.DatabaseInstance AS dbinst ON dbinst.DatabaseInstanceID = db.DatabaseInstanceID LEFT OUTER JOIN
                         DC.Server AS serv ON serv.ServerID = dbinst.ServerID LEFT OUTER JOIN
                         DC.System AS system ON system.SystemID = db.SystemID LEFT OUTER JOIN
                         DC.[Schema] AS s ON s.DatabaseID = db.DatabaseID LEFT OUTER JOIN
                         DC.DataEntity AS de ON de.SchemaID = s.SchemaID LEFT OUTER JOIN
                         DC.Field AS f ON f.DataEntityID = de.DataEntityID
)

GO
