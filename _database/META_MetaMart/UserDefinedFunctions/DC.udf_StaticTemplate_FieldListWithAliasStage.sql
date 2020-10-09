SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 16 Oct 2018
-- Description: Returns a field list from the Data Catalog for an INSERT or		`
-- =============================================
-- Sample Execution: DC.sp_FieldListForSelect 68
CREATE FUNCTION [DC].[udf_StaticTemplate_FieldListWithAliasStage]
(
    @DataEntityID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

DECLARE @FieldList varchar(MAX)
SET @FieldList = 	(SELECT 
					'StandardAlias.'   +
					'['+FieldName+'] ' + 
					',' 
		 

				  FROM DC.Field f WHERE f.DataEntityID = 90
				  ORDER BY FieldSortOrder asc
				  FOR XML PATH('')
				   ) 
SET @FieldList = LEFT(@FieldList,LEN(@FieldList)-1)				   
RETURN @FieldList
END



GO
