SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [DC].[sp_UpdateModellingToReadFromViewsNotTables]
@DatabaseName varchar(50)
AS
--SELECT distinct de.DataEntityName , fd.FieldName ,fd.FieldID, de2.DataEntityName ,de2.FieldName,de2.FieldID,lffk.ForeignKeyFieldID,lfpk.PrimaryKeyFieldID,pkfkl.LinkName
--FROM dc.vw_rpt_databasefielddetail fd 
--inner join 
--	(SELECT DataEntityID,DataEntityName 
--	 FROM dc.DataEntity 
--	 WHERE DataEntityTypeID = 2) 
--	 de  ON
--		de.DataEntityID = fd.DataEntityID
--INNER JOIN 
--	(SELECT distinct de1.DataEntityName,fd1.FieldName,fd1.FieldID 
--	 FROM dc.vw_rpt_databasefielddetail fd1 
--			INNER JOIN DC.DataEntity de1 ON 
--				de1.DataEntityID = fd1.DataEntityID 
--	 WHERE fd1.databasename = 'DEV_ODS_D365' 
--		AND de1.DataEntityTypeID is null) 
--		de2 ON 
--			'vw_DMOD_'+de2.DataEntityName = de.DataEntityName
--				AND de2.FieldName = fd.FieldName
--LEFT JOIN DMOD.PKFKLinkField lfpk ON
--	de2.FieldID = lfpk.PrimaryKeyFieldID
--LEFT JOIN DMOD.PKFKLinkField lffk ON
--	de2.FieldID = lffk.ForeignKeyFieldID
--INNER JOIN DMOD.PKFKLink pkfkl ON
--pkfkl.PKFKLinkID = lffk.PKFKLinkID
--WHERE fd.databasename = 'DEV_ODS_D365'
--AND (lffk.ForeignKeyFieldID is not null or lfpk.PrimaryKeyFieldID is not null)
--order by ForeignKeyFieldID asc

/*----------------------------------------------------------------------------------------------------------------------------------------------------
Count the differences in the views and tables
*/----------------------------------------------------------------------------------------------------------------------------------------------------
--Count PKFKLink Out of Sink

DECLARE @PKFKLinkCount int = 
(SELECT COUNT(1)
 FROM DMOD.PKFKLinkField lf
 LEFT join DC.vw_rpt_DatabaseFieldDetail fd ON
 fd.FieldID = lf.PrimaryKeyFieldID
 LEFT join (SELECT de.DataEntityID,DataEntityName,f.FieldID,f.FieldName
			FROM DC.DataEntity de
			inner join DC.Field f ON
				f.DataEntityID = de.DataEntityID
			inner join DC.[Schema] s ON
				s.SchemaID = de.SchemaID
			INNER JOIN DC.[Database] db ON
				db.DatabaseID = s.DatabaseID
			WHERE DataEntityTypeID = (SELECT DataEntityTypeID FROM DC.DataEntityType WHERE DataEntityTypeCode = 'SrcV')
				AND DatabaseName = @DatabaseName
			) detid ON
				detid.DataEntityName = 'vw_dmod_'+fd.DataEntityName	
					AND detid.FieldName = fd.FieldName
 WHERE fd.DatabaseName = @DatabaseName
 AND fd.SchemaName = 'DV'
 AND lf.IsActive = 1
 AND detid.FieldID is null --This tells us that the view is missing a column that was modelled in the DV table 
 )

DECLARE @PKFKLinkCount1 int = 
(SELECT COUNT(1)
FROM DMOD.PKFKLinkField lf
LEFT join DC.vw_rpt_DatabaseFieldDetail fd ON
fd.FieldID = lf.ForeignKeyFieldID
LEFT join (SELECT de.DataEntityID,DataEntityName,f.FieldID,f.FieldName
			FROM DC.DataEntity de
			inner join DC.Field f ON
				f.DataEntityID = de.DataEntityID
			inner join DC.[Schema] s ON
				s.SchemaID = de.SchemaID
			INNER JOIN DC.[Database] db ON
				db.DatabaseID = s.DatabaseID
			WHERE DataEntityTypeID = (SELECT DataEntityTypeID FROM DC.DataEntityType WHERE DataEntityTypeCode = 'SrcV')
				AND DatabaseName = @DatabaseName
			) detid ON
				detid.DataEntityName = 'vw_dmod_'+fd.DataEntityName	
					AND detid.FieldName = fd.FieldName
WHERE fd.DatabaseName = @DatabaseName
AND fd.SchemaName = 'DV'
AND lf.IsActive = 1
AND detid.FieldID IS NULL)

