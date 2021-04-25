SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[array].[ConvertArrayToXml]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	Written By: Emile Fraser
	Date: 2021-04-01
	Converts a list into a SQL Server Array type

	Usage Samples:
	SELECT   [array].[ConvertArrayToXml](''man,woman,boy,girl'', '','')
	SELECT   [array].[ConvertArrayToXml](''one,two,three,four,five,six,seven,eight,nine,ten'', '','')
*/
CREATE   FUNCTION [array].[ConvertArrayToXml]  (
    @StringArray VARCHAR(8000),
    @Delimiter VARCHAR(10) = '',''
)
RETURNS XML
AS 
BEGIN

	DECLARE @results TABLE (
        seqno INT IDENTITY(1, 1),
        Item VARCHAR(MAX)
    )

	DECLARE 
		@Next			INT
	,	@lenStringArray INT
	,	@lenDelimiter	INT
	,	@ii				INT
	,	@xml			XML

	SELECT
		@ii				= 0
	  , @lenStringArray = LEN(REPLACE(@StringArray, '' '', ''|''))
	  , @lenDelimiter   = LEN(REPLACE(@Delimiter, '' '', ''|''))

	WHILE @ii <= @lenStringArray + 1--while there is another list element
	BEGIN
		SELECT
			@Next = CHARINDEX(@Delimiter, @StringArray + @Delimiter, @ii)

		INSERT INTO @results (
			Item
		)
		SELECT
			SUBSTRING(@StringArray, @ii, @Next - @ii)

		SELECT @ii = @Next + @lenDelimiter
	END

SELECT
	@xml = (
		SELECT
			seqno, Item
		FROM
			@results
		FOR
		XML
			PATH (''element''),
			TYPE,
			ELEMENTS,
			ROOT (''stringarray'')
	)

RETURN @xml

END
' 
END
GO
