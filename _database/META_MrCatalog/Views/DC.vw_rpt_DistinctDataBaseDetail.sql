SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DC].[vw_rpt_DistinctDataBaseDetail]
AS
SELECT        db.DatabaseID, db.DatabaseName, serv.ServerName, serv.ServerLocation, dbinst.DatabaseInstanceID, 
                         CASE WHEN dbinst.IsDefaultInstance = 1 THEN 'Default' ELSE dbinst.DatabaseInstanceName END AS DatabaseInstanceName, db.IsActive, db.DatabasePurposeID, db.SystemID
FROM            DC.[Database] AS db RIGHT OUTER JOIN
                         DC.DatabaseInstance AS dbinst ON dbinst.DatabaseInstanceID = db.DatabaseInstanceID LEFT OUTER JOIN
                         DC.Server AS serv ON serv.ServerID = dbinst.ServerID

GO
