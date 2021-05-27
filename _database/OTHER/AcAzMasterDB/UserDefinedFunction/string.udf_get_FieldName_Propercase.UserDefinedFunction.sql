SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[udf_get_FieldName_Propercase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE   FUNCTION [string].[udf_get_FieldName_Propercase] (
	@FieldName AS SYSNAME
) 
RETURNS VARCHAR(MAX)
BEGIN
    DECLARE @Reset BIT
	DECLARE @Return_Value VARCHAR(MAX)
	DECLARE @i INT
	DECLARE @c CHAR(1)

IF @FieldName IS NULL 
	RETURN NULL

SELECT
    @Reset = 1,
    @i = 1,
    @Return_Value = ''''

WHILE (@i <= LEN(@FieldName)) 
	SELECT
		@c = SUBSTRING(@FieldName, @i, 1)
	,	@Return_Value = @Return_Value + 
						CASE
							WHEN
								@Reset = 1 
							THEN
								UPPER(@c) 
							ELSE
								LOWER(@c) 
						END
	,	@Reset = 
				CASE
					WHEN
						@c LIKE ''[a-zA-Z]'' 
					THEN
						0 
					ELSE
						1 
				END
	,	@i = @i + 1 


RETURN REPLACE(@Return_Value , ''_'', '' '')

END

' 
END
GO
