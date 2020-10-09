SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [MASTER].[ConfiguredODSLoadDataEntitiesSource]
AS
SELECT DISTINCT 
                         DataEntityID, DatabaseID, DatabaseName, ServerName, 
						 DatabaseInstanceID, DatabaseInstanceName, SchemaID, SchemaName, DBSchemaID, 
						 DBObjectID, DataEntityName, IsActive_DE, DataEntity_CreatedDT, IsActive, SystemID, DatabasePurposeID,
						 DatabasePurposeCode, DatabasePurposeName
FROM            DC.vw_rpt_DistinctDataEntityDetail
WHERE        EXISTS
                             (SELECT        SourceDataEntityID
                               FROM            ETL.vw_mat_ODSLoadConfigDetails AS ODS
                               WHERE        (DC.vw_rpt_DistinctDataEntityDetail.DataEntityID = SourceDataEntityID))
AND DatabasePurposeCode = 'Source'

GO
