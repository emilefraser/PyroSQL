SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019

-- Sample Execution Statement
--Select [DMOD].[udf_get_ODSDataEntityName](60) --[ext_DEV_ODS_D365_DV_CustInvoiceTrans]

*/

CREATE FUNCTION [DMOD].[udf_get_ODSDataEntityName_External](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @ODSDataEntityName VARCHAR(MAX) = '';
    DECLARE @Source_ExternalTable_Prefix VARCHAR(MAX) = 'ext';
    DECLARE @Source_DataEntityID INT = (SELECT SourceDataEntityID FROM [DMOD].[LoadConfig] AS lc  WHERE lc.LoadConfigID = @LoadConfigID)
    DECLARE @Source_SchemaID INT = (SELECT DC.udf_GetSchemaIDForDataEntityID(@Source_DataEntityID))
    DECLARE @Source_SchemaName VARCHAR(MAX)  = (SELECT DC.udf_GetSchemaNameForDataEntityID(@Source_DataEntityID))
    DECLARE @Source_DatabaseID INT = (SELECT DatabaseID FROM DC.[Schema] WHERE SchemaID = @Source_SchemaID)
    DECLARE @Source_DatabaseName VARCHAR(MAX) = (SELECT DatabaseName FROM DC.[Database] WHERE DatabaseID = @Source_DatabaseID)
    DECLARE @Source_DataEntityName VARCHAR(MAX) = (SELECT DC.udf_GetDataEntityNameForDataEntityID(@Source_DataEntityID))
  
    DECLARE @Target_DataEntityID INT = (SELECT TargetDataEntityID FROM [DMOD].[LoadConfig] AS lc  WHERE lc.LoadConfigID = @LoadConfigID)
    DECLARE @TargetSchemaName VARCHAR(MAX) = (SELECT DC.udf_GetSchemaNameForDataEntityID(@Target_DataEntityID))


	SELECT @ODSDataEntityName = QUOTENAME(@Source_ExternalTable_Prefix + '_' + @Source_DatabaseName + '_' + @Source_SchemaName + '_' + @Source_DataEntityName)

	RETURN @ODSDataEntityName;
END;

GO
