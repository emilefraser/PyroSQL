SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Francois Senekal 
-- Create Date: 16 Oct 2018
-- Description: Returns a field list from the Data Catalog for an Select Statement
-- =============================================
-- Sample Execution: DC.[udf_FieldListForSelectWithAlias] 68, 'TestAlias'
CREATE FUNCTION [DC].[udf_FieldListForSelectWithAlias]
(
    @DataEntityID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @FieldList VARCHAR(MAX) = ''

	SELECT @FieldList = @FieldList + '[' + 'StandardAlias' + '].[' + f.FieldName + '],' + CHAR(13) + CHAR(10)
	  FROM DC.Field f
	 WHERE DataEntityID = @DataEntityID


    IF @FieldList != ''
		SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 3)

	-- Return the result of the function
    RETURN @FieldList
END

GO
