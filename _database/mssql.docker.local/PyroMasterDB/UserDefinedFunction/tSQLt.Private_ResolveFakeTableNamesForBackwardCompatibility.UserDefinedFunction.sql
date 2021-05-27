SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_ResolveFakeTableNamesForBackwardCompatibility]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [tSQLt].[Private_ResolveFakeTableNamesForBackwardCompatibility] 
 (@TableName NVARCHAR(MAX), @SchemaName NVARCHAR(MAX))
RETURNS TABLE AS 
RETURN
  SELECT QUOTENAME(OBJECT_SCHEMA_NAME(object_id)) AS CleanSchemaName,
         QUOTENAME(OBJECT_NAME(object_id)) AS CleanTableName
     FROM (SELECT CASE
                    WHEN @SchemaName IS NULL THEN OBJECT_ID(@TableName)
                    ELSE COALESCE(OBJECT_ID(@SchemaName + ''.'' + @TableName),OBJECT_ID(@TableName + ''.'' + @SchemaName)) 
                  END object_id
          ) ids;
' 
END
GO
