CREATE  OR ALTER FUNCTION string.RemoveNonNumeric_ITVF(@OriginalText NVARCHAR(4000))
RETURNS TABLE WITH SCHEMABINDING AS
RETURN

WITH
	E1(N) AS (select 1 from (values (1),(1),(1),(1),(1),(1),(1),(1),(1),(1))dt(n)),
	E2(N) AS (SELECT 1 FROM E1 a, E1 b), --10E+2 or 100 rows
	E4(N) AS (SELECT 1 FROM E2 a, E2 b), --10E+4 or 10,000 rows max
	Tally(N) AS 
	(
		SELECT  ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E4
	)
	 
select STUFF(
(	 
	SELECT SUBSTRING(@OriginalText, t.N, 1)
	FROM tally t
	WHERE ASCII(SUBSTRING(@OriginalText, t.N, 1)) BETWEEN 48 AND  57
  AND n <= len(@OriginalText) -- added by ajb
	FOR XML PATH('')
), 1 ,0 , '') as CleanedText 
GO
q