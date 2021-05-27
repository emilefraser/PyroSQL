SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[array]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[array]
-- =================================================
-- array Function
-- =================================================
-- This function returns an XML version of a list with
-- the sequence number and the value of each element
-- as an XML fragment
-- Parameters
-- array() takes a varchar(max) list with whatever delimiter you wish. The
-- second value is the delimiter
   (
    @StringArray VARCHAR(8000),
    @Delimiter VARCHAR(10) = '',''
    
   )
RETURNS XML
AS BEGIN
      DECLARE @results TABLE
         (
           seqno INT IDENTITY(1, 1),-- the sequence is meaningful here
           Item VARCHAR(MAX)
         )
      DECLARE @Next INT
      DECLARE @lenStringArray INT
      DECLARE @lenDelimiter INT
      DECLARE @ii INT
      DECLARE @xml XML
 
      SELECT   @ii = 0, @lenStringArray = LEN(REPLACE(@StringArray, '' '', ''|'')),
               @lenDelimiter = LEN(REPLACE(@Delimiter, '' '', ''|''))
 
      WHILE @ii <= @lenStringArray + 1--while there is another list element
         BEGIN
            SELECT   @next = CHARINDEX(@Delimiter, @StringArray + @Delimiter,
                                       @ii)
             INSERT   INTO @Results
                     (Item)
                     SELECT   SUBSTRING(@StringArray, @ii, @Next - @ii)
             SELECT   @ii = @Next + @lenDelimiter
         END    
      SELECT   @xml = ( SELECT seqno,
                             item
                     FROM   @results
                   FOR
                     XML PATH(''element''),
                         TYPE,
                         ELEMENTS,
                         ROOT(''stringarray'')
                   )
      RETURN @xml
   END
 
' 
END
GO
