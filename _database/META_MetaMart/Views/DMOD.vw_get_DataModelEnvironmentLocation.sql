SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_get_DataModelEnvironmentLocation]
AS

--Show the SUM of Hub Business Keys mapped to the related source/ODS db
SELECT hub.HubName,
	   dc.DatabaseName AS DataModelSourceDatabase,
	   [type].DetailTypeDescription AS DatabaseEnvironmentType,
	   COUNT(1) AS BusinessKeyFieldMappingCount
  FROM DMOD.HubBusinessKeyField hub_bkf
	   INNER JOIN DMOD.HubBusinessKey hub_bk ON
			hub_bk.HubBusinessKeyID = hub_bkf.HubBusinessKeyID
	   INNER JOIN DMOD.Hub hub ON
			hub.HubID = hub_bk.HubID
	   INNER JOIN DC.vw_rpt_DatabaseFieldDetail dc ON
			dc.FieldID = hub_bkf.FieldID
	   INNER JOIN DC.[Database] db ON
			db.DatabaseID = dc.DatabaseID
	   INNER JOIN [TYPE].Generic_Detail [type] ON
			[type].DetailID = db.DatabaseEnvironmentTypeID
	
GROUP BY
	   hub.HubName,
	   dc.DatabaseName,
	   [type].DetailTypeDescription

GO
