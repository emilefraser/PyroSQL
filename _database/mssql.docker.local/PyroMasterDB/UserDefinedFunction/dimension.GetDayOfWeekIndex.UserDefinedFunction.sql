SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[GetDayOfWeekIndex]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- Metadata --
/* ========================================================================================================================
	Created by	:	Emile Fraser
	Dreated on	:	2020-06-30
	Description	:	Returns the start of the week value based on this table

					Value	First day of the week is
					1		Monday
					2		Tuesday
					3		Wednesday
					4		Thursday
					5		Friday
					6		Saturday
					7		Sunday
				
======================================================================================================================== */

-- Changelog & TODO --
/* =========================================================================================================================
	 2020-06-30	:		Created this function
	 2021-02-24 :		Changed the scalar function to just return the value
/* ========================================================================================================================*/
    
	DECLARE @FirstDayOfWeekName			VARCHAR(10)		= ''Monday''
	SELECT [dimension].[GetDayOfWeekIndex](@FirstDayOfWeekName)

======================================================================================================================== */
CREATE   FUNCTION [dimension].[GetDayOfWeekIndex] (
    @FirstDayOfWeekName VARCHAR(10)
)
RETURNS SMALLINT
AS
BEGIN
	RETURN CHARINDEX(UPPER(SUBSTRING(@FirstDayOfWeekName,1 ,3)), ''SUN MON TUE WED THU FRI SAT'')/ 4.00 + 1
END
' 
END
GO
