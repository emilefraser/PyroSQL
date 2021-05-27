SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[VerifyStringStartsWith]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =================================================
-- StartsWith string Function
-- =================================================
-- Return non-zero if the string starts with the prefix, 
-- otherwise return False. prefix can also be a list of
-- prefixes to look for. With optional start, test string
-- beginning at that position. With optional end, stop 
-- comparing string at that position. 
/*

SELECT string.VerifyStringStartsWith(
''Aside from its purchasing power, money is pretty useless'',
dbo.array(''power,money,love'','',''),27,DEFAULT)
*/
CREATE FUNCTION [string].[VerifyStringStartsWith]
(
    @String VARCHAR(MAX),
    @prefix XML,
    @start INT = NULL,
    @end INT = NULL
)
RETURNS INT
AS BEGIN
	RETURN dbo.within(@String,@prefix,@start,@end,''%'','''')
END
' 
END
GO
