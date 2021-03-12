SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[TransformStringByExpandTabs]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =================================================
-- Expand Tabs in a string
-- =================================================
-- Returns a copy of @String where all tab characters 
-- are expanded using spaces.
CREATE FUNCTION [string].[TransformStringByExpandTabs]
   (
    @String VARCHAR(MAX),
    @tabsize INT = NULL
   )
RETURNS VARCHAR(MAX)
AS BEGIN
      SELECT   @tabsize = COALESCE(@tabsize, 4)
      IF @string IS NULL 
         RETURN NULL
      DECLARE @OriginalString VARCHAR(MAX),
         @DetabbifiedString VARCHAR(MAX),
         @Column INT,
         @Newline INT
      SELECT   @OriginalString = @String, @DeTabbifiedString = '''',
               @NewLine = 1, @Column = 1
      WHILE PATINDEX(''%['' + CHAR(9) + CHAR(10) + '']%'', @OriginalString) > 0
         BEGIN--do we need to expand tabs?
            IF CHARINDEX(CHAR(9), @OriginalString + CHAR(9)) 
                   > CHARINDEX(CHAR(10), @OriginalString + CHAR(10)) 
               BEGIN--we have to deal with a CR
                  SELECT   @NewLine = 1, @Column = 1,
                           @DeTabbifiedString = @DeTabbifiedString 
                             + SUBSTRING(@OriginalString, 
                                         1, 
                                         CHARINDEX(CHAR(10), @OriginalString)),
                           @OriginalString = STUFF(@OriginalString, 1,
                                                   CHARINDEX(CHAR(10), 
                                                          @OriginalString),'''')
               END
            ELSE 
               BEGIN--de-tabbifying
                  SELECT   @Column = @column 
                            + CHARINDEX(CHAR(9), 
                                    @OriginalString + CHAR(9)) - 1,
                            @DeTabbifiedString = @DeTabbifiedString 
                                 + SUBSTRING(@OriginalString, 1, 
                                             CHARINDEX(CHAR(9),@OriginalString)
                                              - 1)
                  SELECT   @DeTabbifiedString = @DeTabbifiedString 
                                      + SPACE(@TabSize - (@column % @TabSize)),
                           @OriginalString = STUFF(@OriginalString, 1,
                                                   CHARINDEX(CHAR(09), 
                                                              @OriginalString),
                                                   '''')
                  SELECT   @Column = @Column + (@TabSize - (@column % @TabSize))
               END
         END
      RETURN @DeTabbifiedString + @Originalstring
   END
' 
END
GO
