SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_GetForeignKeyRefColumns]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [tSQLt].[Private_GetForeignKeyRefColumns](
    @ConstraintObjectId INT
)
RETURNS TABLE
AS
RETURN SELECT STUFF((
                 SELECT '',''+QUOTENAME(rci.name) FROM sys.foreign_key_columns c
                   JOIN sys.columns rci
                  ON rci.object_id = c.referenced_object_id
                  AND rci.column_id = c.referenced_column_id
                   WHERE @ConstraintObjectId = c.constraint_object_id
                   FOR XML PATH(''''),TYPE
                   ).value(''.'',''NVARCHAR(MAX)''),1,1,'''')  AS ColNames;
' 
END
GO
