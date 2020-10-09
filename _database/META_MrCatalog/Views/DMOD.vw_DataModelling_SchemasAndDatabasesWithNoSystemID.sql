SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_DataModelling_SchemasAndDatabasesWithNoSystemID] 
AS 
SELECT DISTINCT serv.ServerID AS ServerID
			   ,serv.ServerName AS ServerName
               ,dbi.DatabaseInstanceID AS DatabaseInstanceID
			   ,dbi.DatabaseInstanceName AS DatabaseInstanceName
			   ,db.DatabaseID AS DatabaseID
			   ,db.DatabaseName AS DatabaseName
			   ,db.SystemID AS DatabaseSystemID
			   ,s.SchemaID AS SchemaID
			   ,s.SchemaName AS SchemaName
			   ,s.SystemID AS SchemaSystemID
FROM DC.[Schema] s
INNER JOIN DC.[Database] db ON
db.DatabaseID = s.DatabaseID
LEFT JOIN DC.DatabaseInstance dbi ON
dbi.DatabaseInstanceID = db.DatabaseInstanceID
LEFT JOIN DC.[Server] serv ON 
serv.ServerID = dbi.ServerID
WHERE s.SystemID IS NULL 
AND db.SystemID IS NULL



GO
