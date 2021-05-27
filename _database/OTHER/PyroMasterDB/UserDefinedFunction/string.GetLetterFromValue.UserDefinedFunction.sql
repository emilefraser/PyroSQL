SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[GetLetterFromValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE   FUNCTION [string].[GetLetterFromValue](
	@LetterValueIndex	SMALLINT
,	@IsUpperCase		BIT = 0
)
RETURNS VARCHAR(1)
AS
BEGIN
	RETURN 
		CASE 
			WHEN @LetterValueIndex NOT BETWEEN 1 AND 26
				THEN ''#''
			WHEN @IsUpperCase = 1
				THEN UPPER(CHAR(97 + @LetterValueIndex - 1))
			ELSE
				CHAR(97 + @LetterValueIndex - 1)
		END
END
' 
END
GO
