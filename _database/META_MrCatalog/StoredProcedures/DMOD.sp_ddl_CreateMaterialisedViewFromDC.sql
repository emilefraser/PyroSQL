SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 5 February 2019
-- Description: Creates materialized view from DataEntityID.
-- =============================================
--Sample Execution: DMOD.sp_ddl_CreateMaterialisedViewFromDC @DataEntityID = 9907
CREATE PROCEDURE [DMOD].[sp_ddl_CreateMaterialisedViewFromDC]
@DataEntityID INT
AS

DECLARE @InTable VARCHAR(100) = 
								(SELECT TOP 1 DataEntityName 
									FROM dc.dataentity
									WHERE dataentityid = @DataEntityID) 
DECLARE @Schema VARCHAR(20) =  (SELECT TOP 1 SchemaName 
									FROM dc.[Schema] s
									JOIN dc.[DataEntity]de ON
										de.SchemaID = s.SchemaID
									WHERE dataentityid = @DataEntityID)

DECLARE @Sql VARCHAR(MAX)



SET @Sql = (
	SELECT  'CREATE VIEW [' + @Schema + '].[vw_mat_' + @InTable + '] AS
SELECT ' + o.list
    FROM    DC.DataEntity de
	CROSS APPLY
		(SELECT
             CHAR(10) + CHAR(13)  + FieldName + ' AS ' + '['+DMOD.udf_Split_On_Upper_Case(FieldName)+'],'
		    FROM DC.Field f WHERE f.DataEntityID = de.DataEntityID
		FOR XML PATH('')) o (list)
	LEFT JOIN
		DC.Field f
	ON  f.DataEntityID = de.DataEntityID
	AND f.IsPrimaryKey  = 1

	WHERE de.DataEntityID = @DataEntityID
	
) 
 + '
FROM ' +  '[' + @Schema + '].[' + @InTable + ']'

--clear last comma
SET @Sql = reverse(@Sql)
Declare @commaIndexedValue INT
Declare @lengthOfString INT
SET @commaIndexedValue = charIndex(',', @Sql)
SET @lengthOfString = len(@sql)
SET @Sql = reverse(Substring(@Sql, 0, @commaIndexedValue) + substring(@Sql, @commaIndexedValue + 1, @lengthOfString))

SELECT @sql = replace(@sql, '&#x0D;', '')

declare @i int = 0

WHILE @i < LEN(@sql)
    BEGIN
	    SELECT SUBSTRING(@sql, @i, @i + 8000)
	    SELECT @i += 8000
    END

GO
