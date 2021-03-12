SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[RemovePatternFromString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- REPLACES SPECIAL CHARACTERS FROM STRINGS
CREATE   FUNCTION [string].[RemovePatternFromString](@STRINGVALUE VARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @PATTERN NVARCHAR(128) = ''%[$&.!?(]%''
    DECLARE @POS INT = PATINDEX(@PATTERN, @STRINGVALUE)
    WHILE @POS > 0 BEGIN
        SET @STRINGVALUE = STUFF(@STRINGVALUE, @POS, 1, ''_'')
        SET @POS = PATINDEX(@PATTERN, @STRINGVALUE)
    END
	SET @STRINGVALUE = REPLACE(REPLACE(REPLACE(@STRINGVALUE , '')'',''''),''['',''''), '']'', '''')
    RETURN @STRINGVALUE
END
' 
END
GO
