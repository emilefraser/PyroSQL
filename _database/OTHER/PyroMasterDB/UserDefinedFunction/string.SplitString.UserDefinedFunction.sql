SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[SplitString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =================================================
-- Split Function 
-- =================================================
-- Return an array of the words in the string, using 
-- @delimiter as a delimiter. If @maxsplit is given, at 
-- most @maxsplit splits are done.
/*
--so now we test it out (The real test rig is longer and more boring)
SELECT  * FROM dbo.ArrayToTable(dbo.split(''If I wanted that c**p from you, 
I''''d squeeze your head'', NULL, NULL))
SELECT [string].[SplitString](''How come you always program when drunk?
Because I learned how to when drunk'', ''?'', NULL) 
SELECT [string].[SplitString](''This is the worst disaster to happen here since I arrived'' 
					,NULL, NULL) 
*/
CREATE   FUNCTION [string].[SplitString]
   (
    @String VARCHAR(8000),
    @Delimiter VARCHAR(255) = NULL,
    @MaxSplit INT = NULL
    
   )
RETURNS XML
AS BEGIN
      DECLARE @results TABLE
         (
          seqno INT IDENTITY(1, 1),
          Item VARCHAR(MAX)
         )
      DECLARE @xml XML,
         @HowManyDone INT, 	--index of current search
         @HowMuchToDo INT,--How much more of the string to do
         @StartOfSplit INT,
         @EndOfSplit INT,
         @SplitStartCharacters VARCHAR(255),
         @SplitEndCharacters VARCHAR(255),
         @ItemCharacters VARCHAR(255),
         @ii INT
 
      SELECT   @HowMuchToDo = LEN(@string), @HowManyDone = 0,
               @StartOfSplit = 100, @SplitEndCharacters = ''[a-z]'',
               @SplitStartCharacters = COALESCE(@Delimiter,
                                                ''[^-a-z'''']''),
               @EndOfSplit = LEN(@SplitStartCharacters), @ii = 1

      WHILE @StartOfSplit > 0--we have a delimiter left to do
         AND @HowMuchToDo > 0--there is more of the string to split
         AND @ii <= COALESCE(@MaxSplit, @ii)
         BEGIN --find the delimiter or the start of the non-word block
            SELECT @StartOfSplit = PATINDEX(''%'' + @SplitStartCharacters + ''%'',
                  RIGHT(@String,@HowMuchToDo) COLLATE Latin1_General_CI_AI) 
                              
            IF @StartOfSplit > 0--if there is a non-word block
               AND @delimiter IS NULL 
               SELECT   @EndOfSplit = --find the next word
					PATINDEX(''%'' + @SplitEndCharacters + ''%'',
                    RIGHT(@string,@HowMuchToDo- @startOfSplit)
					COLLATE Latin1_General_CI_AI)
                                                                                 
            IF @StartOfSplit > 0--if there is a non-word block or delimiter 
               AND @ii < COALESCE(@MaxSplit, @ii + 1) --and there is a field
				--still to do
               INSERT   INTO @Results (item)
                        SELECT   LEFT(RIGHT(@String, @HowMuchToDo),
                                      @startofsplit - 1)
            ELSE --if not then save the rest of the string
               INSERT   INTO @Results (item)
                        SELECT   RIGHT(@String, @HowMuchToDo)
                                        
            SELECT   @HowMuchToDo = @HowMuchToDo - @StartOfSplit
                     - @endofSplit + 1, @ii = @ii + 1	
         END

--now we simply output the temporary table variable as XML
-- using our standard string-array format
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
