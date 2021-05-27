SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[RegexReplaceSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE   FUNCTION [string].[RegexReplaceSingle](@input VARCHAR(MAX), @pattern VARCHAR(MAX), @replacement VARCHAR(MAX))
RETURNS VARCHAR(MAX)
WITH SCHEMABINDING
AS
BEGIN
	
	
   IF(PATINDEX(@pattern, @input) > 0)
   BEGIN

    SET @input = STUFF(@input, 12, 17, @replacement) --PATINDEX(@pattern, @input), LEN(@pattern), @replacement)

	END
    RETURN @input
END' 
END
GO
