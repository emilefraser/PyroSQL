SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 16 Oct 2018
-- Description: Returns a field list from the Data Catalog for an INSERT or		`
-- =============================================
-- Sample Execution: DC.sp_FieldListForSelect 68
CREATE FUNCTION [DC].[udf_StaticTemplate_FieldListCreateTableStage]
(
    @DataEntityID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

DECLARE @FieldList varchar(MAX)
SET @FieldList = 	(SELECT 
					'['+FieldName+'] ' + 
					DataType + CASE DataType
						WHEN 'int' THEN ''
						WHEN 'geography' THEN ''
						WHEN 'image' THEN ''
						WHEN 'tinyint' THEN ''
						WHEN 'bigint' THEN ''
						WHEN 'bit' THEN ''
						WHEN 'smallint' THEN ''
						WHEN 'decimal' THEN '(' + cast([precision] AS VARCHAR) + ', ' + CAST([scale] AS VARCHAR) + ')'
						WHEN 'datetime' THEN ''
						WHEN 'datetime2' THEN '(7)'
 						ELSE coalesce('('+CASE WHEN [MaxLength] = -1 THEN 'MAX' ELSE cast([MaxLength] AS VARCHAR) END +')','') END +
						' NULL,' 
		 

				  FROM DC.Field f WHERE f.DataEntityID = @DataEntityID
				  AND f.FieldName NOT LIKE 'BKHash'
				  AND f.FieldName NOT LIKE 'LoadDT'
				  AND f.FieldName NOT LIKE 'RecSrcDataEntityID'

				  ORDER BY FieldSortOrder asc
				  FOR XML PATH('')
				   ) 				  
		
RETURN @FieldList
END



GO
