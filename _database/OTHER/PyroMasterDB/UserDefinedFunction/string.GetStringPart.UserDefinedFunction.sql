SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[GetStringPart]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
SELECT string.GetStringPart(''schema.table|schema1.table1|schema2.table2|schema3.table3'', ''|'', 1)
*/
CREATE   FUNCTION [string].[GetStringPart] (
	@FullTextString		VARCHAR(MAX)
,	@Delimiter			VARCHAR(10)
,	@PartNumber			SMALLINT
)
RETURNS VARCHAR(8000)
AS

BEGIN
	DECLARE	@NextPos SMALLINT,
		@LastPos SMALLINT,
		@Offset TINYINT = DATALENGTH(@Delimiter),
		@Found SMALLINT;

	IF @PartNumber > 0
		SELECT	@FullTextString = REVERSE(@FullTextString),
			@Delimiter = REVERSE(@Delimiter);

	SELECT	@NextPos = CHARINDEX(@Delimiter, @FullTextString, 1),
		@LastPos = 1 - @Offset,
		@Found = 1

	WHILE @NextPos > 0 AND ABS(@PartNumber) <> @Found
		SELECT	@LastPos = @NextPos,
			@NextPos = CHARINDEX(@Delimiter, @FullTextString, @NextPos + @Offset),
			@Found = @Found + 1;

	RETURN	CASE
			WHEN @Found <> ABS(@PartNumber) OR @PartNumber = 0 THEN NULL
			WHEN @PartNumber > 0 THEN REVERSE(SUBSTRING(@FullTextString, @LastPos + @Offset, CASE WHEN @NextPos = 0 THEN DATALENGTH(@FullTextString) - @LastPos ELSE @NextPos - @LastPos - @Offset END))
			ELSE SUBSTRING(@FullTextString, @LastPos + @Offset, CASE WHEN @NextPos = 0 THEN DATALENGTH(@FullTextString) - @LastPos ELSE @NextPos - @LastPos - @Offset END)
		END
END' 
END
GO
