SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[SplitLines]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

/*
-- =================================================
-- SplitLines string Function
-- =================================================
Return a list of the lines in the string, 
breaking at line boundaries. Line breaks are not included 
in the resulting list unless keepends is given and true. 
*/
/*
SELECT * FROM  array.ConvertArrayToTable([string].[SplitLines](''
When the guy who
made the first drawing board
got it wrong, what did
he go back to?
'',1))
*/
CREATE FUNCTION [string].[SplitLines]
(
    @String VARCHAR(8000),
	@keepends INT=0    
)
RETURNS XML
AS BEGIN
DECLARE @Delimiter VARCHAR(5)
SELECT @Delimiter=CASE WHEN COALESCE(@keepends,0)<>0
THEN CHAR(13) ELSE ''
'' END
RETURN  string.SplitString(@string, @delimiter, NULL)
END
' 
END
GO
