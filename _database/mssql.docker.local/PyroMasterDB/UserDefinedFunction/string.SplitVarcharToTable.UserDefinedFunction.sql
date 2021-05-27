SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[SplitVarcharToTable]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
CHARINDEX
Charindex provides a standard way of searching within strings to find a substring, and returning the starting position of the string. It has the added versatility of allowing you to specify the starting location of the search. This is especially useful in places where you must find all occurrences of a string. Consider the following simple routine which splits delimited strings (such as you might find in ''serialised'' data) into a table.
*/
/*
SELECT * FROMstring.SplitVarcharToTable(
''First|second|third|fourth|fifth|sixth'',''|'')
*/
CREATE     FUNCTION [string].[SplitVarcharToTable]
(
@StringArray VARCHAR(8000),
@Delimiter VARCHAR(10)
)
RETURNS
@Results TABLE
(
SeqNo INT IDENTITY(1, 1), Item VARCHAR(8000)
)
AS
BEGIN
DECLARE @Next INT
DECLARE @lenStringArray INT
DECLARE @lenDelimiter INT
DECLARE @ii INT
--initialise everything
SELECT @ii=1, @lenStringArray=LEN(REPLACE(@StringArray,'' '',''|'')),
@lenDelimiter=LEN(REPLACE(@Delimiter,'' '',''|''))
--notice we have to be cautious about LEN with trailing spaces!
 
--while there is more of the string…
WHILE @ii<=@lenStringArray
BEGIN--find the next occurrence of the delimiter in the stringarray
SELECT @next=CHARINDEX(@Delimiter,  @StringArray + @Delimiter, @ii)
INSERT INTO @Results (Item)
       SELECT SUBSTRING(@StringArray, @ii, @Next - @ii)
--note that we can get all the items from the list by appeending a
--delimiter to the final string
SELECT @ii=@Next+@lenDelimiter
END
RETURN
END' 
END
GO
