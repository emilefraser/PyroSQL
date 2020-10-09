SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE Function dbo.usp_TestComputed(@CalendarDate DATE) 
RETURNS BIT AS
BEGIN
	DECLARE @return BIT = (SELECT IIF(DATEPART(WEEKDAY, @CalendarDate) = 1, 1, 0))

	RETURN @return
END

GO