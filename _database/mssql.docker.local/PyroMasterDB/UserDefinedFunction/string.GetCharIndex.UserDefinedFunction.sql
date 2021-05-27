SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[GetCharIndex]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	SELECT string.[GetCharIndex](''a'', ''abbabba'', 3) -- 8
*/
CREATE   FUNCTION [string].[GetCharIndex] (
	@FindString			VARCHAR(8000)
  , @InString			VARCHAR(8000)
  , @OccurrenceNumber     INT
 ) 
RETURNS INT
AS
	BEGIN

		DECLARE 
			@pos        INT
		  , @counter    INT
		  , @ret        INT;

		SET @pos = CHARINDEX(@FindString, @InString);
		SET @counter = 1;

		IF @OccurrenceNumber = 1
		BEGIN
			SET @ret = @pos;
		END
			ELSE
		BEGIN

			WHILE(@counter < @OccurrenceNumber)
			BEGIN

				SELECT 
					@ret = CHARINDEX(@FindString, @InString, @pos + 1);

				SET @counter = @counter + 1;

				SET @pos = @ret;
			END;
		END;

		RETURN(@ret);
	END;' 
END
GO
