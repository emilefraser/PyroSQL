SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_GetForeignKeyParColumns]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [tSQLt].[Private_GetForeignKeyParColumns](
    @ConstraintObjectId INT
)
RETURNS TABLE
AS
RETURN SELECT STUFF((
                 SELECT '',''+QUOTENAME(pci.name) FROM sys.foreign_key_columns c
                   JOIN sys.columns pci
                   ON pci.object_id = c.parent_object_id
                  AND pci.column_id = c.parent_column_id
                   WHERE @ConstraintObjectId = c.constraint_object_id
                   FOR XML PATH(''''),TYPE
                   ).value(''.'',''NVARCHAR(MAX)''),1,1,'''')  AS ColNames
' 
END
GO
