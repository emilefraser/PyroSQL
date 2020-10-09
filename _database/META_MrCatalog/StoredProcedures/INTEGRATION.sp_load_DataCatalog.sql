SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 6 Oct 2018
-- Description: Loads the data catalog tables from the INTEGRATION table.
-- =============================================
CREATE PROCEDURE [INTEGRATION].[sp_load_DataCatalog]
AS

/*========================================================================
********************************************************
-Update DBDatabaseID if it changed or if it is null 
********************************************************
Test Case:

Change a DBDatabaseID to Null and run this update statement
1. Pick a sepcific entry in the DC.Database that is NB: currently in the INTEGRATION.ingress_DataCatalog :
		SELECT * 
		FROM Dc.[Database]  
		WHERE DatabaseID = 136
2. Change the DBDatabaseID to 999/NULL
		UPDATE DC.[Database] 
		SET DBDatabaseID = 999 --(or NULL to check if NULL updates)
		WHERE DataBaseID = 136
3. Check if change happened
		SELECT * 
		FROM DC.[Database]  
		WHERE DatabaseID = 136
3. Run the Update statement below
4. Check if it updated back to DataBaseID = 136
		SELECT * 
		FROM DC.[Database]  
		WHERE DatabaseID = 136
							SUCCESS!
========================================================================*/
UPDATE d
SET  DBDatabaseID = idc.DatabaseID,
	 UpdatedDT = GETDATE()
FROM DC.[Database] d
	 INNER JOIN (SELECT DISTINCT DCDatabaseInstanceID, 
								DatabaseID, 
								DatabaseName 
				FROM [INTEGRATION].[ingress_DataCatalog]
				) idc ON
				  idc.DCDatabaseInstanceID = d.DatabaseInstanceID 
				  AND
				  idc.DatabaseName = d.DatabaseName
 WHERE DBDatabaseID != idc.DatabaseID
    OR DBDatabaseID != idc.DatabaseID

 /*========================================================================
********************************************************
Update Database name (renamed database)
********************************************************
1. Pick a sepcific entry in the DC.Database that is NB: currently in the INTEGRATION.ingress_DataCatalog :
		SELECT * 
		FROM DC.[Database]  
		WHERE DatabaseID = 136
2. Change the DatabaseName
		UPDATE DC.[Database]  
		SET DatabaseName = 'TestRename'
		WHERE DataBaseID = 136
3. Check if change happened
		SELECT * 
		FROM DC.[Database]  
		WHERE DatabaseID = 136
3. Run the Update statement below
4. Check if it updated back to DataBaseID = 136
		SELECT * 
		FROM DC.[Database]  
		WHERE DatabaseID = 136
							SUCCESS!
========================================================================*/

--KD 2019/09/10: Removed because DatabaseName should never be updated based on a possibly changing DBDatabaseID (DBDatabaseID is not reliable enough to do this).
--UPDATE d
--SET  DatabaseName = idc.DatabaseName,
--	 UpdatedDT = GETDATE()
--FROM DC.[Database] d
--	   INNER JOIN (	SELECT DISTINCT DCDatabaseInstanceID, 
--									DatabaseID,
--									DatabaseName 
--					FROM [INTEGRATION].[ingress_DataCatalog]
--				   ) idc ON
--					 idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
--					 idc.DatabaseID = d.DBDatabaseID
--WHERE d.DatabaseName != idc.DatabaseName


  /*========================================================================
Update LastSeenDT for database - for all DB's crawled
========================================================================*/
UPDATE d
SET  d.LastSeenDT = GETDATE(),
	 --Set the UpdatedDT only if it was inactive and now we're making it active
	 d.UpdatedDT = CASE WHEN d.IsActive = 0 THEN GETDATE() ELSE d.UpdatedDT END,
	 d.IsActive = 1
FROM DC.[Database]  d
	   INNER JOIN (	SELECT DISTINCT DCDatabaseInstanceID, 
									DatabaseName 
					FROM [INTEGRATION].[ingress_DataCatalog]
				   ) idc ON
					 idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
					 idc.DatabaseName = d.DatabaseName

  /*========================================================================
Insert new Database/s
========================================================================*/
INSERT INTO DC.[Database]  (DatabaseName,
						   DatabaseInstanceID,
						   DBDatabaseID,
						   CreatedDT,
						   LastSeenDT,
						   IsActive
						   )
