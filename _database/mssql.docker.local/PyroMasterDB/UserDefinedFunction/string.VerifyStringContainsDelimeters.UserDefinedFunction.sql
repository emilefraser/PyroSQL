SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[VerifyStringContainsDelimeters]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	Extracts part of a string between 2 delimiters
		@StringValue  - source character expression 
		@Delimeter_Start, @Delimeter_End - start and end delimiters

	SELECT string.VerifyStringContainsDelimeters(''The quick brown fox jumps over the lazy dog'', ''fox'', ''dog'')
	SELECT string.VerifyStringContainsDelimeters(''The quick brown fox jumps over the lazy dog'', ''fox'', ''dog'')
	SELECT string.VerifyStringContainsDelimeters(''The quick brown fox jumps over the lazy dog'', ''fox'', ''dogma'')
	SELECT string.VerifyStringContainsDelimeters(''The quick brown fox jumps over the lazy dog'', ''fox'', ''quick'')
*/
CREATE   FUNCTION [string].[VerifyStringContainsDelimeters] (
	@StringValue		VARCHAR(8000)
,	@Delimeter_Start	VARCHAR(128)	= NULL
,	@Delimeter_End		VARCHAR(128)	= NULL
)					
RETURNS BIT
AS
BEGIN
	DECLARE 
		@Position_Start					INT
	,	@Position_End					INT
	,	@LengthDelimeter_Start			INT
	,	@LengthDelimeter_End			INT
	
	-- Initialized the ReturnValue
	DECLARE 
		@ReturnValue					BIT	= 0
	

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
			IF (@Position_End <= 0) AND (@Delimeter_End IS NULL)
			BEGIN
				SET @Position_End = DATALENGTH(@StringValue) 
			END
		END
	END	
	
	-- If we found both delimeters and end > start
	IF (@Position_Start > 0) AND (@Position_End > 0) AND (@Position_End > @Position_Start)
	BEGIN
		SET @ReturnValue = 1
	END

	RETURN @ReturnValue

END
' 
END
GO
