SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 16 Oct 2018
-- Description: Returns a field list from the Data Catalog for an INSERT or		`
-- =============================================
-- Sample Execution: SELECT [MASTER].[udf_FieldListForSortOrderGroup]('LABSAMPLE')
CREATE FUNCTION [MASTER].[udf_FieldListForSortOrderGroup_NotUsedDontDelete]
(
    @SortOrderGroupCode VARCHAR(20)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @FieldList VARCHAR(MAX) = ''

	SELECT @FieldList = @FieldList + '[' + f.FieldName + '],' + CHAR(13) + CHAR(10)
	  FROM [MASTER].SortOrderGrouping sog
	   LEFT JOIN [MASTER].SortOrderGroupingField sogf ON
			sogf.SortOrderGroupingID = sog.SortOrderGroupingID
	   LEFT JOIN DC.Field f ON
			f.FieldID = sogf.FieldID
	 WHERE sog.SortOrderGroupCode = @SortOrderGroupCode

    IF @FieldList != ''
		SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 3)

	-- Return the result of the function
    RETURN @FieldList
END

GO
