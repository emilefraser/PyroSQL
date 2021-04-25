SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[GetStringBetweenDelimeters]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	Extracts part of a string between 2 delimiters
		@StringValue  - source character expression 
		@Delimeter_Start, @Delimeter_End - start and end delimiters
		@Flag - modifies function behavior:
				  2 - End delimiter not required. If it''''s not found returns the rest of the string
				  4 - Delimiters are included in result
		@IsTrimResult - Trims result if specified

	SELECT string.GetStringBetweenDelimeters(''The quick brown |>fox jumps<| over the lazy dog'', ''|>'', ''<|'', 2, 0)
	SELECT string.GetStringBetweenDelimeters(''The quick brown |>fox jumps<| over the lazy dog'', ''|>'', ''<|'', 2, 1)
	SELECT string.GetStringBetweenDelimeters(''The quick brown |>fox jumps<| over the lazy dog'', ''|>'', ''<|'', 4, 0)
	SELECT string.GetStringBetweenDelimeters(''The quick brown |>fox jumps<| over the lazy dog'', ''|>'', ''<|'', DEFAULT)
*/
CREATE   FUNCTION [string].[GetStringBetweenDelimeters] (
	@StringValue		VARCHAR(8000),
	@Delimeter_Start	VARCHAR(128),
	@Delimeter_End		VARCHAR(128),
	@Flag				INT				= 0,
	@IsTrimResult		BIT				= 0
)
									
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE 
		@Position_Start			INT
	,	@Position_End			INT
	,	@LengthDelimeter_Start	INT
	,	@LengthDelimeter_End	INT
	
	-- Initialized the ReturnValue
	DECLARE 
		@ReturnValue VARCHAR(8000)
	
	-- DATALENGTH() returns actual length including trailing spaces
	SET @LengthDelimeter_Start = COALESCE(DATALENGTH(@Delimeter_Start), 0)
	SET @LengthDelimeter_End   = COALESCE(DATALENGTH(@Delimeter_End), 0)

		-- If Start delimiter is empty or null, extract from the beginning of the string 
	IF (@LengthDelimeter_Start = 0)
	BEGIN		
		SET @Position_Start = 1
	END

	-- Find Start delimiter position in the string
	ELSE
	BEGIN
		SET @Position_Start = CHARINDEX(@Delimeter_Start, @StringValue)
	END


-- If we found the Start of Delimeter, then continue
	IF (@Position_Start > 0)
	BEGIN	
		-- Look for End delimiter position, If End delimiter is empty, extract to the end of the string 
		IF (@LengthDelimeter_End = 0)
		BEGIN
			SET @Position_End = DATALENGTH(@StringValue) 
		END

		-- Find End delimiter position in the string
		ELSE
		BEGIN
			SET @Position_End = CHARINDEX(@Delimeter_End, @StringValue, @Position_Start + 1) - 1

			-- The End delimiter is not found but delimeter end not passed, then we extract to the end of the string	
			IF (@Position_End <= 0) AND ((@flag & 2) > 0)
			BEGIN
				-- The End delimiter is not found but flag 2 is set extract to the end of the string	
				SET @Position_End = DATALENGTH(@StringValue) 
			END
		END
	END	
	
	-- We found both delimiters
	IF (@Position_Start > 0) AND (@Position_End > 0) AND (@Position_End > @Position_Start)
	BEGIN
		
		-- Flag 4 is not set, dont include Start delimiter into result
		IF (@flag & 4)  = 0
		BEGIN
			SET @Position_Start = @Position_Start + @LengthDelimeter_Start
		END

		-- Flag 4 is set, include End delimiter into result
		IF @Position_End < DATALENGTH(@StringValue)  AND (@flag & 4) > 0
		BEGIN
			SET @Position_End = @Position_End + @LengthDelimeter_End
		END	

		
		-- Extract substring 
		SET @ReturnValue = SUBSTRING(@StringValue, @Position_Start, @Position_End - @Position_Start + 1)

		IF(@IsTrimResult = 1)
		BEGIN
			SET @ReturnValue = LTRIM(RTRIM(@ReturnValue))
		END

	END

	-- One of the delimiters or both not found, return empty string
	ELSE
	BEGIN
		SET @ReturnValue = NULL
	END

	RETURN @ReturnValue

END

' 
END
GO
