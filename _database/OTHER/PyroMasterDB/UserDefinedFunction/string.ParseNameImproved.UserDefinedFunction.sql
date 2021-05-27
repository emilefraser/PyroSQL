SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[ParseNameImproved]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	SELECT string.ParseNameImproved (''aaa|bbb|ccc'', ''|'', 1)
*/
CREATE   FUNCTION [string].[ParseNameImproved] (
	@StringValue	NVARCHAR(MAX)
,	@Delimiter		CHAR
,	@ReturnPart		INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	--RETURN right(REPLACE(@StringValue, charindex(''.'', reverse(@StringValue), 1) - 1)
	--RETURN CHARINDEX(''.'', REVERSE(REPLACE(@StringValue, @Delimiter, ''.'')))
	--PARSENAME(REPLACE(@StringValue, @Delimiter, ''.''), @ReturnPart)
	-- Gets the nth Delimiter

	-- Gets the nth Delimeter - 1

	-- Substring in between

	RETURN right(REPLACE(@StringValue, @Delimiter, ''.''), charindex(''.'', reverse(REPLACE(@StringValue, @Delimiter, ''.'')), 1) - 1)
	
END' 
END
GO
