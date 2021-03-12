SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt].[CalculateMonthDifferenceBetweenInts]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

-- Created By: Emile Fraser
-- Date: 2020-09-09
-- Calculates the difference in days between 1 integer representation of a data and another
-- select [infomart].[CalculateDaysDifferenceBetweenInts] (20200101091544, 20200201)
CREATE     FUNCTION [dt].[CalculateMonthDifferenceBetweenInts] (
	@StartDateInteger BIGINT
,	@EndDateInteger BIGINT
)
RETURNS INT
WITH SCHEMABINDING
AS
BEGIN
   RETURN DATEDIFF(MONTH, CONVERT(DATE,  SUBSTRING(CAST(@StartDateInteger AS CHAR(20)),1,8)), CONVERT(DATE, SUBSTRING(CAST(@EndDateInteger AS CHAR(20)),1,8)))
END

' 
END
GO
