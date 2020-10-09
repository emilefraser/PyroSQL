SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
--===============================================================================================================================
--Stored Proc Version Control
--===============================================================================================================================
/*

	Author:						| Karl Dinkelmann
	Stored Proc Create Date:	| 2019-07-13
	Stored Proc Last Modified:	| N/A
	Last Modified User:			| N/A
	Description:				| Transfers config for a Data Model from a Source Database to a Target Database.
								| This is for transferring Data Models from Source System DEV to QA to PROD environments.

WARNING: This functionality is DESTRUCTIVE. It will deactivate any existing Data Modelling done on the Target Source Database.

*/
								
/* SAMPLE EXECUTION:
EXEC [DMOD].[sp_TransferDataModelToSourceSystemEnvironment] 7, 1
*/
CREATE PROCEDURE [DMOD].[sp_TransferDataModelToSourceSystemEnvironment]
	--@SourceDatabaseID - The DatabaseID of the database that the data model currently refers to (where it was originally built).
	@SourceDatabaseID INT,
	--@TargetDatabaseID - The DatabaseID of the database that you want the Data Model to refer to.
	@TargetDatabaseID INT
AS

/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
--Stored Proc Management
	--===============================================================================================================================
	--Variable workbench
	--===============================================================================================================================
	---------------------------------------------------------------------------------------------------------------------------------
	--Testing variables (COMMENT OUT BEFORE ALTERING THE PROC)
	---------------------------------------------------------------------------------------------------------------------------------
	-- (If you uncomment this line the whole testing variable block will become active
	--SELECT * FROM DC.[Database]	
	--DECLARE @SourceDatabaseID INT = 1,
	--		@TargetDatabaseID INT = 7
	---------------------------------------------------------------------------------------------------------------------------------
	--Stored Proc Variables
	---------------------------------------------------------------------------------------------------------------------------------	
		--DECLARE	 



/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
--Stored Proc Logic

DECLARE @SchemaName sysname,
		@DataEntityName sysname,
		@FieldName sysname,
		@Sql VARCHAR(MAX)

		--Counts the modelled fields of the  source Database before the transfer
DROP TABLE IF EXISTS #SourceCountBefore
CREATE TABLE #SourceCountBefore (SourceName varchar(150),SourceCountBefore int)
INSERT INTO #SourceCountBefore
SELECT 'HierarchicalLinkPKFieldIDCount' ,COUNT(PKFieldID)  FROM DMOD.HierarchicalLink hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.PKFieldID WHERE DatabaseID = @SourceDatabaseID
UNION ALL
SELECT 'HierarchicalLinkParentFieldIDCount',COUNT(ParentFieldID)  FROM DMOD.HierarchicalLink hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.ParentFieldID WHERE DatabaseID = @SourceDatabaseID
UNION ALL
SELECT 'HubBusinessKeyHubBKFieldIDCount',COUNT([HubBKFieldID])   FROM [DMOD].[HubBusinessKey] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.HubBKFieldID WHERE DatabaseID = @SourceDatabaseID 
UNION ALL
SELECT 'HubBusinessKeyFieldFieldIDCount',COUNT(hl.FieldID)  FROM [DMOD].[HubBusinessKeyField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.FieldID WHERE DatabaseID = @SourceDatabaseID 
UNION ALL
SELECT 'LinkHubToManyToManyLinkFieldHubPKFieldIDCount',COUNT([HubPKFieldID])   FROM [DMOD].[LinkHubToManyToManyLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[HubPKFieldID] WHERE DatabaseID = @SourceDatabaseID  
UNION ALL
SELECT 'LinkHubToManyToManyLinkFieldManyToManyTableFKFieldIDCount', COUNT([ManyToManyTableFKFieldID])  FROM [DMOD].[LinkHubToManyToManyLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[ManyToManyTableFKFieldID] WHERE DatabaseID = @SourceDatabaseID 
UNION ALL
SELECT 'PKFKLinkFieldPrimaryKeyFieldIDCount',COUNT([PrimaryKeyFieldID])  FROM [DMOD].[PKFKLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[PrimaryKeyFieldID] WHERE DatabaseID = @SourceDatabaseID  
UNION ALL
SELECT 'PKFKLinkFieldForeignKeyFieldIDCount',COUNT([ForeignKeyFieldID])  FROM [DMOD].[PKFKLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[ForeignKeyFieldID] WHERE DatabaseID = @SourceDatabaseID 
UNION ALL
SELECT 'SameAsLinkFieldMasterFieldIDCount',COUNT([MasterFieldID])  FROM [DMOD].[SameAsLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[MasterFieldID] WHERE DatabaseID = @SourceDatabaseID 
UNION ALL
SELECT 'SameAsLinkFieldSlaveFieldIDCount',COUNT([SlaveFieldID])  FROM [DMOD].[SameAsLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[SlaveFieldID] WHERE DatabaseID = @SourceDatabaseID 
UNION ALL
SELECT 'SatelliteFieldFieldIDCountCount',COUNT(hl.[FieldID])  FROM [DMOD].[SatelliteField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[FieldID] WHERE DatabaseID = @SourceDatabaseID 
SELECT * FROM #SourceCountBefore

--Counts the modelled fields of the  target Database before the transfer
DROP TABLE IF EXISTS #TargetCountBefore
CREATE TABLE #TargetCountBefore (SourceName varchar(150),TargetCountBefore int)
INSERT INTO #TargetCountBefore
SELECT 'HierarchicalLinkPKFieldIDCount' ,COUNT(PKFieldID)  FROM DMOD.HierarchicalLink hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.PKFieldID WHERE DatabaseID = @TargetDatabaseID
UNION ALL
SELECT 'HierarchicalLinkParentFieldIDCount',COUNT(ParentFieldID)  FROM DMOD.HierarchicalLink hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.ParentFieldID WHERE DatabaseID = @TargetDatabaseID
UNION ALL
SELECT 'HubBusinessKeyHubBKFieldIDCount',COUNT([HubBKFieldID])   FROM [DMOD].[HubBusinessKey] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.HubBKFieldID WHERE DatabaseID = @TargetDatabaseID 
UNION ALL
SELECT 'HubBusinessKeyFieldFieldIDCount',COUNT(hl.FieldID)  FROM [DMOD].[HubBusinessKeyField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.FieldID WHERE DatabaseID = @TargetDatabaseID 
UNION ALL
SELECT 'LinkHubToManyToManyLinkFieldHubPKFieldIDCount',COUNT([HubPKFieldID])   FROM [DMOD].[LinkHubToManyToManyLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[HubPKFieldID] WHERE DatabaseID = @TargetDatabaseID  
UNION ALL
SELECT 'LinkHubToManyToManyLinkFieldManyToManyTableFKFieldIDCount', COUNT([ManyToManyTableFKFieldID])  FROM [DMOD].[LinkHubToManyToManyLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[ManyToManyTableFKFieldID] WHERE DatabaseID = @TargetDatabaseID 
UNION ALL
SELECT 'PKFKLinkFieldPrimaryKeyFieldIDCount',COUNT([PrimaryKeyFieldID])  FROM [DMOD].[PKFKLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[PrimaryKeyFieldID] WHERE DatabaseID = @TargetDatabaseID  
UNION ALL
SELECT 'PKFKLinkFieldForeignKeyFieldIDCount',COUNT([ForeignKeyFieldID])  FROM [DMOD].[PKFKLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[ForeignKeyFieldID] WHERE DatabaseID = @TargetDatabaseID 
UNION ALL
SELECT 'SameAsLinkFieldMasterFieldIDCount',COUNT([MasterFieldID])  FROM [DMOD].[SameAsLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[MasterFieldID] WHERE DatabaseID = @TargetDatabaseID 
UNION ALL
SELECT 'SameAsLinkFieldSlaveFieldIDCount',COUNT([SlaveFieldID])  FROM [DMOD].[SameAsLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[SlaveFieldID] WHERE DatabaseID = @TargetDatabaseID 
UNION ALL
SELECT 'SatelliteFieldFieldIDCountCount',COUNT(hl.[FieldID])  FROM [DMOD].[SatelliteField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[FieldID] WHERE DatabaseID = @TargetDatabaseID 
SELECT * FROM #TargetCountBefore

--Deactivate any Modelling already done on the Target Database

--Set all TargetDatabase DataEntityID references to inactive
DECLARE FieldsCursor CURSOR FOR   
	SELECT DISTINCT s.name AS SchemaName,
				    t.name AS DataEntityName,
				    c.name AS FieldName
	  FROM sys.columns c
		   INNER JOIN sys.tables t ON
				t.object_id = c.object_id
		   INNER JOIN sys.schemas s ON
				s.schema_id = t.schema_id
		   INNER JOIN sys.indexes i ON
				i.object_id = t.object_id
		   LEFT JOIN (SELECT subi.object_id, subi.index_id, subic.column_id
						 FROM sys.indexes subi
							LEFT JOIN sys.index_columns subic
								ON subic.object_id = subi.object_id AND
								   subic.index_id = subi.index_id
						WHERE subi.is_primary_key = 1) i_pk
				ON i_pk.object_id = t.object_id AND
				   i_pk.column_id = c.column_id
	 WHERE (
	        c.name LIKE '%DataEntityID' OR
		    c.name LIKE '%FieldID'
		   ) AND
		     s.name = 'DMOD'
		     AND
		     t.name IN ('HubBusinesskeyField','LoadConfig','PKFKLinkField','SatelliteField','SamesAsLinkField') 
			 AND
		     CASE WHEN i_pk.object_id IS NOT NULL THEN 1 ELSE 0 END = 0 --Not primary keys

OPEN FieldsCursor  
  
FETCH NEXT FROM FieldsCursor
INTO @SchemaName, @DataEntityName, @FieldName
  
WHILE @@FETCH_STATUS = 0  
BEGIN  

/*Example:
UPDATE [DMOD].[HierarchicalLink]
   SET IsActive = 0
 WHERE [DC].[udf_get_DatabaseID_from_FieldID](PKFieldID) = 2 AND
	   IsActive = 1
*/

	SET @Sql = '
UPDATE [' + @SchemaName + '].[' + @DataEntityName + ']
   SET IsActive = 0
  FROM [' + @SchemaName + '].[' + @DataEntityName + ']
 WHERE ' + 
		--Depending on whether it's a "DataEntityID" reference field or a "FieldID" field, use the appropriate function
		CASE WHEN @FieldName LIKE '%DataEntityID'
		  THEN '[DC].[udf_get_DatabaseID_from_DataEntityID]'
		  ELSE '[DC].[udf_get_DatabaseID_from_FieldID]'
		END
	   + '(' + @FieldName + ') = ' + CONVERT(VARCHAR, @TargetDatabaseID) + ' AND
	   IsActive = 1'
	
	SELECT @Sql
	--EXEC (@Sql)

	FETCH NEXT FROM FieldsCursor   
	INTO @SchemaName, @DataEntityName, @FieldName

END

CLOSE FieldsCursor;  
DEALLOCATE FieldsCursor;


--Convert all "SchemaID", "DataEntityID" and "FieldID" fields from the SourceDatabaseID to the related "SchemaID", "DataEntityID" and "FieldID" in the TargetDatabaseID
DECLARE FieldsCursor CURSOR FOR   
	SELECT DISTINCT s.name AS SchemaName,
				    t.name AS DataEntityName,
				    c.name AS FieldName
	  FROM sys.columns c
		   INNER JOIN sys.tables t ON
				t.object_id = c.object_id
		   INNER JOIN sys.schemas s ON
				s.schema_id = t.schema_id
		   INNER JOIN sys.indexes i ON
				i.object_id = t.object_id
		   LEFT JOIN (SELECT subi.object_id, subi.index_id, subic.column_id
						 FROM sys.indexes subi
							LEFT JOIN sys.index_columns subic
								ON subic.object_id = subi.object_id AND
								   subic.index_id = subi.index_id
						WHERE subi.is_primary_key = 1) i_pk
				ON i_pk.object_id = t.object_id AND
				   i_pk.column_id = c.column_id
	 WHERE (
	        c.name LIKE '%DataEntityID' OR
		    c.name LIKE '%FieldID'
		   ) AND
		   s.name = 'DMOD'
		     AND
		   t.name IN ('HubBusinesskeyField','LoadConfig','PKFKLinkField','SatelliteField','SamesAsLinkField') AND
		   CASE WHEN i_pk.object_id IS NOT NULL THEN 1 ELSE 0 END = 0 --Not primary keys

OPEN FieldsCursor  
  
FETCH NEXT FROM FieldsCursor
INTO @SchemaName, @DataEntityName, @FieldName
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
/*Example:
UPDATE [DMOD].[HubBusinessKeyField]
   SET FieldID = [DC].[udf_get_EquivalentFieldID_in_TargetDatabaseID](FieldID, 4)
 WHERE [DC].[udf_get_DatabaseID_from_FieldID](FieldID) = 2 --@SourceDatabaseID
*/


	SET @Sql = '
UPDATE [' + @SchemaName + '].[' + @DataEntityName + ']
   SET ' + @FieldName + ' = ' + 
		--Depending on whether it's a "DataEntityID" reference field or a "FieldID" field, use the appropriate function
		CASE WHEN @FieldName LIKE '%DataEntityID'
		  THEN '[DC].[udf_get_EquivalentDataEntityID_in_TargetDatabaseID]'
		  ELSE '[DC].[udf_get_EquivalentFieldID_in_TargetDatabaseID]'
		END
	   + '(' + @FieldName + ', ' + CONVERT(VARCHAR, @TargetDatabaseID) + ')
  FROM [' + @SchemaName + '].[' + @DataEntityName + ']
 WHERE ' +
 		--Depending on whether it's a "DataEntityID" reference field or a "FieldID" field, use the appropriate function
		CASE WHEN @FieldName LIKE '%DataEntityID'
		  THEN '[DC].[udf_get_DatabaseID_from_DataEntityID]'
		  ELSE '[DC].[udf_get_DatabaseID_from_FieldID]'
		END
		+ '(' + @FieldName + ') = ' + CONVERT(VARCHAR, @SourceDatabaseID)
	
	SELECT @Sql
	--EXEC (@Sql)

	FETCH NEXT FROM FieldsCursor   
	INTO @SchemaName, @DataEntityName, @FieldName

END

CLOSE FieldsCursor;  
DEALLOCATE FieldsCursor;

--Counts the modelled fields of the  source Database after the transfer
DROP TABLE IF EXISTS #SourceCountAfter
CREATE TABLE #SourceCountAfter (SourceName varchar(150),SourceCountAfter int)
INSERT INTO #SourceCountAfter
SELECT 'HierarchicalLinkPKFieldIDCount' ,COUNT(PKFieldID)  FROM DMOD.HierarchicalLink hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.PKFieldID WHERE DatabaseID = @SourceDatabaseID
UNION ALL
SELECT 'HierarchicalLinkParentFieldIDCount',COUNT(ParentFieldID)  FROM DMOD.HierarchicalLink hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.ParentFieldID WHERE DatabaseID = @SourceDatabaseID
UNION ALL
SELECT 'HubBusinessKeyHubBKFieldIDCount',COUNT([HubBKFieldID])   FROM [DMOD].[HubBusinessKey] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.HubBKFieldID WHERE DatabaseID = @SourceDatabaseID 
UNION ALL
SELECT 'HubBusinessKeyFieldFieldIDCount',COUNT(hl.FieldID)  FROM [DMOD].[HubBusinessKeyField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.FieldID WHERE DatabaseID = @SourceDatabaseID 
UNION ALL
SELECT 'LinkHubToManyToManyLinkFieldHubPKFieldIDCount',COUNT([HubPKFieldID])   FROM [DMOD].[LinkHubToManyToManyLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[HubPKFieldID] WHERE DatabaseID = @SourceDatabaseID  
UNION ALL
SELECT 'LinkHubToManyToManyLinkFieldManyToManyTableFKFieldIDCount', COUNT([ManyToManyTableFKFieldID])  FROM [DMOD].[LinkHubToManyToManyLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[ManyToManyTableFKFieldID] WHERE DatabaseID = @SourceDatabaseID 
UNION ALL
SELECT 'PKFKLinkFieldPrimaryKeyFieldIDCount',COUNT([PrimaryKeyFieldID])  FROM [DMOD].[PKFKLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[PrimaryKeyFieldID] WHERE DatabaseID = @SourceDatabaseID  
UNION ALL
SELECT 'PKFKLinkFieldForeignKeyFieldIDCount',COUNT([ForeignKeyFieldID])  FROM [DMOD].[PKFKLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[ForeignKeyFieldID] WHERE DatabaseID = @SourceDatabaseID 
UNION ALL
SELECT 'SameAsLinkFieldMasterFieldIDCount',COUNT([MasterFieldID])  FROM [DMOD].[SameAsLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[MasterFieldID] WHERE DatabaseID = @SourceDatabaseID 
UNION ALL
SELECT 'SameAsLinkFieldSlaveFieldIDCount',COUNT([SlaveFieldID])  FROM [DMOD].[SameAsLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[SlaveFieldID] WHERE DatabaseID = @SourceDatabaseID 
UNION ALL
SELECT 'SatelliteFieldFieldIDCountCount',COUNT(hl.[FieldID])  FROM [DMOD].[SatelliteField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[FieldID] WHERE DatabaseID = @SourceDatabaseID 
SELECT * FROM #SourceCountAfter

--Counts the modelled fields of the  target Database before the transfer
DROP TABLE IF EXISTS #TargetCountAfter
CREATE TABLE #TargetCountAfter (SourceName varchar(150),TargetCountAfter int)
INSERT INTO #TargetCountAfter
SELECT 'HierarchicalLinkPKFieldIDCount' ,COUNT(PKFieldID)  FROM DMOD.HierarchicalLink hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.PKFieldID WHERE DatabaseID = @TargetDatabaseID
UNION ALL
SELECT 'HierarchicalLinkParentFieldIDCount',COUNT(ParentFieldID)  FROM DMOD.HierarchicalLink hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.ParentFieldID WHERE DatabaseID = @TargetDatabaseID
UNION ALL
SELECT 'HubBusinessKeyHubBKFieldIDCount',COUNT([HubBKFieldID])   FROM [DMOD].[HubBusinessKey] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.HubBKFieldID WHERE DatabaseID = @TargetDatabaseID 
UNION ALL
SELECT 'HubBusinessKeyFieldFieldIDCount',COUNT(hl.FieldID)  FROM [DMOD].[HubBusinessKeyField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.FieldID WHERE DatabaseID = @TargetDatabaseID 
UNION ALL
SELECT 'LinkHubToManyToManyLinkFieldHubPKFieldIDCount',COUNT([HubPKFieldID])   FROM [DMOD].[LinkHubToManyToManyLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[HubPKFieldID] WHERE DatabaseID = @TargetDatabaseID  
UNION ALL
SELECT 'LinkHubToManyToManyLinkFieldManyToManyTableFKFieldIDCount', COUNT([ManyToManyTableFKFieldID])  FROM [DMOD].[LinkHubToManyToManyLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[ManyToManyTableFKFieldID] WHERE DatabaseID = @TargetDatabaseID 
UNION ALL
SELECT 'PKFKLinkFieldPrimaryKeyFieldIDCount',COUNT([PrimaryKeyFieldID])  FROM [DMOD].[PKFKLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[PrimaryKeyFieldID] WHERE DatabaseID = @TargetDatabaseID  
UNION ALL
SELECT 'PKFKLinkFieldForeignKeyFieldIDCount',COUNT([ForeignKeyFieldID])  FROM [DMOD].[PKFKLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[ForeignKeyFieldID] WHERE DatabaseID = @TargetDatabaseID 
UNION ALL
SELECT 'SameAsLinkFieldMasterFieldIDCount',COUNT([MasterFieldID])  FROM [DMOD].[SameAsLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[MasterFieldID] WHERE DatabaseID = @TargetDatabaseID 
UNION ALL
SELECT 'SameAsLinkFieldSlaveFieldIDCount',COUNT([SlaveFieldID])  FROM [DMOD].[SameAsLinkField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[SlaveFieldID] WHERE DatabaseID = @TargetDatabaseID 
UNION ALL
SELECT 'SatelliteFieldFieldIDCountCount',COUNT(hl.[FieldID])  FROM [DMOD].[SatelliteField] hl 
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON fd.Fieldid = hl.[FieldID] WHERE DatabaseID = @TargetDatabaseID 
SELECT * FROM #TargetCountAfter



  
  
  
  
  



GO