--Count SatelliteFieldID Out of Sink
DECLARE @SatelliteFieldCount int = 
(SELECT COUNT(1)
FROM DMOD.SatelliteField lf
LEFT join DC.vw_rpt_DatabaseFieldDetail fd ON
fd.FieldID = lf.FieldID
LEFT join (SELECT de.DataEntityID,DataEntityName,f.FieldID,f.FieldName
			FROM DC.DataEntity de
			inner join DC.Field f ON
				f.DataEntityID = de.DataEntityID
			inner join DC.[Schema] s ON
				s.SchemaID = de.SchemaID
			INNER JOIN DC.[Database] db ON
				db.DatabaseID = s.DatabaseID
			WHERE DataEntityTypeID = (SELECT DataEntityTypeID FROM DC.DataEntityType WHERE DataEntityTypeCode = 'SrcV')
				AND DatabaseName = @DatabaseName
			) detid ON
				detid.DataEntityName = 'vw_dmod_'+fd.DataEntityName	
					AND detid.FieldName = fd.FieldName
WHERE fd.DatabaseName = @DatabaseName
AND fd.SchemaName = 'DV'
AND lf.IsActive = 1
AND detid.FieldID IS NULL)

--Count HubBusinessKeyField Out of Sink
DECLARE @HubBKCount int = 
(SELECT COUNT(1)
FROM DMOD.HubBusinessKeyField lf
LEFT join DC.vw_rpt_DatabaseFieldDetail fd ON
fd.FieldID = lf.FieldID
LEFT join (SELECT de.DataEntityID,DataEntityName,f.FieldID,f.FieldName
			FROM DC.DataEntity de
			inner join DC.Field f ON
				f.DataEntityID = de.DataEntityID
			inner join DC.[Schema] s ON
				s.SchemaID = de.SchemaID
			INNER JOIN DC.[Database] db ON
				db.DatabaseID = s.DatabaseID
			WHERE DataEntityTypeID = (SELECT DataEntityTypeID FROM DC.DataEntityType WHERE DataEntityTypeCode = 'SrcV')
				AND DatabaseName = @DatabaseName
			) detid ON
				detid.DataEntityName = 'vw_dmod_'+fd.DataEntityName	
					AND detid.FieldName = fd.FieldName
WHERE fd.DatabaseName = @DatabaseName
AND fd.SchemaName = 'DV'
AND lf.IsActive = 1
AND detid.FieldID IS NULL)

/*----------------------------------------------------------------------------------------------------------------------------------------------------
Return errors if views and tables are out of sink
*/----------------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CountAll int = @PKFKLinkCount + @PKFKLinkCount1 + @SatelliteFieldCount + @HubBKCount

IF @PKFKLinkCount >0 OR @PKFKLinkCount1 > 0
BEGIN 
PRINT 'The PKFKLink views and tables are not in sync' 
END
IF @SatelliteFieldCount >0 
BEGIN 
PRINT 'The Satellite views and tables are not in sync' 
END
IF @HubBKCount >0 
BEGIN 
PRINT 'The BusinessKeyField views and tables are not in sync' 
END
/*----------------------------------------------------------------------------------------------------------------------------------------------------
Change the model from tables to views if they are all in sync
*/----------------------------------------------------------------------------------------------------------------------------------------------------

IF @CountAll = 0
BEGIN
--Update PKFKLink Primary Keys
UPDATE lf
SET PrimaryKeyFieldID = detid.FieldID
FROM DMOD.PKFKLinkField lf
LEFT join DC.vw_rpt_DatabaseFieldDetail fd ON
fd.FieldID = lf.PrimaryKeyFieldID
LEFT join (SELECT de.DataEntityID,DataEntityName,f.FieldID,f.FieldName
			FROM DC.DataEntity de
			inner join DC.Field f ON
				f.DataEntityID = de.DataEntityID
			inner join DC.[Schema] s ON
				s.SchemaID = de.SchemaID
			INNER JOIN DC.[Database] db ON
				db.DatabaseID = s.DatabaseID
			WHERE DataEntityTypeID = (SELECT DataEntityTypeID FROM DC.DataEntityType WHERE DataEntityTypeCode = 'SrcV')
				AND DatabaseName = @DatabaseName
			) detid ON
				detid.DataEntityName = 'vw_dmod_'+fd.DataEntityName	
					AND detid.FieldName = fd.FieldName
WHERE fd.DatabaseName = @DatabaseName
AND fd.SchemaName = 'DV'
AND fd.DataEntityName not like 'vw_dmod_%'
AND lf.IsActive = 1

