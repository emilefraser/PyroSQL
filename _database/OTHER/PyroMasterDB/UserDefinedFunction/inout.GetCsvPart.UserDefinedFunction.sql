SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[GetCsvPart]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [inout].[GetCsvPart] (
	@csv      VARCHAR(8000)
  , @index    TINYINT
  , @last     BIT           = 0) 
RETURNS VARCHAR(4000)
AS

	/* function to retrieve 0 based "column" from csv string */
	BEGIN
		DECLARE 
			@i    INT;
		SET @i = 0;
		WHILE 1 = 1
		BEGIN
			IF @index = 0
			BEGIN
				IF @last = 1
				   OR CHARINDEX('','', @csv, @i + 1) = 0
				BEGIN
					RETURN SUBSTRING(@csv, @i + 1, LEN(@csv) - @i + 1);
				END
					ELSE
				BEGIN
					RETURN SUBSTRING(@csv, @i + 1, CHARINDEX('','', @csv, @i + 1) - @i - 1);
				END;
			END;
			SELECT 
				@index = @index - 1
			  , @i = CHARINDEX('','', @csv, @i + 1);
			IF @i = 0
			BEGIN
				BREAK
			END;
		END;
		RETURN NULL;
	END;' 
END
GO
