SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AdjustedDayOfWeek]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[AdjustedDayOfWeek] (
	@CalendarDate			DATETIME
)
RETURNS SMALLINT
AS
BEGIN
  DECLARE @return_value	SMALLINT
  SET @return_value =	CASE WHEN @@DATEFIRST = 7 THEN (DATEPART(WEEKDAY, @CalendarDate) + @@DATEFIRST - 8) % 7
							 WHEN @@DATEFIRST = 1 THEN (DATEPART(WEEKDAY, @CalendarDate) + @@DATEFIRST - 1) % 7
							 WHEN @@DATEFIRST = 2 THEN (DATEPART(WEEKDAY, @CalendarDate) + @@DATEFIRST - 2) % 7
							 WHEN @@DATEFIRST = 3 THEN (DATEPART(WEEKDAY, @CalendarDate) + @@DATEFIRST - 3) % 7
							 WHEN @@DATEFIRST = 4 THEN (DATEPART(WEEKDAY, @CalendarDate) + @@DATEFIRST - 4) % 7
							 WHEN @@DATEFIRST = 5 THEN (DATEPART(WEEKDAY, @CalendarDate) + @@DATEFIRST - 5) % 7
							 WHEN @@DATEFIRST = 6 THEN (DATEPART(WEEKDAY, @CalendarDate) + @@DATEFIRST - 6) % 7
												  ELSE 0 END
IF (@return_value = 0)
BEGIN
	SET @return_value = 7 -- fix for sunday
END

RETURN @return_value

END
' 
END
GO
