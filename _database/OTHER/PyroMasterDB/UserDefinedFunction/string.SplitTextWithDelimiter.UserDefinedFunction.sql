SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[SplitTextWithDelimiter]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
Purpose: Split text on a common char. 
Design Notes:
1) Will trim leading/trailing white space from items.
2) Will omit blank and null items.
3) Compatible from SQL 2005 and onward (see details about [item_int] in return table)
4) Return table item is nvarchar(max) (not bound by string length)
5) Reasonably durable with escape sequences, so if a delimiter has a [,%,_ in it, the patter should still match.
6) Uses a sliding search window, not saving the remaining text on each iteration.  However, 
   saving each item in a temp variable (@item) was faster than using a CTE to temporarily 
   store the value, which surprised me.
7) Returns the value as an int as well, which is a common use for this function (splitting comma 
   separated lists of ints).  Note that this should be low impact in that if you don''t query 
   against that column since it is a non-persistent computed column (i.e. low overhead).
8) Supports @Delimiter > 1 char, but slower.  Note in the unit tests, with text of approximately 
   10K, 1 char is about 30% faster, hence the big IF block in the code.  Plus, the multi-char 
   delimiter does not scale terribly well. The test with 100,000 records, a 1 char delimiter takes 
   about 6 seconds while with a 5 char delimiter took 430 seconds (7 minutes!).  As such, try to 
   replace your multi char delimiters with a single char value before calling this function.  
   Side Note: For what it''s worth, I did try an alternative method of saving the remaining 
   "working text" as a sub string of text so the search would get faster near the end, but overall 
   it was slower at about 500 seconds.
*/
/*
{{##
	(WrittenBy)		Emile Fraser
	(CreatedDate)	2021-01-22
	(ModifiedDate)	2021-01-22
	(Description)	Creates a Dynamic SQL Insert Statement

	(Usage)	
					SELECT * FROM [template].[ObjectName] (@Parameter1, @Parameter2)
	(/Usage)
##}}
*/

CREATE   FUNCTION [string].[SplitTextWithDelimiter] (
	@Text nvarchar(max),			-- Text to split
	@Delimiter nvarchar(1000)		-- Value to split on, try to only pass a single char. See notes for details.
)
RETURNS @retTable TABLE 
(
	-- Output table definition
	[item] nvarchar(max) COLLATE DATABASE_DEFAULT NOT NULL,
	[item_int] AS (
					CAST(
						CASE 
							WHEN LEN(item) > 11 THEN NULL  -- LEN OF (-2147483648) is 11.  Simple out of bounds checking.
							WHEN ISNUMERIC([item]) = 1 AND [item] NOT LIKE ''%.%'' THEN [item] -- Ensure value conforms to int
							ELSE null
						END 
					AS INT)
	)
) 
WITH SCHEMABINDING
AS
BEGIN 
	-- Garbage in, Garbage out.  If they did not pass input data, return nothing.
	IF RTRIM(ISNULL(@Text,'''')) = '''' OR RTRIM(ISNULL(@Delimiter,'''')) = ''''
		RETURN

	DECLARE
	   @ix bigint -- Current index
	 , @pix bigint -- Previous index
	 , @del_len int -- Delimiter length
	 , @text_len bigint -- Input text length
	 , @item nvarchar(max) -- Temp item buffer.  I tried w/o using CTEs, but this way was faster

	SELECT @del_len = LEN(@Delimiter)
		 , @text_len = LEN(@Text)

	IF @del_len = 1
	BEGIN -- CHARINDEX MODE (Much faster than PATINDEX mode)
		SELECT @ix = CHARINDEX(@Delimiter, @Text) -- TODO: If you want to implment Case Insensitivity here, wrap both in LOWER()
			 , @pix = 0
	
		-- No delim found, just return the passed value, trimmed
		IF @ix = 0
		BEGIN
			INSERT INTO @retTable(item) 
				SELECT LTRIM(RTRIM(@Text)) -- We know this is not null because of the first GIGO check above
		END
		ELSE
		BEGIN
			-- Find most of the matches
			WHILE @ix > 0
			BEGIN
				SELECT 
					-- Get the current value
					  @item = LTRIM(RTRIM(SUBSTRING(@Text,@pix,(@ix - @pix)))) 
					-- Move previous pointer to end of last found delimiter
					, @pix = @ix + @del_len 
					-- And update the values for next pass though the loop, finding the next match
					, @ix = CHARINDEX(@Delimiter, @Text, (@ix + @del_len)) -- TODO: If you want to implment Case Insensitivity here, wrap both in LOWER()
				
				IF @item <> '''' AND @item IS NOT NULL -- Only save non empty values
					INSERT INTO @retTable(item) VALUES (@item)
			END

			-- Get the trailing text
			SET @item = LTRIM(RTRIM(SUBSTRING(@Text,@pix,@text_len)))
			IF @item <> '''' AND @item IS NOT NULL  -- Only save non empty values
				INSERT INTO @retTable(item) VALUES (@item)
		END --  @ix = 0
	END
	ELSE -- @del_len = 1
	BEGIN -- PATINDEX Mode (SLOW!) Try to pass in text that uses single char delimeters when possible

		DECLARE @del_pat nvarchar(3002)  -- Assume 3x @Delimiter + 2, for escaping every character plus wrapper %

		-- Escape characters that will mess up the like clause, and wrap in wild cards %
		SELECT @del_pat = ''%'' + REPLACE(REPLACE(REPLACE(@Delimiter
				, ''['',''[[]'')
				, ''%'',''[%]'')
				, ''_'', ''[_]'') 
			+ ''%''

		SELECT @ix = PATINDEX(@del_pat, @Text) -- TODO: If you want to implment Case Insensitivity here, wrap both in LOWER()
			 , @pix = 0
	
		-- No delim found, just return the passed value, trimmed
		IF @ix = 0
		BEGIN
			INSERT INTO @retTable(item) 
				SELECT LTRIM(RTRIM(@Text)) -- We know this is not null because of the first GIGO check above
		END
		ELSE
		BEGIN
			-- Find most of the matches
			WHILE @ix > 0
			BEGIN
				SELECT 
					-- Get the curent Item
					@item = LTRIM(RTRIM(SUBSTRING(@Text,@pix,(@ix - @pix))))
					-- Move the previous index to the end of the previous delimiter
					, @pix = @ix + @del_len 
					-- And set values for next itteration of the loop, finding the next match
					, @ix = PATINDEX(@del_pat, SUBSTRING(@Text, (@ix + @del_len), @text_len)) -- TODO: If you want to implment Case Insensitivity here, wrap both in LOWER()

				IF @item <> '''' AND @item IS NOT NULL  -- Only save non empty values
					INSERT INTO @retTable(item) VALUES (@item)

				IF @ix > 0 SET @ix = ((@ix + @pix) - 1) -- -1 since PatIndex is 1 based and Substring is 0 based
			END

			-- Get the trailing text
			SET @item = LTRIM(RTRIM(SUBSTRING(@Text,@pix,@text_len)))
			IF @item <> '''' AND @item IS NOT NULL  -- Only save non empty values
				INSERT INTO @retTable(item) VALUES (@item)
		END --  @ix = 0
	END -- @del_len = 1

	RETURN
END

' 
END
GO
