SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[ConvertIntToDateTimeWithNullProtect]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

-- Created By: Emile Fraser
-- Date: 2020-09-09
-- Converts a date in integer formate (20200909) to a DateTime Value
-- INCLUDES NULL PROTECTION FOR 0
-- SELECT [tool].[ConvertIntToDateTimeWithNullProtect](0)
CREATE   FUNCTION [tool].[ConvertIntToDateTimeWithNullProtect] (
	@IntegerDate INT
)
RETURNS DATETIME
WITH SCHEMABINDING
AS
BEGIN
   RETURN 
	CASE WHEN @IntegerDate = 0
			THEN CONVERT(DATETIME, ''1900-01-01'', 101)
			ELSE CONVERT(DATETIME, CAST(@IntegerDate AS CHAR(8)), 101)
		END
END
' 
END
GO
