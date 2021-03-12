SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[ConvertIntToDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'


-- Created By: Emile Fraser
-- Date: 2020-09-09
-- Converts a date in integer formate (20200909) to a DateTime Value
CREATE   FUNCTION [tool].[ConvertIntToDate] (
	@IntegerDate BIGINT
)
RETURNS DATE
AS
BEGIN
   RETURN CONVERT(DATE, CAST(@IntegerDate AS CHAR(8)), 101)
END
' 
END
GO
