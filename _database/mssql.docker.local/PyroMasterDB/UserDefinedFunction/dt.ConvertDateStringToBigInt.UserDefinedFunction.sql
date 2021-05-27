SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt].[ConvertDateStringToBigInt]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dt].[ConvertDateStringToBigInt] (
	@DateString NVARCHAR(50)
)
RETURNS BIGINT 
WITH SCHEMABINDING
AS
BEGIN
	declare @datedt datetime = (select convert(datetime, TRIM(SUBSTRING(@DateString,5,6)) + '' '' + SUBSTRING(@DateString, len(@DateString) - 1, 2) + '' '' + SUBSTRING(@DateString, 12, 8)))

	RETURN (
		SELECT 
           DATEPART(YEAR, @datedt) * 10000000000 +
           DATEPART(MONTH, @datedt) * 100000000 +
           DATEPART(DAY, @datedt) * 1000000 +
           DATEPART(HOUR, @datedt) * 10000 +
           DATEPART(MINUTE, @datedt) * 100 +
           DATEPART(SECOND, @datedt)
	)

end

' 
END
GO