--Update PKFKLink Foreign Keys
UPDATE lf
SET ForeignKeyFieldID = detid.FieldID
FROM DMOD.PKFKLinkField lf
LEFT join DC.vw_rpt_DatabaseFieldDetail fd ON
fd.FieldID = lf.ForeignKeyFieldID
LEFT join (SELECT de.DataEntityID,DataEntityName,f.FieldID,f.FieldName
			FROM DC.DataEntity de
			inner join DC.Field f ON
				f.DataEntityID = de.DataEntityID
			inner join DC.[Schema] s ON
				s.SchemaID = de.SchemaID
			INNER JOIN DC.[Database] db ON
				db.DatabaseID = s.DatabaseID
			WHERE DataEntityTypeID = (SELECT DataEntityTypeID FROM DC.DataEntityType WHERE DataEntityTypeCode = 'SrcV')
				AND DatabaseName = @DatabaseName
			) detid ON
				detid.DataEntityName = 'vw_dmod_'+fd.DataEntityName	
					AND detid.FieldName = fd.FieldName
WHERE fd.DatabaseName = @DatabaseName
AND fd.SchemaName = 'DV'
AND fd.DataEntityName not like 'vw_dmod_%'
AND lf.IsActive = 1

--Update HubBusinessKeyField FieldIDs
UPDATE lf
SET FieldID = detid.FieldID
FROM DMOD.HubBusinessKeyField lf
LEFT join DC.vw_rpt_DatabaseFieldDetail fd ON
fd.FieldID = lf.FieldID
LEFT join (SELECT de.DataEntityID,DataEntityName,f.FieldID,f.FieldName
			FROM DC.DataEntity de
			inner join DC.Field f ON
				f.DataEntityID = de.DataEntityID
			inner join DC.[Schema] s ON
				s.SchemaID = de.SchemaID
			INNER JOIN DC.[Database] db ON
				db.DatabaseID = s.DatabaseID
			WHERE DataEntityTypeID = (SELECT DataEntityTypeID FROM DC.DataEntityType WHERE DataEntityTypeCode = 'SrcV')
				AND DatabaseName = @DatabaseName
			) detid ON
				detid.DataEntityName = 'vw_dmod_'+fd.DataEntityName	
					AND detid.FieldName = fd.FieldName
WHERE fd.DatabaseName = @DatabaseName
AND fd.SchemaName = 'DV'
AND fd.DataEntityName not like 'vw_dmod_%'
AND lf.IsActive = 1

--Update SatelliteField FieldIDs
UPDATE lf
SET FieldID = detid.FieldID
--SELECT fd.DataEntityName,detid.DataEntityName,lf.FieldID,detid.FieldID,lf.SatelliteFieldID
FROM DMOD.SatelliteField lf
LEFT join DC.vw_rpt_DatabaseFieldDetail fd ON
fd.FieldID = lf.FieldID
LEFT join (SELECT de.DataEntityID,DataEntityName,f.FieldID,f.FieldName
			FROM DC.DataEntity de
			inner join DC.Field f ON
				f.DataEntityID = de.DataEntityID
			inner join DC.[Schema] s ON
				s.SchemaID = de.SchemaID
			INNER JOIN DC.[Database] db ON
				db.DatabaseID = s.DatabaseID
			WHERE DataEntityTypeID = (SELECT DataEntityTypeID FROM DC.DataEntityType WHERE DataEntityTypeCode = 'SrcV')
				AND DatabaseName = @DatabaseName
			) detid ON
				detid.DataEntityName = 'vw_dmod_'+fd.DataEntityName	
					AND detid.FieldName = fd.FieldName
WHERE fd.DatabaseName = @DatabaseName
AND fd.SchemaName = 'DV'
AND fd.DataEntityName not like 'vw_dmod_%'
AND lf.IsActive = 1


--SELECT  lf.FieldID FROM DMOD.SatelliteField lf
--inner join DC.vw_rpt_DatabaseFieldDetail fd
--ON fd.FieldID = lf.FieldID
--WHERE fd.DatabaseID = 4
--AND SchemaName = 'DV'
--AND Databasename = 'DEV_ODS_D365'
--AND DataEntityName like 'vw%'
--AND lf.Isactive = 1


END


