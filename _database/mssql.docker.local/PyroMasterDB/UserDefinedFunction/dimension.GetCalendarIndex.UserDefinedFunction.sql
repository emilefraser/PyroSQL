SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[GetCalendarIndex]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	Created by	:	Emile Fraser
	Dreated on	:	2020-06-30
	Description	:	Gets the Index Per Date Period 
*/				
CREATE      FUNCTION [dimension].[GetCalendarIndex] (
    @CalendarDate		DATE
,	@DatePart			VARCHAR(20)
)
RETURNS INT
AS
BEGIN
	DECLARE @returnValue		INT
	DECLARE @CalendarDateStart	DATE = (SELECT MIN(CalendarDate) FROM DIMENSION.[DateDimension])

	SET @returnValue = 
		CASE @DatePart 
			WHEN ''DAY''
				THEN DATEDIFF(DAY,		@CalendarDateStart,  @CalendarDate)
			WHEN ''WEEK''
				THEN DATEDIFF(WEEK,		@CalendarDateStart,  @CalendarDate)
			WHEN ''MONTH''
				THEN DATEDIFF(MONTH,	@CalendarDateStart,  @CalendarDate)
			WHEN ''QUARTER''
				THEN DATEDIFF(QUARTER,	@CalendarDateStart,  @CalendarDate)
			WHEN ''HALFYEAR''
				THEN DATEDIFF(QUARTER,	@CalendarDateStart,  @CalendarDate) / 2
			WHEN ''YEAR''
				THEN DATEDIFF(YEAR,		@CalendarDateStart,  @CalendarDate)
			ELSE
				0
		END

	RETURN @returnValue

END
' 
END
GO