SELECT DISTINCT idc.DatabaseName,
				idc.DCDatabaseInstanceID,
				idc.DatabaseID,
				GETDATE(),
				GETDATE(),
				1
FROM [INTEGRATION].[ingress_DataCatalog] idc
WHERE NOT EXISTS (SELECT 1
				  FROM DC.[Database]  d
				  WHERE d.DatabaseInstanceID = idc.DCDatabaseInstanceID AND
						 d.DatabaseName = idc.DatabaseName --KD 2019/09/10: Updated from Database Object ID.
				  )
  /*========================================================================
********************************************************
Update Schema details - missing SchemaID
********************************************************
Test case:
1. Find a DBSchemaID that is NB: currently in the INTEGRATION.ingress_DataCatalog :
		SELECT * 
		FROM   DC.[Schema]  
		WHERE  SchemaID = 261
2. Change the DBSchemaID 
		UPDATE DC.[Schema]  
		SET DBSchemaID = NULL
		WHERE  SchemaID = 261
3.Check the change
		SELECT * 
		FROM   DC.[Schema]  
		WHERE  SchemaID = 261
4.Run the Update statement below
5.Check if it was returned to DBSchemaID = 1
		SELECT * 
		FROM   DC.[Schema]  
		WHERE  SchemaID = 261
							!SUCCESS!
========================================================================*/
UPDATE s
SET  DBSchemaID = idc.SchemaID,
	 UpdatedDT = GETDATE()
FROM DC.[Schema]  s
	 INNER JOIN DC.[Database]  d ON
				d.DatabaseID = s.DatabaseID
	 INNER JOIN (SELECT DISTINCT DCDatabaseInstanceID,
								 DatabaseName, 
								 SchemaName,
								 SchemaID
				 FROM [INTEGRATION].[ingress_DataCatalog]
				  )  idc ON
					 idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
					 idc.DatabaseName = d.DatabaseName AND
					 idc.SchemaName = s.SchemaName
 WHERE s.DBSchemaID IS NULL OR
	   s.DBSchemaID != idc.SchemaID
	   
  /*========================================================================
Update LastSeenDT for Schema
========================================================================*/
UPDATE s
SET  s.LastSeenDT = GETDATE(),
	 --Set the UpdatedDT only if it was inactive and now we're making it active
	 s.UpdatedDT = CASE WHEN s.IsActive = 0 THEN GETDATE() ELSE s.UpdatedDT END,
	 s.IsActive = 1
FROM DC.[Schema]  s
	 INNER JOIN DC.[Database]  d ON
				d.DatabaseID = s.DatabaseID
	 INNER JOIN (SELECT DISTINCT DCDatabaseInstanceID,
								 DatabaseName, 
								 SchemaName 
				 FROM [INTEGRATION].[ingress_DataCatalog]
				  )  idc ON
					 idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
					 idc.DatabaseName = d.DatabaseName AND
					 idc.SchemaName = s.SchemaName
  /*========================================================================
********************************************************
Insert new Schema/s
********************************************************
This has been tested : Don not delete entries
========================================================================*/
INSERT INTO DC.[Schema]  (SchemaName,
						 DatabaseID,
						 DBSchemaID,
						 CreatedDT,
						 LastSeenDT,
						 IsActive
					     )
SELECT DISTINCT idc.SchemaName,
				d.DatabaseID,
				idc.SchemaID,
				GETDATE(),
				GETDATE(),
				1
FROM [INTEGRATION].[ingress_DataCatalog] idc
	 INNER JOIN DC.[Database] d ON
				d.DatabaseInstanceID = idc.DCDatabaseInstanceID AND
				d.DatabaseName = idc.DatabaseName
WHERE NOT EXISTS
			    (SELECT 1
			     FROM DC.[Schema]  s
			     WHERE	s.SchemaName = idc.SchemaName AND
			    		s.DatabaseID = d.DatabaseID --AND
			    		--s.DBSchemaID = idc.SchemaID --KD 2019/09/10
			    ) AND
idc.SchemaID IS NOT NULL --A database can have no schemas in the Ingress table

