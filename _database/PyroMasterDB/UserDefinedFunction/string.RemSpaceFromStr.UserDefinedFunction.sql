SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[RemSpaceFromStr]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [string].[RemSpaceFromStr](@str VARCHAR(MAX)) RETURNS VARCHAR(MAX) AS
BEGIN
  RETURN (CASE WHEN CHARINDEX(''  '', @str) > 0 THEN
    string.RemSpaceFromStr(REPLACE(@str, ''  '', '' '')) ELSE @str END);
END' 
END
GO
