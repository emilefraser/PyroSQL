SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt].[ConvertDateTimeToTimeStampWithNullProtect]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- SELECT  [infomart].[ConvertDateTimeToTimeStampWithNullProtect](''2021-02-14 12:25:32'')
CREATE FUNCTION [dt].[ConvertDateTimeToTimeStampWithNullProtect] (
	@DateTimeValue DATETIME
)
RETURNS BIGINT
WITH SCHEMABINDING
AS
BEGIN
   RETURN 
	CASE WHEN @DateTimeValue = ''1900-01-01 00:00:00''
			THEN 19000101000000
			ELSE CONVERT(BIGINT, 
					CONCAT(
						FORMAT(CONVERT(DATETIME, @DateTimeValue), ''yyyyMMdd''),
						FORMAT(CONVERT(DATETIME, @DateTimeValue), ''hhmmss'')
					)
				)
		END
END
' 
END
GO
