SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [DC].[sp_Validate_DCSchemaComparison]
@SourceDatabaseName varchar(100),
@TargetDatabaseName varchar(100),
@IsDevToQa bit,
@IsDevToPROD bit,
@IsQAToProd bit
AS

/*------------------------------------------------------------------------
Author = Francois Senekal
Purpose = Compares the DC's between two databases
------------------------------------------------------------------------*/

--DECLARE @SourceDatabaseName varchar(100) = 'DEV_ODS_D365'
--,@TargetDatabaseName varchar(100) =  'ODS_D365'

BEGIN
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
FULL OUTER JOIN (SELECT fd.*,db.DatabasePurposeID
				 FROM DC.vw_rpt_DatabaseFieldDetail fd
				 INNER JOIN DC.[Database] db ON
					 db.DatabaseID = fd.DatabaseID
				 WHERE fd.DatabaseName = @SourceDatabaseName	
 ) fd1 ON
 fd1.SystemID = fd.SystemID AND
 fd1.SchemaName = fd.SchemaName AND
 fd1.DataEntityName = fd.DataEntityName
 where fd.DatabaseName = @TargetDatabaseName

END

GO
