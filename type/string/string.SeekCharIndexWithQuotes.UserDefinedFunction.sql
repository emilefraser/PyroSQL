CREATE OR ALTER FUNCTION CharIndexWithQuotes (
	@ExpressionToSearch VARCHAR(8000), 
									@ExpressionToFind VARCHAR(255) = ',', 
									@QuotesOn Bit = 0
									)
RETURNS INT
AS
BEGIN
	IF @QuotesOn = 0 OR LEFT(@ExpressionToSearch, 1) <> '"' 
		   CHARINDEX(@ExpressionToFind, @ExpressionToSearch)
	
	DECLARE @vEndQuotePosition Int 
	SET @vEndQuotePosition = NULLIF(CHARINDEX('"', @ExpressionToSearch, 2),0)

	RETURN CHARINDEX(@ExpressionToFind, @ExpressionToSearch, Coalesce(@vEndQuotePosition, LEN(@ExpressionToSearch)))
END
GO
