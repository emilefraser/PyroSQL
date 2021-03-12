SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt].[ConvertIntToDateTime]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE   FUNCTION [dt].[ConvertIntToDateTime] (
	@IntegerDate INT
)
RETURNS DATETIME
AS
BEGIN
   RETURN CONVERT(DATETIME, CAST(@IntegerDate AS CHAR(8)), 101)
END' 
END
GO
