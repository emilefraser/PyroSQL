CREATE OR ALTER FUNCTION string.RemoveNonAlphaCharacters (
    @inputString NVARCHAR(MAX)
  , @keepValues NVARCHAR(1000) = N'%[^a-z0-9]%'
  )
RETURNS NVARCHAR(MAX)
/*
SELECT dbo.udf_RemoveNonAlphaCharacters(N'Тестовая строка - Test string 123_456', N'%[^a-z0-9]%');
SELECT dbo.udf_RemoveNonAlphaCharacters(N'Тестовая строка - Test string 123_456', N'%[^3-9]%');
*/
AS
BEGIN
    WHILE PATINDEX(@keepValues, @inputString) > 0
      SET @inputString = STUFF(@inputString, PATINDEX(@keepValues, @inputString), 1, '');

    RETURN @inputString;
END;
GO