/*========================================================================
********************************************************
Update table details - missing DBObjectID
********************************************************
Test case:
1. Find a DBObjectID that is NB: currently in the INTEGRATION.ingress_DataCatalog :
		SELECT * 
		FROM   DC.[DataEntity] 
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
2. Change the DBObjectID 
		UPDATE DC.[DataEntity] 
		SET DBObjectID = NULL
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
3.Check the change
		SELECT * 
		FROM   DC.[DataEntity] 
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
4.Run the Update statement below
5.Check if it was returned to DBSchemaID = 1
		SELECT * 
		FROM   DC.[DataEntity] 
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
							!SUCCESS!
========================================================================*/
UPDATE de
SET  DBObjectID = idc.DataEntityID,
	 UpdatedDT = GETDATE()
FROM [DC].[DataEntity] de
	 INNER JOIN DC.[Schema]  s ON
			    s.SchemaID = de.SchemaID
	 INNER JOIN DC.[Database]  d ON
			    d.DatabaseID = s.DatabaseID
	 INNER JOIN (SELECT DISTINCT DCDatabaseInstanceID,
								 DatabaseName, 
								 SchemaName,
								 DataEntityName,
								 DataEntityID
				 FROM [INTEGRATION].[ingress_DataCatalog]
				  ) idc ON
			    idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
			    idc.DatabaseName = d.DatabaseName AND
			    idc.SchemaName = s.SchemaName AND
			    idc.DataEntityName = de.DataEntityName		
WHERE de.DBObjectID IS NULL OR
	  de.DBObjectID != idc.DataEntityID

/*========================================================================
********************************************************
Update table information (table name)
********************************************************
Test case:
1. Find a DBObjectID that is NB: currently in the INTEGRATION.ingress_DataCatalog :
		SELECT * 
		FROM   DC.[DataEntity] 
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
2. Change the DBObjectID 
		UPDATE DC.[DataEntity] 
		SET DataEntityName  = 'Test'
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
3.Check the change
		SELECT * 
		FROM   DC.[DataEntity] 
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
4.Run the Update statement below
5.Check if it was returned to DBSchemaID = 1
		SELECT * 
		FROM   DC.[DataEntity] 
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
							!SUCCESS!
========================================================================*/
--KD 2019/09/10: Removed because DataEntityName should never be updated based on a possibly changing DBObjectID (DBObjectID is not reliable enough to do this).
--UPDATE de
--SET   DataEntityName = idc.DataEntityName,
--	  UpdatedDT = GETDATE()
--FROM  [DC].[DataEntity] de
--	  INNER JOIN DC.[Schema] s ON
--				 s.SchemaID = de.SchemaID
--	  INNER JOIN DC.[Database] d ON
--				 d.DatabaseID = s.DatabaseID
--	  INNER JOIN [INTEGRATION].[ingress_DataCatalog] idc ON
--				 idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
--				 idc.DatabaseID = d.DBDatabaseID AND
--				 idc.SchemaID = s.DBSchemaID AND
--			     idc.DataEntityID = de.DBObjectID
--WHERE de.DataEntityName != idc.DataEntityName

  /*========================================================================
Update LastSeenDT for DataEntity
========================================================================*/
UPDATE de
SET   de.LastSeenDT = GETDATE(),
	 --Set the UpdatedDT only if it was inactive and now we're making it active
	 de.UpdatedDT = CASE WHEN de.IsActive = 0 THEN GETDATE() ELSE de.UpdatedDT END,
	 de.IsActive = 1
FROM  [DC].[DataEntity] de
	  INNER JOIN DC.[Schema]  s ON
				 s.SchemaID = de.SchemaID
	  INNER JOIN DC.[Database]  d ON
				 d.DatabaseID = s.DatabaseID
	 INNER JOIN (SELECT DISTINCT DCDatabaseInstanceID,
								 DatabaseName, 
								 SchemaName,
								 DataEntityName
				 FROM [INTEGRATION].[ingress_DataCatalog]
				  ) idc ON
				 idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
				 idc.DatabaseName = d.DatabaseName AND
				 idc.SchemaName = s.SchemaName AND
			     idc.DataEntityName = de.DataEntityName

/*========================================================================
********************************************************
Insert new Table/s
********************************************************
This has been tested : Don not delete entries
========================================================================*/
INSERT INTO [DC].[DataEntity]
           ([DataEntityName]
           ,[SchemaID]
		   ,[DBObjectID]
		   ,CreatedDT
		   ,LastSeenDT
		   ,IsActive)
