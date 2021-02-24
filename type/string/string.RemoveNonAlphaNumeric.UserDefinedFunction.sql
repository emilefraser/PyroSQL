CREATE  OR ALTER FUNCTION string.RemoveNonAlphaNumeric(@OriginalText VARCHAR(8000))
RETURNS VARCHAR(8000)
BEGIN
  DECLARE @CleanedText VARCHAR(8000)
  ;WITH Tally (N) as
    (SELECT TOP 10000 row_number() OVER (ORDER BY sc1.id)
     FROM Master.dbo.SysColumns sc1
     CROSS JOIN Master.dbo.SysColumns sc2)
  SELECT @CleanedText = ISNULL(@CleanedText,'') +
    CASE
      --ascii numbers are 48(for '0') thru 57 (for '9')
      WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 48 AND  57
      THEN SUBSTRING(@OriginalText,Tally.N,1)
      --ascii upper case letters A-Z is 65 thru 90
      WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 65 AND  90
      THEN SUBSTRING(@OriginalText,Tally.N,1)
      --ascii lower case letters a-z is 97 thru 122
      WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 97 AND  122
      THEN SUBSTRING(@OriginalText,Tally.N,1)
      ELSE ''
    END
  FROM Tally
  WHERE Tally.N <= LEN(@OriginalText)
  RETURN @CleanedText
END --PROC
GO
