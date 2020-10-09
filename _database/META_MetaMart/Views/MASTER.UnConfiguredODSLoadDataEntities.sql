SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [MASTER].[UnConfiguredODSLoadDataEntities]
AS
SELECT DISTINCT 
                         DataEntityID, DatabaseID, DatabaseName, ServerName, DatabaseInstanceID, DatabaseInstanceName, SchemaID, SchemaName, DBSchemaID, DBObjectID, DataEntityName, IsActive_DE, 
                         DataEntity_CreatedDT, IsActive, SystemID, DatabasePurposeID, DatabasePurposeName
FROM            DC.vw_rpt_DistinctDataEntityDetail
WHERE       NOT EXISTS
                             (SELECT        SourceDataEntityID
                               FROM            ETL.vw_mat_ODSLoadConfigDetails AS ODS
                               WHERE        (DC.vw_rpt_DistinctDataEntityDetail.DataEntityID = SourceDataEntityID))

GO
