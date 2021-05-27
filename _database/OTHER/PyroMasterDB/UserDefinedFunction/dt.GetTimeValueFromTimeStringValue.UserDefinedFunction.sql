SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt].[GetTimeValueFromTimeStringValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*	
	CREATED BY	: Emile Fraser
	DATE		: 2020-10-20
	DESCRIPTION	: Converts a time string to a time sql format
*/
CREATE   FUNCTION [dt].[GetTimeValueFromTimeStringValue] (
	@TimeStringValue NVARCHAR(6)
)
RETURNS TIME
AS 
BEGIN
	RETURN
		DATEADD(HOUR, (@TimeStringValue / 10000) % 100,
			DATEADD(MINUTE, (@TimeStringValue / 100) % 100,
				DATEADD(SECOND, (@TimeStringValue / 1) % 100,
					CAST(''00:00:00'' AS TIME(0))
				)
			)
		) 
END
' 
END
GO
