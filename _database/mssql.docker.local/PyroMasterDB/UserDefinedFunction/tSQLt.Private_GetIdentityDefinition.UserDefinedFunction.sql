SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_GetIdentityDefinition]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [tSQLt].[Private_GetIdentityDefinition](@ObjectId INT, @ColumnId INT, @ReturnDetails BIT)
RETURNS TABLE
AS
RETURN SELECT 
              COALESCE(IsIdentity, 0) AS IsIdentityColumn,
              COALESCE(IdentityDefinition, '''') AS IdentityDefinition
        FROM (SELECT 1) X(X)
        LEFT JOIN (SELECT 1 AS IsIdentity,
                          '' IDENTITY('' + CAST(seed_value AS NVARCHAR(MAX)) + '','' + CAST(increment_value AS NVARCHAR(MAX)) + '')'' AS IdentityDefinition, 
                          object_id, 
                          column_id
                     FROM sys.identity_columns
                  ) AS id
               ON id.object_id = @ObjectId
              AND id.column_id = @ColumnId
              AND @ReturnDetails = 1;               


' 
END
GO
