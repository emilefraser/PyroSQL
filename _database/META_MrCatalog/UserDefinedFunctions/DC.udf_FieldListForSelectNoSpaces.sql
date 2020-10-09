SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 16 Oct 2018
-- Description: Returns a field list from the Data Catalog for an INSERT or		`
-- =============================================
-- Sample Execution: DC.sp_FieldListForSelect 68
CREATE FUNCTION [DC].[udf_FieldListForSelectNoSpaces]
(
    @DataEntityID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @FieldList VARCHAR(MAX) = ''

	SELECT @FieldList = @FieldList + '[' + f.FieldName + '],'
	  FROM DC.Field f
	 WHERE DataEntityID = @DataEntityID
	 AND DataType != 'Geography'

		ORDER BY FieldSortOrder ASC

    IF @FieldList != ''
		SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 1)

	-- Return the result of the function
    RETURN @FieldList
END


GO
