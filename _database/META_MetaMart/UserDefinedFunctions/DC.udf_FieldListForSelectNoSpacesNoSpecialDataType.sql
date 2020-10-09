SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



 
 
 
 
-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 16 Oct 2018
-- Description: Returns a field list from the Data Catalog for an INSERT or     `
-- =============================================
-- Sample Execution: DC.sp_FieldListForSelect 68
CREATE FUNCTION [DC].[udf_FieldListForSelectNoSpacesNoSpecialDataType]
(
    @DataEntityID INT
)
RETURNS VARCHAR(MAX)
AS


BEGIN
    
    --DECLARE @DataEntityID int = 30955
    DECLARE @FieldList VARCHAR(MAX) = ''
 
    SELECT @FieldList = @FieldList + '[' + f.FieldName + '],' 
      FROM DC.Field f
     WHERE DataEntityID = @DataEntityID
     AND DataType not in ('Geography','xml', 'text', 'image', 'ntext')
	 AND FieldID not in (SELECT FieldID	
							FROM DC.Field 
							WHERE DataEntityID = @DataEntityID 
							AND DataType = 'nvarchar'
							AND (MaxLength < 0 OR MaxLength = 8000))
	 AND FieldID not in (SELECT FieldID	
							FROM DC.Field 
							WHERE DataEntityID = @DataEntityID 
							AND DataType = 'varbinary'
							AND (MaxLength < 0 OR MaxLength = 8000))
     AND f.IsActive = 1
 
        ORDER BY FieldSortOrder ASC
 
    IF @FieldList != ''
        SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 1)
 --select @FieldList
    -- Return the result of the function
    RETURN @FieldList
    --select @FieldList
END


GO
