SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_GetQuotedFullName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [tSQLt].[Private_GetQuotedFullName](@Objectid INT)
RETURNS NVARCHAR(517)
AS
BEGIN
    DECLARE @QuotedName NVARCHAR(517);
    SELECT @QuotedName = QUOTENAME(OBJECT_SCHEMA_NAME(@Objectid)) + ''.'' + QUOTENAME(OBJECT_NAME(@Objectid));
    RETURN @QuotedName;
END;
' 
END
GO
