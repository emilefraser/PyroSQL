SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt].[CheckIfCalendarDateIsPublicHoliday]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	SELECT [dt].[CheckIfCalendarDateIsPublicHoliday](''2020-01-01'') == 1
	SELECT [dt].[CheckIfCalendarDateIsPublicHoliday](''2020-01-02'') == 0
	SELECT [dt].[CheckIfCalendarDateIsPublicHoliday](''2021-04-04'') == 0
	SELECT [dt].[CheckIfCalendarDateIsPublicHoliday](''2021-04-02'') == 0
	SELECT [dt].[CheckIfCalendarDateIsPublicHoliday](''2021-04-05'') == 0
*/
CREATE     FUNCTION [dt].[CheckIfCalendarDateIsPublicHoliday] (
	@CalendarDate			DATETIME
)
RETURNS BIT
WITH SCHEMABINDING
AS
BEGIN
	 DECLARE @return_value	BIT
 
	IF EXISTS (
		SELECT 1 FROM dimension.GetPublicHolidayDate AS gph
		WHERE gph.PublicHolidayDate = @CalendarDate
	)
	BEGIN
		SET @return_value = 1
	END
	ELSE
	BEGIN
		SET @return_value = 0
	END

	RETURN @return_value

END
' 
END
GO
