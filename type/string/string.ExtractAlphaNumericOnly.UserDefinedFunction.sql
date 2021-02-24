CREATE OR ALTER FUNCTION string.ExtractAlphaNumericOnly (
@pString varchar(8000)) 
RETURNS TABLE WITH SCHEMABINDING AS RETURN
/****************************************************************************************
Purpose:
 Given a VARCHAR(8000) or less string, returns only the alphanumeric digits from the 
 string.

--===== Autonomous
 SELECT ca.udf_AlphaNumericOnly
 FROM dbo.udf_AlphaNumericOnly(@pString) ca;

--===== CROSS APPLY example
 SELECT ca.udf_AlphaNumericOnly
 FROM dbo.SomeTable st
 CROSS APPLY dbo.udf_AlphaNumericOnly(st.SomeVarcharCol) ca;

Usage Examples:
--===== 1. Basic use against a literal

 SELECT ao.udf_AlphaNumericOnly 
 FROM dbo.udf_AlphaNumericOnly('xxx123abc999!!!') ao;

--===== 2. Against a table 
 DECLARE @sampleTxt TABLE (txtID int identity, txt varchar(100));
 INSERT @sampleTxt(txt) VALUES ('!!!A555A!!!'),(NULL),('AAA.999');

 SELECT txtID, OldTxt = txt, udf_AlphaNumericOnly
 FROM @sampleTxt st
 CROSS APPLY dbo.udf_AlphaNumericOnly(st.txt);
*****************************************************************/ 
WITH 
E1(N) AS 
( 
  SELECT N 
  FROM (VALUES (NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL))X(N)
), 
iTally(N) AS 
( 
  SELECT TOP (LEN(ISNULL(@pString,CHAR(32)))) 
    (CHECKSUM(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)))) 
  FROM E1 a CROSS JOIN E1 b CROSS JOIN E1 c CROSS JOIN E1 d 
) 
SELECT udf_AlphaNumericOnly = 
( 
  SELECT SUBSTRING(@pString,N,1) 
  FROM iTally 
  WHERE 
     ((ASCII(SUBSTRING(@pString,N,1)) - 48) & 0x7FFF) < 10 
  OR ((ASCII(SUBSTRING(@pString,N,1)) - 65) & 0x7FFF) < 26 
  OR ((ASCII(SUBSTRING(@pString,N,1)) - 97) & 0x7FFF) < 26 
  FOR XML PATH('') 
);