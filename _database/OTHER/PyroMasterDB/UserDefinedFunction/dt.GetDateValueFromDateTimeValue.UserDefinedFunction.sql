SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt].[GetDateValueFromDateTimeValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	CREATED BY	: Emile Fraser
	DATE		: 2020-10-15
	DESCRIPTION	: Converts a bigint version of datetime to date

	SELECT infomart.GetDateValueFromDateTimeValue(20201012231553)
*/
CREATE   FUNCTION [dt].[GetDateValueFromDateTimeValue] (
	@DateTimeValue BIGINT
)
RETURNS INT
AS 
BEGIN
	RETURN (
		SELECT @DateTimeValue / 1000000
	)

END
' 
END
GO
