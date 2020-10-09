SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [DC].[vw_rpt_DistinctDataEntityDetail]
AS
SELECT        db.DatabaseID, db.DatabaseName, serv.ServerName, serv.ServerLocationID, SL.ServerLocationCode, SL.ServerLocationName, 
                SL.IsCloudLocation, dbinst.DatabaseInstanceID, 
                         CASE WHEN dbinst.IsDefaultInstance = 1 THEN 'Default' ELSE dbinst.DatabaseInstanceName END AS DatabaseInstanceName, s.SchemaID, 
                         s.SchemaName, s.DBSchemaID, de.DataEntityID, de.DataEntityName, de.DBObjectID,
                          de.IsActive AS IsActive_DE, de.CreatedDT AS DataEntity_CreatedDT, db.DatabasePurposeID, DBP.DatabasePurposeCode, DBP.DatabasePurposeName, db.IsActive, db.SystemID, de.FriendlyName, de.Description,
    
                        de.FriendlyName AS [Friendly Name],
                        de.DataEntityTypeID AS [Data Entity Type ID],
                        de.RowsCount AS [Rows Count],
                        de.ColumnsCount AS [Columns Count],
                        de.Size AS [Size],
                        de.DataQualityScore2 AS [Data Quality Score 2],
                        de.DataQualityScore AS [Data Quality Score],
                        de.SchemaID AS [Schema ID],
                        de.CreatedDT AS [Created Date],
                        de.UpdatedDT AS [Updated Date],
                        de.LastSeenDT AS [Last Seen Date Time],
                        DET.DataEntityTypeName AS [Data Entity Type Name]
                    

 

FROM            DC.[Database] AS db LEFT OUTER JOIN
                         DC.DatabaseInstance AS dbinst ON dbinst.DatabaseInstanceID = db.DatabaseInstanceID LEFT OUTER JOIN
                         DC.Server AS serv ON serv.ServerID = dbinst.ServerID LEFT OUTER JOIN
                         DC.[Schema] AS s ON s.DatabaseID = db.DatabaseID LEFT OUTER JOIN
                         DC.DataEntity AS de ON de.SchemaID = s.SchemaID LEFT OUTER JOIN
                         DC.DatabasePurpose AS DBP ON DBP.DatabasePurposeID = DB.DatabasePurposeID LEFT JOIN 
                         [DC].[DataEntityType] AS DET ON de.DataEntityTypeID = DET.DataEntityTypeID LEFT OUTER JOIN
                         DC.ServerLocation SL ON SL.ServerLocationID = serv.ServerLocationID


GO
