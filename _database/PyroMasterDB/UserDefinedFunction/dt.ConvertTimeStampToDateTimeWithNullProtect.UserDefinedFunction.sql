SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt].[ConvertTimeStampToDateTimeWithNullProtect]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

-- Created By: Emile Fraser
-- Date: 2020-09-09
-- Converts a date in integer formate (20200909) to a DateTime Value
-- INCLUDES NULL PROTECTION FOR 0
-- SELECT [infomart].[ConvertTimeStampToDateTimeWithNullProtect](''20191107124015'')
CREATE       FUNCTION [dt].[ConvertTimeStampToDateTimeWithNullProtect] (
	@IntegerDate BIGINT
)
RETURNS DATETIME2(7)
WITH SCHEMABINDING
AS
BEGIN
   RETURN 
	CASE WHEN @IntegerDate = 0
			THEN CONVERT(DATETIME2(7), ''1900-01-01'', 101)
			ELSE DATEADD(SECOND,CONVERT(INT,SUBSTRING(CAST(@IntegerDate AS CHAR(14)),13,2)),
					DATEADD(MINUTE, CONVERT(INT, SUBSTRING(CAST(@IntegerDate AS CHAR(14)),11,2)),
						DATEADD(HOUR, CONVERT(INT,SUBSTRING(CAST(@IntegerDate AS CHAR(14)),9,2)),
							CONVERT(DATETIME2(7),SUBSTRING(CAST(@IntegerDate AS CHAR(14)),1,8), 101)
						)
					)
				)
								
		END
END' 
END
GO
