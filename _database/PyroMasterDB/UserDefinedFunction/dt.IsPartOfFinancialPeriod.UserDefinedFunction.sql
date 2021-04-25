SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt].[IsPartOfFinancialPeriod]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE    FUNCTION [dt].[IsPartOfFinancialPeriod] (
			@CalendarDate					DATE
		,	@FinancialPeriodGranularity		NVARCHAR(20) -- Year, HalfYear, Quarter, Month, Week
)
RETURNS BIT 
WITH SCHEMABINDING
AS 

BEGIN
	DECLARE 
		@CurrentFinancialPeriodValue		NVARCHAR(20)
	,	@CalendarDateFinancialPeriodValue	NVARCHAR(20)
	,	@CurrentDate						DATE = FORMAT(GETDATE(), ''yyyy-MM-dd'')
	,	@ReturnValue						BIT
	/*
	SET @CurrentFinancialPeriodValue = 
		CASE UPPER(@FinancialPeriodGranularity) 
			WHEN ''YEAR''
				THEN (SELECT FinancialYear FROM dimension.DateDimension2 WHERE [CalendarDate] = @CalendarDate)
			WHEN ''HALFYEAR''
				THEN (CONCAT(
					(SELECT FinancialYearValue FROM dimension.DateDimension2 WHERE [CalendarDate] = @CalendarDate)
				,	(SELECT HalfYearOfFinancialYear FROM dimension.DateDimension2 WHERE [CalendarDate] = @CalendarDate)
					)
				)
			WHEN ''QUARTER''
				THEN (CONCAT(
					(SELECT FinancialYearValue FROM dimension.DateDimension2 WHERE [CalendarDate] = @CalendarDate)
				,	(SELECT QuarterOfFinancialYear FROM dimension.DateDimension2 WHERE [CalendarDate] = @CalendarDate)
					)
				)
			WHEN ''MONTH''
				THEN (CONCAT(
					(SELECT FinancialYearValue FROM dimension.DateDimension2 WHERE [CalendarDate] = @CalendarDate)
				,	(SELECT MonthOfFinancialYear FROM dimension.DateDimension2 WHERE [CalendarDate] = @CalendarDate)
					)
				)
			--WHEN ''WEEK''
			--	THEN (CONCAT(
			--		(SELECT FinancialYearValue FROM dimension.DateDimension2 WHERE [CalendarDate] = @CalendarDate)
			--	,	(SELECT FinancialWeekOfYear FROM dimension.DateDimension2 WHERE [CalendarDate] = @CalendarDate)
			--		)
			--	)
			ELSE
				''190001''
		END

	SET @CalendarDateFinancialPeriodValue = 
		CASE UPPER(@FinancialPeriodGranularity) 
			WHEN ''YEAR''
				THEN (SELECT FinancialYear FROM dimension.DateDimension2 WHERE [CalendarDate] = @CurrentDate)
			WHEN ''HALFYEAR''
				THEN (CONCAT(
					(SELECT FinancialYearValue FROM dimension.DateDimension2 WHERE [CalendarDate] = @CurrentDate)
				,	(SELECT HalfYearOfFinancialYear FROM dimension.DateDimension2 WHERE [CalendarDate] = @CurrentDate)
					)
				)
			WHEN ''QUARTER''
				THEN (CONCAT(
					(SELECT FinancialYearValue FROM dimension.DateDimension2 WHERE [CalendarDate] = @CurrentDate)
				,	(SELECT QuarterOfFinancialYear FROM dimension.DateDimension2 WHERE [CalendarDate] = @CurrentDate)
					)
				)
			WHEN ''MONTH''
				THEN (CONCAT(
					(SELECT FinancialYearValue FROM dimension.DateDimension2 WHERE [CalendarDate] = @CurrentDate)
				,	(SELECT MonthOfFinancialYear FROM dimension.DateDimension2 WHERE [CalendarDate] = @CurrentDate)
					)
				)
			--WHEN ''WEEK''
			--	THEN (CONCAT(
			--		(SELECT FinancialYearValue FROM dimension.DateDimension2 WHERE [CalendarDate] = @CurrentDate)
			--	,	(SELECT FinancialWeekOfYear FROM dimension.DateDimension2 WHERE [CalendarDate] = @CurrentDate)
			--		)
			--	)
			ELSE
				''190001''
		END
		
		IF(@CalendarDateFinancialPeriodValue = @CurrentFinancialPeriodValue)
			SET @ReturnValue = 1
		ELSE
			SET @ReturnValue = 0
			*/
		RETURN 0 --@ReturnValue

END' 
END
GO
