SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[TransformStringWithRightPartition]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =================================================
-- RPartition string Function
-- =================================================

-- Split the string at the last occurrence of sep, and RETURN
-- an array containing the part before the separator, the 
-- separator itself, and the part after the separator. IF
-- the separator is not found, return an array containing
-- the string itself, followed by two empty strings. 
/*

SELECT item FROM array.ConvertArrayToTable(string.TransformStringWithRightPartition(
''Does the name ''''Pavlov'''' ring a bell?'',
''pavlov''))
*/
CREATE FUNCTION [string].[TransformStringWithRightPartition]
(
    @String VARCHAR(MAX),
    @Sep VARCHAR(MAX)
)
RETURNS XML
AS BEGIN
	RETURN string.GetStringPartsWithDelimiter(@String,@sep,1)
END
' 
END
GO
