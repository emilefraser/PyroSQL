SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[VerifyStringContains]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =================================================
-- Contains string Function
-- =================================================
-- Return non-zero if the string contains the substring, 
-- otherwise returns 0. substring can also be a list of
-- substrings to look for. With optional start, test string
-- beginning at that position. With optional end, stop 
-- comparing string at that position. 
/*
SELECT dbo.[contains](''What about coming to work for my company?
Will that many people fit under a rock?'',''work'',DEFAULT, DEFAULT)
*/
CREATE FUNCTION [string].[VerifyStringContains]
(
    @String VARCHAR(MAX),
    @substring XML,
    @start INT = NULL,
    @end INT = NULL
)
RETURNS INT
AS BEGIN
	RETURN string.GetStringWithin(@String,@substring,@start,@end,''%'',''%'')
END
' 
END
GO
