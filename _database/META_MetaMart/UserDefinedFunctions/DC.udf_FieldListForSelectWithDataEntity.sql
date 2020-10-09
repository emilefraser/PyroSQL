SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 16 Oct 2018
-- Description: Returns a field list from the Data Catalog for an INSERT or		`
-- =============================================
-- Sample Execution: DC.[udf_FieldListForSelectWithAlias] 68, 'TestAlias'
CREATE FUNCTION [DC].[udf_FieldListForSelectWithDataEntity]
(
    @DataEntityID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @FieldList VARCHAR(MAX) = ''

	SELECT @FieldList = @FieldList + '[' + f.DataEntityName + '].' + + '[' + f.FieldName + ']' + ' as [' + f.DataEntityName + '_' + f.FieldName + '],' + CHAR(13) + CHAR(10)
	  FROM [DC].[vw_rpt_DatabaseFieldDetailDMOD] f
	 WHERE DataEntityID = @DataEntityID


    IF @FieldList != ''
		SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 3)

	-- Return the result of the function
    RETURN @FieldList
END


GO