SELECT DISTINCT idc.DataEntityName,
				s.SchemaID,
				idc.DataEntityID,
				GETDATE(),
				GETDATE(),
				1
  FROM [INTEGRATION].[ingress_DataCatalog] idc
	   INNER JOIN DC.[Database]  d ON
				  d.DatabaseName = idc.DatabaseName AND
				  d.DatabaseInstanceID = idc.DCDatabaseInstanceID
	   INNER JOIN DC.[Schema]  s ON
				  s.DatabaseID = d.DatabaseID AND
				  s.SchemaName = idc.SchemaName
 WHERE NOT EXISTS
			(SELECT 1
			 FROM DC.[DataEntity] de
			 WHERE de.DataEntityName = idc.DataEntityName AND
					de.SchemaID = s.SchemaID)
AND idc.DataEntityID IS NOT NULL --Empty databases in the ingress table


 /*========================================================================
********************************************************
Update field information (field name, etc.)
********************************************************
Test case:
1. Find a DBColumnID that is NB: currently in the INTEGRATION.ingress_DataCatalog :
		SELECT * 
		FROM   DC.[Field] 
		WHERE  DataEntityID = 9038 AND
			FieldID = 443336
2. Change the DBColumnID 
		UPDATE DC.[Field] 
		SET FieldName  = 'Test'
		WHERE  DataEntityID = 9038 AND
			FieldID = 443336
3.Check the change
		SELECT * 
		FROM   DC.[Field] 
		WHERE  DataEntityID = 9038 AND
			FieldID = 443336
4.Run the Update statement below
5.Check if it was returned to DBSchemaID = 1
		SELECT * 
		FROM   DC.[Field] 
		WHERE  DataEntityID = 9038 AND
			FieldID = 443336
							!SUCCESS!
========================================================================*/
UPDATE f
   SET --FieldName = idc.ColumnName,
       DBColumnID = idc.ColumnID,
	   DataType = idc.DataType,
	   MAXLENGTH = idc.MAXLENGTH,
	   PRECISION = idc.PRECISION,
	   Scale = idc.Scale,
	   IsPrimaryKey = idc.IsPrimaryKey,
	   IsForeignKey = idc.IsForeignKey,
	   DataEntitySize = idc.dataentitysize,
	   DatabaseSize = idc.DatabaseSize,
	   DefaultValue = idc.defaultvalue,
	   UpdatedDT = GETDATE(),
	   FieldSortOrder = idc.FieldSortOrder
  FROM [DC].Field f
	   INNER JOIN [DC].DataEntity de ON
				  de.DataEntityID = f.DataEntityID
	   INNER JOIN DC.[Schema]  s ON
				  s.SchemaID = de.SchemaID
	   INNER JOIN DC.[Database]  d ON
				  d.DatabaseID = s.DatabaseID
	   INNER JOIN [INTEGRATION].[ingress_DataCatalog] idc ON
				  idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
				  idc.DatabaseName = d.DatabaseName AND
				  idc.SchemaName = s.SchemaName AND
				  idc.DataEntityName = de.DataEntityName AND
				  idc.ColumnName = f.FieldName
 WHERE (
		--f.FieldName != idc.ColumnName OR
	    f.DBColumnID IS NULL OR
	    f.DBColumnID != idc.ColumnID OR
		f.DataType != idc.DataType OR
		ISNULL(f.MAXLENGTH, -1) != idc.MAXLENGTH OR
		ISNULL(f.PRECISION, -1) != idc.PRECISION OR
		ISNULL(f.Scale, -1) != idc.Scale OR
		f.FieldSortOrder is NULL OR
		f.FieldSortOrder != idc.FieldSortOrder
	    )

