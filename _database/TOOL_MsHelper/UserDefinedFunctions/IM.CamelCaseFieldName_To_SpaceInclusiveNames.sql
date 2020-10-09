SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   FUNCTION IM.[CamelCaseFieldName_To_SpaceInclusiveNames] (
    @fieldName VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE
		@i INT, @j INT
	,   @cp NCHAR, @c0 NCHAR, @c1 NCHAR
	,   @returnValue VARCHAR(MAX)

	SELECT
		@i = 1
	,   @j = LEN(@fieldName)
	,   @returnValue = ''

	WHILE @i <= @j
	BEGIN
		SELECT
			@cp = SUBSTRING(@fieldName,@i-1,1)
		,   @c0 = SUBSTRING(@fieldName,@i+0,1)
		,   @c1 = SUBSTRING(@fieldName,@i+1,1)

		IF (@c0 = UPPER(@c0) COLLATE Latin1_General_CS_AS)
		BEGIN
			IF 
				(@c0 = UPPER(@c0) COLLATE Latin1_General_CS_AS)
			AND 
				(@cp <> UPPER(@cp) COLLATE Latin1_General_CS_AS)
			OR  (
					@c1 <> UPPER(@c1) COLLATE Latin1_General_CS_AS
				AND 
					@cp <> ' '
				AND 
					@c0 <> ' '
				)
		   BEGIN
				SET @returnValue = @returnValue + ' '
		   END -- IF Inner
		END -- IF Outer

		SET @returnValue = @returnValue + @c0
		SET @i = @i + 1

		END -- WHILE

	RETURN @returnValue

END

GO
