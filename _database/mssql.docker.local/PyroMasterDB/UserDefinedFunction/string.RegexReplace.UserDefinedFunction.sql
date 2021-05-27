SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[RegexReplace]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- SELECT [string].[RegexReplace](''Hello!&.?Dolly[removed]!!!'', ''%[^a-z]%'', '''')
-- SELECT [string].[RegexReplace](''Hello!&.?D ol  ly[removed]!!!'', ''%[^a-z ]%'', '''')
-- SELECT [string].[RegexReplace](''Hello!&.?Dolly254654[removed]!!!'', ''%[^0-9a-z]%'', '''')
CREATE FUNCTION [string].[RegexReplace](@input VARCHAR(MAX), @pattern VARCHAR(MAX), @replacement VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
    WHILE PATINDEX(@pattern, @input) > 0
        SET @input = STUFF(@input, PATINDEX(@pattern, @input), 1, @replacement)
    RETURN @input
END' 
END
GO
