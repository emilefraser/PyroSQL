CREATE OR ALTER FUNCTION string.ReplacePattern8K
(
  @string  varchar(8000),
  @pattern varchar(50),
  @replace varchar(1)
) 
/*****************************************************************************************
Purpose:
 Given a string (@string), a pattern (@pattern), and a replacement character (@replace)
 udf_PatReplace8K will replace any character in @string that matches the @pattern parameter 
 with the character, @replace.

Usage:
--===== Basic Syntax Example
 SELECT pr.NewString
 FROM dbo.udf_PatReplace8K(@string, @pattern, @replace);

--===== Replace numeric characters with a "*"
 SELECT pr.NewString
 FROM dbo.udf_PatReplace8K('My phone number is 555-2211','[0-9]','*') pr;

--==== Using againsts a table
 DECLARE @table TABLE(OldString varchar(40));
 INSERT @table VALUES 
 ('Call me at 555-222-6666'),
 ('phone number: (312)555-2323'),
 ('He can be reached at 444.665.4466');
 SELECT t.OldString, pr.NewString
 FROM @table t
 CROSS APPLY dbo.udf_PatReplace8K(t.OldString,'[0-9]','*') pr;
 */
RETURNS TABLE WITH SCHEMABINDING
AS
RETURN
WITH
E1(N) AS (SELECT N FROM (VALUES (1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) AS E1(N)),
iTally(N) AS 
(
  SELECT TOP (LEN(@string)) CHECKSUM(ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) 
  FROM E1 a,E1 b,E1 c,E1 d
)
SELECT NewString =
((
  SELECT
    CASE 
      WHEN PATINDEX(@pattern,SUBSTRING(@string COLLATE Latin1_General_BIN,N,1)) = 0
      THEN SUBSTRING(@string,N,1)
      ELSE @replace
    END
  FROM iTally
  FOR XML PATH(''), TYPE
).value('.[1]','varchar(8000)'));
GO
