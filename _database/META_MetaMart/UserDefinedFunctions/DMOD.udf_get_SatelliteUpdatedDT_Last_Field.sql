SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 16 Oct 2018
-- Description: Returns a field list from the Data Catalog for an INSERT or		`
-- =============================================
-- Sample Execution: select [DMOD].[udf_get_SatelliteUpdateDT_Last](46704)

CREATE FUNCTION [DMOD].[udf_get_SatelliteUpdatedDT_Last_Field]
(
    @LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @ReturnField varchar(MAX)

	DECLARE @FieldID INT = (SELECT [UpdatedDT_FieldID] FROM [DMOD].[LoadConfig] WHERE [LoadConfigID] = @LoadConfigID)
	SET @ReturnField = (SELECT DC.udf_get_FieldName_From_FieldID(@FieldID))

	RETURN QUOTENAME(@ReturnField)
END




GO
