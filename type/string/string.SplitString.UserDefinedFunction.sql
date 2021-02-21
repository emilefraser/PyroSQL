CREATE OR ALTER.FUNCTION string.SplitString(
@String nvarchar(max), @Delimiter char(1), @WithOrder bit)
RETURNS @Result TABLE (Piece nvarchar(max), OrderNo int)
AS
BEGIN
	INSERT 
	INTO @Result
	(
	    Piece,
	    OrderNo
	)
	SELECT	value,
			CASE 
				WHEN @WithOrder = 0 THEN NULL
				ELSE ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP)
			END AS OrderNo
	FROM	STRING_SPLIT(@String, @Delimiter)

	RETURN
END
GO
