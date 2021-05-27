SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[CamelCaseFieldName_To_SpaceInclusiveNames]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
----USE [InfoMart]
----GO

----/****** Object:  Schema [INTEGRATION]    Script Date: 2019/11/14 4:26:01 PM ******/
----CREATE SCHEMA [INTEGRATION]
----GO
----/****** Object:  UserDefinedFunction [dbo].[CamelCaseFieldName_To_SpaceInclusiveNames]    Script Date: 2019/11/14 4:26:01 PM ******/
----SET ANSI_NULLS ON
----GO
----SET QUOTED_IDENTIFIER ON
----GO

CREATE   FUNCTION [string].[CamelCaseFieldName_To_SpaceInclusiveNames] (
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
	,   @returnValue = ''''

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
					@cp <> '' ''
				AND 
					@c0 <> '' ''
				)
		   BEGIN
				SET @returnValue = @returnValue + '' ''
		   END -- IF Inner
		END -- IF Outer

		SET @returnValue = @returnValue + @c0
		SET @i = @i + 1

		END -- WHILE

	RETURN @returnValue

END

' 
END
GO
