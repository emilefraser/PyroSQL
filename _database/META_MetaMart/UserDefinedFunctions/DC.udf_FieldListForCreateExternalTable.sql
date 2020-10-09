SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 16 Oct 2018
-- Description: Returns a field list from the Data Catalog for an INSERT or		`
-- =============================================
-- Sample Execution: SELECT DC.[udf_FieldListForCreateTable](191)
--SELECT * FROM DC.DataEntity

-- SELECT DC.[udf_FieldListForCreateTable](9619)


CREATE FUNCTION [DC].[udf_FieldListForCreateExternalTable]
(
    @DataEntityID INT
)

RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @FieldList VARCHAR(MAX) = ''

	SELECT 
		@FieldList = @FieldList + CHAR(9) + CHAR(9) + CHAR(9) + '[' + [f].[FieldName] + '] [' + [f].[DataType] + ']' +

			-- Numeric DataTypes
			CASE WHEN [f].[DataType] IN ('bigint', 'int', 'smallint', 'tinyint', 'bit', 'decimal', 'numeric', 'money', 'smallmoney', 'float', 'real')
					THEN CASE WHEN [f].[DataType] IN ('decimal', 'numeric')
										THEN '(' + CAST(f.[Precision] AS VARCHAR(5)) + ',' + CAST(f.[Scale] AS VARCHAR(5)) + ')'
								WHEN [f].[DataType] IN ('float', 'real')  
										THEN ''
										--THEN '(' + CAST(f.[Precision] AS VARCHAR(5)) + ')'
								WHEN [f].[DataType] IN ('bigint', 'int', 'smallint', 'tinyint', 'bit', 'money', 'smallmoney')
										THEN ''
										ELSE ''
							END 
						 
			-- Date/Time DataTypes
			WHEN [f].[DataType] IN ('datetime', 'datetime2', 'smalldatetime', 'date', 'time', 'datetimeoffset', 'timestamp')
				THEN CASE WHEN [f].[DataType] IN ('datetime2', 'datetimeoffset', 'time')
							THEN '(' + CAST(f.[Scale] AS VARCHAR(5)) + ')'
							WHEN [f].[DataType] IN ('datetime', 'smalldatetime', 'date', 'time')
							THEN ''
							ELSE ''
						END 		
								 
			-- char string types
			WHEN [f].[DataType] IN ('char', 'nchar', 'varchar', 'nvarchar', 'varbinary', 'binary', 'text', 'ntext')
				THEN CASE WHEN [f].[DataType] IN ('varchar', 'char', 'varbinary', 'binary')  
							THEN '(' + CASE WHEN f.[MaxLength] = -1   
											THEN 'MAX'   
											ELSE CAST(f.[MaxLength] AS VARCHAR(5))   
										END + ')'  
							WHEN [f].[DataType] IN ('nvarchar', 'nchar')  
							THEN '(' + CASE WHEN f.[MaxLength] = -1   
											THEN 'MAX'   
											ELSE CAST(f.[MaxLength] / 2 AS VARCHAR(5))   
										END + ')'
							WHEN [f].[DataType] IN ('binary', 'text', 'ntext')  
							THEN ''
							ELSE ''
						END

			-- spatial
			WHEN [f].[DataType] IN ('geography', 'geometry', 'hierarchyid')
				THEN CASE WHEN [f].[DataType] IN ('geography', 'geometry', 'hierarchyid')
							THEN ''
							ELSE ''
						END 

					
			-- other types
			WHEN [f].[DataType] IN ('sql_variant',  'uniqueidentifier', 'xml', 'image', 'sysname')
				THEN CASE WHEN [f].[DataType] IN ('sql_variant',  'uniqueidentifier', 'xml', 'image', 'sysname')
							THEN ''
							ELSE ''
					END 
		END
		/*
		-- Just keeping this for now for possible FUTURE
		CASE WHEN c.collation_name IS NOT NULL AND c.system_type_id = c.user_type_id   
                    THEN ' COLLATE ' + c.collation_name  
                    ELSE ''  
                END +  
                CASE WHEN c.is_nullable = 1   
                    THEN ' NULL'  
                    ELSE ' NOT NULL'  
                END +  
                CASE WHEN c.default_object_id != 0   
                    THEN ' CONSTRAINT [' + OBJECT_NAME(c.default_object_id) + ']' +   
                         ' DEFAULT ' + OBJECT_DEFINITION(c.default_object_id)  
                    ELSE ''  
                END +   
                CASE WHEN cc.[object_id] IS NOT NULL   
                    THEN ' CONSTRAINT [' + cc.name + '] CHECK ' + cc.[definition]  
                    ELSE ''  
                END +  
                CASE WHEN c.is_identity = 1   
                    THEN ' IDENTITY(' + CAST(IDENTITYPROPERTY(c.[object_id], 'SeedValue') AS VARCHAR(5)) + ',' +   
                                    CAST(IDENTITYPROPERTY(c.[object_id], 'IncrementValue') AS VARCHAR(5)) + ')'   
                    ELSE ''   
                END   
				*/
		+ ',' + CHAR(13) + CHAR(10)
		FROM 
			[DC].[Field] AS [f]
		WHERE 
			[f].[DataEntityID] = @DataEntityID
		ORDER BY 
			[f].[FieldSortOrder] ASC
		

    IF @FieldList != ''
		SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 3)

	-- Return the result of the function
    RETURN @FieldList
END



GO
