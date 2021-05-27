SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[CalculateOccurancesOfSubstringInString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =================================================
-- Count substring in string Function
-- =================================================
-- Returns the number of occurrences of substring sub 
-- in string s. allows you to specifying the start and
-- end position of the search
/*
SELECT   string.count(''The artistic temperament is something that afflicts amateurs'', ''[^a-z][a-z]'', NULL, NULL)
--wordcount (not include first word) 4
SELECT   string.count(''IT salesmen are sometimes so intellectually simple as to hide in packing cases or pretend to be their own aunts.'', ''[aeiou]'', NULL, NULL)
--37 vowels
SELECT   string.count(''45667892398'', ''8'', NULL, NULL)
--2
SELECT   string.count(''if something is worth doing, it is worth doing badly'', ''worth doing'', 17, 46)
--2
*/
CREATE FUNCTION [string].[CalculateOccurancesOfSubstringInString]
   (
    @string VARCHAR(MAX),
    @Sub VARCHAR(MAX),
    @start INT = NULL,
    @end INT = NULL
   )
RETURNS INT
AS BEGIN
      DECLARE @more INT
      DECLARE @count INT
      IF @string = NULL 
         RETURN NULL
      SELECT   @count = 0, @more = 1, @Start = COALESCE(@Start, 1), @end = COALESCE(@end, LEN(@string))
      SELECT   @end = CASE WHEN @end > LEN(@string) THEN LEN(@string)
                           ELSE @end
                      END, @Start = CASE WHEN @start > LEN(@string) THEN LEN(@string)
                                         ELSE @start
                                    END
      WHILE @more <> 0
         BEGIN
            SELECT   @more = PATINDEX(''%'' + @sub + ''%'', SUBSTRING(@string, @Start, @End - @start + 1))
            IF @more > 0 
               SELECT   @Start = @Start + @more, @count = @count + 1
            IF @start >= @End 
               SELECT   @more = 0
         END
      RETURN @count
   END
' 
END
GO