/*========================================================================
Update LastSeenDT for DataEntity
========================================================================*/
UPDATE f
   SET f.LastSeenDT = GETDATE(),
	 --Set the UpdatedDT only if it was inactive and now we're making it active
	 f.UpdatedDT = CASE WHEN f.IsActive = 0 THEN GETDATE() ELSE f.UpdatedDT END,
	 f.IsActive = 1
  FROM [DC].Field f
	   INNER JOIN [DC].DataEntity de ON
				  de.DataEntityID = f.DataEntityID
	   INNER JOIN DC.[Schema]  s ON
				  s.SchemaID = de.SchemaID
	   INNER JOIN DC.[Database]  d ON
				  d.DatabaseID = s.DatabaseID
	   INNER JOIN [INTEGRATION].[ingress_DataCatalog] idc ON
				  idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
				  idc.DatabaseName = d.DatabaseName AND
				  idc.SchemaName = s.SchemaName AND
				  idc.DataEntityName = de.DataEntityName AND
				  idc.ColumnName = f.FieldName

/*========================================================================
********************************************************
Insert new Field/s
********************************************************
This has been tested : Don not delete entries
========================================================================*/
INSERT INTO [DC].[Field]
           ([FieldName]
           ,[DataType]
           ,[MaxLength]
           ,[Precision]
           ,[Scale]
           ,[IsPrimaryKey]
           ,[IsForeignKey]
           ,[DefaultValue]
           ,[SystemGenerated]
           ,[DataEntityID]
           ,[DBColumnID]
		   ,CreatedDT
		   ,DataEntitySize
		   ,DatabaseSize
		   ,FieldSortOrder
		   ,LastSeenDT
		   ,IsActive)
SELECT idc.ColumnName,
	   idc.DataType,
	   idc.MaxLength,
	   idc.Precision,
	   idc.Scale,
	   idc.IsPrimaryKey,
	   idc.IsForeignKey,
	   idc.DefaultValue,
	   idc.IsSystemGenerated,
	   de.DataEntityID,
	   idc.ColumnID,
	   GETDATE(),
	   idc.DataEntitySize, 
	   idc.DatabaseSize ,
	   idc.FieldSortOrder,
	   GETDATE(),
	   1
FROM [INTEGRATION].[ingress_DataCatalog] idc
	 INNER JOIN [DC].[Database]  d ON
				d.DatabaseInstanceID = idc.DCDatabaseInstanceID AND
				d.DatabaseName = idc.DatabaseName
	 INNER JOIN DC.[Schema] s ON
				s.DatabaseID = d.DatabaseID AND
			    s.SchemaName = idc.SchemaName
	 INNER JOIN DC.DataEntity de ON
				de.SchemaID = s.SchemaID AND
				de.DataEntityName = idc.DataEntityName
WHERE NOT EXISTS
			(SELECT 1
			 FROM [DC].[Field] f
			 WHERE f.FieldName = idc.ColumnName AND
				   f.DataEntityID = de.DataEntityID
		     ) AND
idc.ColumnID IS NOT NULL --Empty databases in ingress table
					
/*========================================================================
--insert new fieldtypefield for PK's
========================================================================*/

--Redundant table - TODO Remove
--INSERT INTO DC.FieldTypeField
--SELECT f.fieldid,
--	   1,
--	   getdate(),
--	   null,
--	   1
--FROM [INTEGRATION].[ingress_DataCatalog] idc
--	 INNER JOIN DC.[Database] d ON
--				d.DatabaseInstanceID = idc.DCDatabaseInstanceID AND
--				d.DBDatabaseID = idc.DatabaseID
--	 INNER JOIN DC.[Schema] s ON
--				s.DBSchemaID = idc.SchemaID AND
--				s.DatabaseID = d.DatabaseID
--	 INNER JOIN DC.DataEntity de ON
--				de.DBObjectID = idc.DataEntityID AND
--				de.SchemaID = s.SchemaID
--	 INNER JOIN DC.Field f on
--				f.DataEntityID = de.DataEntityID
--	 INNER JOIN dc.FieldTypeField ftf on
--				ftf.FieldID = f.FieldID
--	 INNER JOIN dc.fieldtype ft ON
--				ft.fieldtypeid = ftf.FieldTypeID
--WHERE not exists (SELECT 1
--				  FROM  dc.FieldTypeField ftf1
--				  WHERE ftf1.FieldID = f.FieldId AND
--						ftf1.FieldTypeID = 1
--				  ) AND
--idc.IsPrimaryKey = 1

