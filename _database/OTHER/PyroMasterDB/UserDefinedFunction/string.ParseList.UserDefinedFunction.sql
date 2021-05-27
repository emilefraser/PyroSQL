SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[ParseList]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [string].[ParseList] (
	@StringList NVARCHAR(MAX)
,	@Delimiter	CHAR
)
RETURNS @Result TABLE (RowID SMALLINT IDENTITY(1, 1) PRIMARY KEY, Data VARCHAR(8000))
AS

BEGIN
	DECLARE	@NextPos INT,
		@LastPos INT

	SELECT	@NextPos = CHARINDEX(@Delimiter, @StringList, 1),
		@LastPos = 0

	WHILE @NextPos > 0
		BEGIN
			INSERT	@Result
				(
					Data
				)
			SELECT	SUBSTRING(@StringList, @LastPos + 1, @NextPos - @LastPos - 1)

			SELECT	@LastPos = @NextPos,
				@NextPos = CHARINDEX(@Delimiter, @StringList, @NextPos + 1)
		END

	IF @NextPos <= @LastPos
		INSERT	@Result
			(
				Data
			)
		SELECT	SUBSTRING(@StringList, @LastPos + 1, DATALENGTH(@StringList) - @LastPos)

	RETURN
END' 
END
GO
