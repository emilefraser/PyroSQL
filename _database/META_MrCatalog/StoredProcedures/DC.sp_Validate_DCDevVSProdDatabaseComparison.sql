SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [DC].[sp_Validate_DCDevVSProdDatabaseComparison]
@DEVDatabaseName varchar(100),
@PRODDatabaseName varchar(100)
AS




SELECT  DISTINCT fd.DatabaseID       AS DEVDabaseID          
				,fd1.DatabaseID      AS DEVDabaseID     
				,fd.databasename     AS DEVDabaseName          
				,fd1.DatabaseName	 AS DEVDabaseName   
				,fd.SchemaID         AS DEVSchemaID          
				,fd1.schemaID		 AS DEVSchemaID     
				,fd.SchemaName       AS DEVSchemaName          
				,fd1.SchemaName 	 AS DEVSchemaName   
				,fd.DataEntityID     AS DEVDataEntityID          
				,fd1.DataEntityID 	 AS DEVDataEntityID 
				,fd.DataEntityName   AS DEVDataEntityNam          
				,fd1.DataEntityName  AS DEVDataEntityNam

from DC.vw_rpt_DatabaseFieldDetail fd
FULL
 OUTER JOIN (select * from DC.vw_rpt_DatabaseFieldDetail where DatabaseName = @PRODDatabaseName
 ) fd1 ON
 fd1.DatabaseInstanceID = fd.DatabaseInstanceID AND
  'DEV_'+fd1.databasename = fd.DatabaseName AND
 fd1.SchemaName = fd.SchemaName AND
 fd1.DataEntityName = fd.DataEntityName
 where fd.DatabaseName = @DEVDatabaseName

 select * from DMOD.HubBusinessKeyField kf inner join dc.vw_rpt_DatabaseFieldDetail f on
 f.FieldID = kf.FieldID



GO
