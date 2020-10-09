SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_Validate_PKFKLinksWithDifferentDatabases]
AS

--Author : Francois Senekal

SELECT l.LinkName
	  ,fdprimarykey.DatabaseName AS PKDatabaseName
	  ,fdprimarykey.DataEntityName AS PKDataEntityName
	  ,fdprimarykey.FieldID AS PKFieldID
	  ,fdprimarykey.FieldName AS PKFieldName
	  ,fdforeignkey.DatabaseName  AS FKDatabaseName
	  ,fdforeignkey.DataEntityName AS FKDataEntityName
	  ,fdforeignkey.FieldID AS FKFieldID
	  ,fdforeignkey.FieldName AS FKFieldName
	  ,'These Links do not have the same Databases' AS ValidationMessage

FROM dmod.PKFKLinkField lf
	INNER JOIN DMOD.PKFKLink l ON
		l.PKFKLinkID = lf.PKFKLinkID 
	INNER JOIN DC.vw_rpt_DatabaseFieldDetail fdprimarykey ON
		fdprimarykey.FieldID = lf.PrimaryKeyFieldID
	INNER JOIN DC.vw_rpt_DatabaseFieldDetail fdforeignkey ON
		fdforeignkey.FieldID = lf.ForeignKeyFieldID
WHERE fdprimarykey.DatabaseName != fdforeignkey.DatabaseName
AND l.IsActive = 1
AND lf.IsActive = 1

GO
