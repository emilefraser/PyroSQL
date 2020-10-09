SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DC].[vw_rpt_DistinctDataBaseDetailODS]
AS
	SELECT        db.DatabaseID, db.DatabaseName, serv.ServerName, dbinst.DatabaseInstanceID, 
                         CASE WHEN dbinst.IsDefaultInstance = 1 THEN 'Default' ELSE dbinst.DatabaseInstanceName END AS DatabaseInstanceName, db.IsActive, db.DatabasePurposeID, db.SystemID
	FROM            DC.[Database] AS db RIGHT OUTER JOIN
                         DC.DatabaseInstance AS dbinst ON dbinst.DatabaseInstanceID = db.DatabaseInstanceID LEFT OUTER JOIN
                         DC.Server AS serv ON serv.ServerID = dbinst.ServerID
	WHERE		db.DatabasePurposeID = (SELECT TOP(1) DataBasePurposeID FROM DC.DatabasePurpose WHERE DatabasePurposeCode like '%ODS%')

GO