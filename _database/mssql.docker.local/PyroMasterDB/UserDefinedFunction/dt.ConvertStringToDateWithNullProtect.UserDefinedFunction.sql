SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt].[ConvertStringToDateWithNullProtect]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- SELECT [dt].[ConvertStringDateToDateWithNullProtect](''2021/02/05'')
-- SELECT [dt].[ConvertStringDateToDateWithNullProtect](''1900/01/01'')
CREATE         FUNCTION [dt].[ConvertStringToDateWithNullProtect] (
	@StringDate NVARCHAR(10)
)
RETURNS DATE
WITH SCHEMABINDING
AS
BEGIN
   RETURN 
	CASE WHEN @StringDate = ''1900/01/01''
			THEN CONVERT(DATE, ''1900-01-01'')
		 WHEN @StringDate = ''00000000''
			THEN CONVERT(DATE, ''1900-01-01'')
		WHEN @StringDate = ''1900-01-01''
			THEN CONVERT(DATE, ''1900-01-01'')
			ELSE CONVERT(DATE, @StringDate)
		END
END' 
END
GO
