SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[GetStringPartsWithDelimiter]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

-- =================================================
-- Parts string Function
-- =================================================

-- Split the string at the first occurrence of sep, and RETURN
-- an array containing the part before the separator, the 
-- separator itself, and the part after the separator. IF
-- the separator is not found, return an array containing
-- the string itself, followed by two empty strings. 

-- p.s. this is not part of the Python suite. It is used
-- to support Partition and RPartition
-- Again, Phil required calming down before he knuckled down
-- to write this, since he once swore he would never publish another
-- string splitting routine
/*
SELECT * FROM array.ConvertArrayToTable(dbo.parts(''IS your manager a bookworm? 
NO just an ordinary one'',''?'',0))
SELECT string.GetStringPartsWithDelimiter(''None of my team ever made a fool of me. 
well who was it then?'',''fool'',0)

*/
CREATE FUNCTION [string].[GetStringPartsWithDelimiter]
(
    @String VARCHAR(MAX),
    @sep VARCHAR(MAX),
    @Last INT=0 
)
RETURNS XML
AS BEGIN
DECLARE @SepPos INT,
@XML AS XML

      DECLARE @results TABLE
         (
          seqno INT IDENTITY(1, 1),
          -- the sequence is meaningful here
          Item VARCHAR(MAX)
         )
IF @last<>0
	SELECT @SepPos=dbo.rfind(@string,@sep,DEFAULT,DEFAULT)
ELSE
	SELECT @SepPos=CHARINDEX(@Sep,@string)

IF @SepPos>0
INSERT INTO @results(Item)
	SELECT LEFT(@String,@SepPos-1) 
	UNION ALL SELECT @Sep
	UNION ALL SELECT RIGHT(@String,LEN(@String)-@Seppos-LEN(@sep)+1)
ELSE
INSERT INTO @results(Item)
	SELECT @String
	UNION ALL SELECT ''''
	UNION ALL SELECT ''''
      SELECT   @xml = (SELECT seqno, item
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
