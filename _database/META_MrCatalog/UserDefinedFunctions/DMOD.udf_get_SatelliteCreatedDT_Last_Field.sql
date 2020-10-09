SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Gets the UpdateDT Field Specified in the LoadConfig  Table
--==============================================

CREATE FUNCTION [DMOD].[udf_get_SatelliteCreatedDT_Last_Field]
(
    @LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @ReturnField varchar(MAX)

	DECLARE @FieldID INT = (SELECT [CreatedDT_FieldID] 
		FROM [DMOD].[LoadConfig] WHERE [LoadConfigID] = @LoadConfigID)
	
	SET @ReturnField = (SELECT DC.udf_get_FieldName_From_FieldID(@FieldID))

	RETURN QUOTENAME(@ReturnField)
END





GO
