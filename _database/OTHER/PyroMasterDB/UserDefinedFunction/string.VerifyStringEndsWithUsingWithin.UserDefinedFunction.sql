SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[VerifyStringEndsWithUsingWithin]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =================================================
-- EndsWith string Function
-- =================================================
-- Return non-zero if the string ends with the suffix, 
-- otherwise return False. The suffix can also be a list of
-- suffixes to look for. With optional start, test string
-- beginning at that position. With optional end, stop 
-- comparing string at that position. 
/*
SELECT   dbo.endswith(''The IRA are indiscriminately killing men
women and children, and now they''''ve killed two Australians
Quote from Margaret Thatcher'', 
	dbo.array(''wilson,Reagan,Clinton,Thatcher'','',''),
                        DEFAULT, DEFAULT)
SELECT   dbo.endswith(
''If we don''''t succeed, then we run the risk of failure
Quote from Dan Quayle'', ''Quayle'',	DEFAULT, DEFAULT)
*/
CREATE FUNCTION [string].[VerifyStringEndsWithUsingWithin]
(
    @String VARCHAR(MAX),
    @prefix XML,
    @start INT = NULL,
    @end INT = NULL
)
RETURNS INT
AS BEGIN
	RETURN string.GetStringWithin(@String,@prefix,@start,@end,'''',''%'')
END
' 
END
GO
