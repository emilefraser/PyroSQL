SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[SplitVarcharToTableAlternative]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE   FUNCTION [string].[SplitVarcharToTableAlternative]
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
DECLARE @Splitpoint INT
DECLARE @lenDelimiter INT
 
--initialise everything
SELECT @lenDelimiter=LEN(REPLACE(@Delimiter,'' '',''|''))
--notice we have to be cautious about LEN with trailing spaces!
 
--while there is more of the string
WHILE 1=1
       BEGIN
       SELECT @splitpoint=CHARINDEX(@Delimiter,@StringArray)
       IF @SplitPoint=0
               BEGIN
               INSERT INTO @Results (Item) SELECT @StringArray
               BREAK
               END
       INSERT INTO @Results (Item)
               SELECT LEFT(@StringArray,@Splitpoint-1)
       --use STUFF to delete the first x characters of the string!
       SELECT @StringArray=
               STUFF(@StringArray,1,@Splitpoint+@lenDelimiter-1,'''')
       END
  RETURN
END' 
END
GO
