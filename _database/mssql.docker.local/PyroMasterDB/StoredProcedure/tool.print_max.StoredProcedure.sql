SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[print_max]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tool].[print_max] AS' 
END
GO
/* https://weblogs.asp.net/bdill/sql-server-print-max
exec util.print_max 'atetew tewtew'
*/
ALTER  PROCEDURE [tool].[print_max](@iInput NVARCHAR(MAX) ) 
AS
BEGIN
    IF @iInput IS NULL
    RETURN;
    DECLARE @ReversedData NVARCHAR(MAX)
          , @LineBreakIndex INT
          , @SearchLength INT;
    SET @SearchLength = 4000;
    WHILE LEN(@iInput) > @SearchLength
    BEGIN
		SET @ReversedData = LEFT(@iInput COLLATE DATABASE_DEFAULT, @SearchLength);
		SET @ReversedData = REVERSE(@ReversedData COLLATE DATABASE_DEFAULT);
		SET @LineBreakIndex = CHARINDEX(CHAR(10) + CHAR(13),
							  @ReversedData COLLATE DATABASE_DEFAULT);
		PRINT LEFT(@iInput, @SearchLength - @LineBreakIndex + 1);
		SET @iInput = RIGHT(@iInput, LEN(@iInput) - @SearchLength 
							+ @LineBreakIndex - 1);
    END;
    IF LEN(@iInput) > 0
    PRINT @iInput;
END












GO
