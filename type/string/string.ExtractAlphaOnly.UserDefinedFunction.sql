
CREATE  OR ALTER FUNCTION string.ExtracAlphaOnly (
@pString varchar(8000))
RETURNS TABLE WITH SCHEMABINDING AS RETURN
WITH 
E1(N) AS (SELECT N FROM (VALUES ($),($),($),($),($),($),($),($),($),($)) x(n)), 
iTally(N) AS 
( 
  SELECT TOP (LEN(ISNULL(@pString,CHAR(32)))) 
    (CHECKSUM(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)))) 
  FROM E1 a CROSS JOIN E1 b CROSS JOIN E1 c CROSS JOIN E1 d 
) 
SELECT udf_AlphaOnly = 
( 
  SELECT SUBSTRING(@pString,N,1) 
  FROM iTally 
  WHERE ((ASCII(SUBSTRING(@pString,N,1)) - 65) & 0x7FFF) < 26 
  OR ((ASCII(SUBSTRING(@pString,N,1)) - 97) & 0x7FFF) < 26 
  FOR XML PATH('') 
); 