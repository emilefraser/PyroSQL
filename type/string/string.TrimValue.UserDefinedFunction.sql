
CREATE OR ALTER FUNCTION 
string.[TrimValue](@String nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
	RETURN LTRIM(RTRIM(@String))
END
GO

/*
	SELECT dbo.[Trim]('                This is to be trimmed                    ')
*/