--Insert new fieldtypefield for FK's
--Insert into DC.FieldTypeField
--select f.fieldid,
--	   2,
--	   getdate(),
--	   null,
--	   1
--FROM [INTEGRATION].[ingress_DataCatalog] idc
--	 INNER JOIN DC.[Database] d ON
--				d.DatabaseInstanceID = idc.DCDatabaseInstanceID AND
--				d.DBDatabaseID = idc.DatabaseID
--	 INNER JOIN DC.[Schema] s ON
--				s.DBSchemaID = idc.SchemaID AND
--				s.DatabaseID = d.DatabaseID
--	 INNER JOIN DC.DataEntity de ON
--				de.DBObjectID = idc.DataEntityID AND
--				de.SchemaID = s.SchemaID
--	 INNER JOIN DC.Field f on
--				f.DataEntityID = de.DataEntityID
--	 INNER JOIN dc.FieldTypeField ftf on
--				ftf.FieldID = f.FieldID
--	 INNER JOIN dc.fieldtype ft ON
--				ft.fieldtypeid = ftf.FieldTypeID
--WHERE not exists (SELECT 1
--				  FROM  dc.FieldTypeField ftf1
--				  WHERE	ftf1.FieldID = f.FieldId AND
--						ftf1.FieldTypeID = 2
--				  ) AND
--idc.IsForeignKey = 1





			




			


--update new fieldtypefield

--TODO: Update Table Size in DC as at current value

--update dc.DataEntity 
--	set		Size = idc.DataEntitySize,
--			ModifiedDT = GETDATE()
--	from    [DC].[DataEntity] de
--			INNER JOIN DC.[Schema]  s ON
--				s.SchemaID = de.SchemaID
--			INNER JOIN DC.[Database]  d ON
--				d.DatabaseID = s.DatabaseID
--			INNER JOIN [INTEGRATION].[ingress_DataCatalog] idc ON
--				idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
--				idc.DatabaseID = d.DBDatabaseID AND
--				idc.SchemaID = s.DBSchemaID AND
--				idc.DataEntityName = de.DataEntityName

--			where de.Size = idc.DataEntitySize

--TODO: Update Database Size in DC as at current value
--UPDATE dc.[Database] 
--  SET	Size = idc.[DatabaseSize],
--		ModifiedDT = GETDATE()
--  FROM DC.[Database]  d
--	   INNER JOIN (SELECT DISTINCT DCDatabaseInstanceID, DatabaseID, DatabaseSize FROM [INTEGRATION].[ingress_DataCatalog]) idc ON
--			idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
--			idc.DatabaseID = d.DBDatabaseID
--	where d.size != idc.[DatabaseSize]
     
--TODO: Update History tracking of table and database table

--insert into dc.HistoryTracking_Size
--(	 [HistoryDT]
--	,[ObjectID]
--	,[ObjectTypeID]
--	,[Size_MB])

--(select
--getdate() as HistoryDT
--,de.DBObjectID as ObjectID
--,3 as ObjectTypeID
--,de.Size as Size_MB
--from    INTEGRATION.ingress_DataCatalog dci
--    inner join DC.DatabaseInstance dbi 
--        on dci.DCDatabaseInstanceID = dbi.[DatabaseInstanceID]
--    inner join DC.[Database]  db
--        on db.DatabaseID = dci.DatabaseID
--        and db.DatabaseID = dci.DatabaseID
--    inner join DC.[Schema]  sc 
--		on sc.DatabaseID = db.DatabaseID
--    inner join DC.DataEntity de 
--		on de.SchemaID = sc.SchemaID
--        and de.DBObjectID = dci.DataEntityID

--)
--union all

--(select
--getdate() as HistoryDT
--,db.DBDatabaseID as ObjectID
--,1 as ObjectTypeID
--,db.Size as Size_MB
--from    INTEGRATION.ingress_DataCatalog dci
--    inner join DC.DatabaseInstance dbi 
--        on dci.DCDatabaseInstanceID = dbi.[DatabaseInstanceID]
--    inner join DC.[Database]  db
--        on db.DatabaseID = dci.DatabaseID
--        and db.DatabaseID = dci.DatabaseID
--    inner join DC.[Schema]  sc 
--		on sc.DatabaseID = db.DatabaseID
--    inner join DC.DataEntity de 
--		on de.SchemaID = sc.SchemaID
--        and de.DBObjectID = dci.DataEntityID

--)

GO