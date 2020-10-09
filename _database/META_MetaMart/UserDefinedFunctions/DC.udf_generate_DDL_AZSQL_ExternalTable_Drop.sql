SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:     Emile FRaser
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE FUNCTION [DC].[udf_generate_DDL_AZSQL_ExternalTable_Drop](
	@TargetDataEntityID AS INT
)

RETURNS VARCHAR(MAX) 
AS
BEGIN
    -- Declare the return variable here
    DECLARE @DropExternalDataTable AS VARCHAR(MAX) = ''
	DECLARE @Object_Name AS VARCHAR(MAX)
	DECLARE @Schema_Name AS VARCHAR(MAX)
	DECLARE @Full_CreationName AS VARCHAR(MAX)
	DECLARE @ExternalSourceName AS VARCHAR(MAX)


	SELECT DISTINCT @Schema_Name =  'dbo'
	--SchemaName FROM [DC].[vw_rpt_DatabaseFieldDetailDMOD] WHERE [DataEntityID] = @TargetDataEntityID
	SELECT DISTINCT @Object_Name =  DataEntityName FROM [DC].[vw_rpt_DatabaseFieldDetailDMOD] WHERE [DataEntityID] = @TargetDataEntityID
	SELECT DISTINCT @Full_CreationName =  'ext_' + DatabaseName + '_' + SchemaName + '_' + DataentityName FROM [DC].[vw_rpt_DatabaseFieldDetailDMOD] WHERE [DataEntityID] = @TargetDataEntityID 
	SELECT DISTINCT @ExternalSourceName = 'ExtDsrc_' + [DatabaseName] FROM [DC].[vw_rpt_DatabaseFieldDetail] WHERE DataEntityID = @TargetDataEntityID

    SELECT @DropExternalDataTable = 
	'IF EXISTS (SELECT * FROM sys.external_tables WHERE [name] = ''' + @Full_CreationName + ''')
		DROP EXTERNAL TABLE [' + @Schema_Name + '].[' + @Full_CreationName + ']' + CHAR(10) + CHAR(13)

    -- Return the result of the function
    RETURN @DropExternalDataTable
END

GO
