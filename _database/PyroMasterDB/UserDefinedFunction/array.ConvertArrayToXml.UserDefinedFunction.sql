SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[array].[ConvertArrayToXml]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
SELECT   [array].[ConvertArrayToXml](''tinker,tailor,soldier,sailor'', '','')

SELECT   @array = [array].[ConvertArrayToXml](''one,two,three,four,five,six,seven,eight,nine,ten'',
                           '','')
--now return the fourth one
SELECT   @array.query('' 
   for $ARRAY in /stringarray/element 
where $ARRAY/seqno = sql:variable("@seqno")  
   return 
     <element> 
      { $ARRAY/item } 
     </element> 
'') AS SingleElement 
*/
CREATE   FUNCTION [array].[ConvertArrayToXml]  (
    @StringArray VARCHAR(8000),
    @Delimiter VARCHAR(10) = '',''
)
RETURNS XML
AS 
BEGIN
      DECLARE @results TABLE
         (
          seqno INT IDENTITY(1, 1),
          Item VARCHAR(MAX)
         )
      DECLARE @Next INT
      DECLARE @lenStringArray INT
      DECLARE @lenDelimiter INT
      DECLARE @ii INT
      DECLARE @xml XML

SELECT
	@ii				= 0
  , @lenStringArray = LEN(REPLACE(@StringArray, '' '', ''|''))
  , @lenDelimiter   = LEN(REPLACE(@Delimiter, '' '', ''|''))

WHILE @ii <= @lenStringArray + 1--while there is another list element
BEGIN
SELECT
	@Next = CHARINDEX(@Delimiter, @StringArray + @Delimiter,
	@ii)
INSERT INTO
	@results (
		Item
	)
	SELECT
		SUBSTRING(@StringArray, @ii, @Next - @ii)
SELECT @ii = @Next + @lenDelimiter
END

SELECT
	@xml =
	(
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