DECLARE @PKFKLinkCountAfter int = 
	   (SELECT COUNT(1)
		FROM DMOD.PKFKLinkField lf
		LEFT JOIN DC.vw_rpt_DatabaseFieldDetail fd ON
		fd.FieldID = lf.PrimaryKeyFieldID
		LEFT JOIN (SELECT de.DataEntityID,DataEntityName,f.FieldID,f.FieldName
				FROM DC.DataEntity de
				inner JOIN DC.Field f ON
					f.DataEntityID = de.DataEntityID
				inner JOIN DC.[Schema] s ON
					s.SchemaID = de.SchemaID
				INNER JOIN DC.[Database] db ON
					db.DatabaseID = s.DatabaseID
				WHERE DataEntityTypeID = (SELECT DataEntityTypeID FROM DC.DataEntityType WHERE DataEntityTypeCode = 'SrcV')
					AND DatabaseName = @DatabaseName
				) detid ON
					detid.DataEntityName = 'vw_dmod_'+fd.DataEntityName	
						AND detid.FieldName = fd.FieldName
		WHERE fd.DatabaseName = @DatabaseName
		AND fd.SchemaName = 'DV'
		AND lf.IsActive = 1
		AND fd.DataEntityName not like 'vw_dmod%'
		)

DECLARE @PKFKLinkCountAfter1 int = 

(SELECT COUNT(1)
FROM DMOD.PKFKLinkField lf
LEFT join DC.vw_rpt_DatabaseFieldDetail fd ON
fd.FieldID = lf.ForeignKeyFieldID
LEFT join (SELECT de.DataEntityID,DataEntityName,f.FieldID,f.FieldName
			FROM DC.DataEntity de
			inner join DC.Field f ON
				f.DataEntityID = de.DataEntityID
			inner join DC.[Schema] s ON
				s.SchemaID = de.SchemaID
			INNER JOIN DC.[Database] db ON
				db.DatabaseID = s.DatabaseID
			WHERE DataEntityTypeID = (SELECT DataEntityTypeID FROM DC.DataEntityType WHERE DataEntityTypeCode = 'SrcV')
				AND DatabaseName = @DatabaseName
			) detid ON
				detid.DataEntityName = 'vw_dmod_'+fd.DataEntityName	
					AND detid.FieldName = fd.FieldName
WHERE fd.DatabaseName = @DatabaseName
AND fd.SchemaName = 'DV'
AND lf.IsActive = 1
AND fd.DataEntityName not like 'vw_dmod%'
)

--Count SatelliteFieldID Out of Sink
DECLARE @SatelliteFieldCountAfter int = 
(SELECT COUNT(1)
FROM DMOD.SatelliteField lf
LEFT join DC.vw_rpt_DatabaseFieldDetail fd ON
fd.FieldID = lf.FieldID
LEFT join (SELECT de.DataEntityID,DataEntityName,f.FieldID,f.FieldName
			FROM DC.DataEntity de
			inner join DC.Field f ON
				f.DataEntityID = de.DataEntityID
			inner join DC.[Schema] s ON
				s.SchemaID = de.SchemaID
			INNER JOIN DC.[Database] db ON
				db.DatabaseID = s.DatabaseID
			WHERE DataEntityTypeID = (SELECT DataEntityTypeID FROM DC.DataEntityType WHERE DataEntityTypeCode = 'SrcV')
				AND DatabaseName = @DatabaseName
			) detid ON
				detid.DataEntityName = 'vw_dmod_'+fd.DataEntityName	
					AND detid.FieldName = fd.FieldName
WHERE fd.DatabaseName = @DatabaseName
AND fd.SchemaName = 'DV'
AND lf.IsActive = 1
AND fd.DataEntityName not like 'vw_dmod%'
)

--Count HubBusinessKeyField Out of Sink
DECLARE @HubBKCountAfter int = 
(SELECT COUNT(1)
FROM DMOD.HubBusinessKeyField lf
LEFT join DC.vw_rpt_DatabaseFieldDetail fd ON
fd.FieldID = lf.FieldID
LEFT join (SELECT de.DataEntityID,DataEntityName,f.FieldID,f.FieldName
			FROM DC.DataEntity de
			inner join DC.Field f ON
				f.DataEntityID = de.DataEntityID
			inner join DC.[Schema] s ON
				s.SchemaID = de.SchemaID
			INNER JOIN DC.[Database] db ON
				db.DatabaseID = s.DatabaseID
			WHERE DataEntityTypeID = (SELECT DataEntityTypeID FROM DC.DataEntityType WHERE DataEntityTypeCode = 'SrcV')
				AND DatabaseName = @DatabaseName
			) detid ON
				detid.DataEntityName = 'vw_dmod_'+fd.DataEntityName	
					AND detid.FieldName = fd.FieldName
WHERE fd.DatabaseName = @DatabaseName
AND fd.SchemaName = 'DV'
AND lf.IsActive = 1
AND fd.DataEntityName not like 'vw_dmod%'
)

DECLARE @CountAllAfter int = @PKFKLinkCountAfter + @PKFKLinkCountAfter1 + @SatelliteFieldCountAfter + @HubBKCountAfter
IF @CountAllAfter > 0
BEGIN
PRINT 'Not all modelling entries in the selected database is reading from views'
END

GO
