SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Francois Senekal 
-- Create Date: 25-06-2019
-- Description: Returns the stage fieldid for a selected sourceid for the BK
-- =============================================
CREATE FUNCTION [DC].[udf_GetDataTypeFromDEIDAndFieldName]
(
    @SourceDataEntityID INT,
	@SourceFieldName varchar(100)
)
RETURNS varchar(50)
AS


BEGIN
	DECLARE @DataType varchar(50) =
		(SELECT DataType
		 FROM DC.DataEntity de
		 INNER JOIN DC.Field f ON
		 f.DataEntityID = de.DataEntityID
		 WHERE f.FieldName = @SourceFieldName
			AND de.DataEntityID = @SourceDataEntityID)



RETURN @DataType
END

GO
