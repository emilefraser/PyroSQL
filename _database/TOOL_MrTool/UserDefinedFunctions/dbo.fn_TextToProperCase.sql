SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:		Emile Fraser
-- Create date: 2020-02-22
-- =============================================
CREATE FUNCTION [dbo].[fn_TextToProperCase]
(
	@InputString NVARCHAR(MAX) 
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	DECLARE @Index INT
	DECLARE @Char CHAR(1)
	DECLARE @OutputString NVARCHAR(MAX)

	SET @InputString = LTRIM(RTRIM(@InputString))
	SET @OutputString = LOWER(@InputString)
	SET @Index = 1
	SET @OutputString = STUFF(@OutputString, 1, 1,UPPER(SUBSTRING(@InputString,1,1)))

	IF CAST(@InputString AS VARCHAR(MAX)) <> @InputString
	BEGIN 
		SET @OutputString = @InputString
	END
	
	ELSE
	BEGIN 
		WHILE @Index <= LEN(@InputString)
		BEGIN
			SET @Char = SUBSTRING(@InputString, @Index, 1)
			IF @Char IN ('m','M',' ', ';', ':', '!', '?', ',', '.', '_', '-', '/', '&','''','’','(',CHAR(9)) --CHAR(9) is a TAB
			BEGIN
				IF @Index + 1 <= LEN(@InputString)
				BEGIN
					IF (@Char IN ('''','’')) AND (UPPER(SUBSTRING(@InputString, @Index + 1, 1)) IN ('S'))
					BEGIN
						SET @OutputString = STUFF(@OutputString, @Index + 1, 1,LOWER(SUBSTRING(@InputString, @Index + 1, 1)))
					END
					ELSE
					BEGIN
						IF UPPER(@Char) = 'M' AND UPPER(SUBSTRING(@InputString, @Index + 1, 1)) = 'C'
						BEGIN
					
							IF UPPER(@Char) = 'M' AND UPPER(SUBSTRING(@InputString, @Index + 1, 1)) = 'C' AND (SUBSTRING(@InputString, @Index - 1, 1) = ' ')
							BEGIN
								SET @OutputString = STUFF(@OutputString, @Index + 1, 1,LOWER(SUBSTRING(@InputString, @Index + 1, 1)))
								SET @OutputString = STUFF(@OutputString, @Index + 2, 1,UPPER(SUBSTRING(@InputString, @Index + 2, 1)))
								SET @Index = @Index + 1
							END						
						END
						
						IF UPPER(@Char) != 'M'
						BEGIN
							SET @OutputString = STUFF(@OutputString, @Index + 1, 1,UPPER(SUBSTRING(@InputString, @Index + 1, 1)))
						END
					END
				END
			END

			SET @Index = @Index + 1

		END

		SET @OutputString = REPLACE(@OutputString,'  ',' ') --Replaces double spaces with a single space
		SET @OutputString = REPLACE(@OutputString,CHAR(9),' ') --Replaces a Tab with a single space
	
	END
	
	RETURN ISNULL(@OutputString,'')

END



GO
