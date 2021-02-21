CREATE OR ALTER FUNCTION string.RemoveNonAlpha_ITVF(
@OriginalText NVARCHAR(4000))
RETURNS TABLE WITH SCHEMABINDING AS
RETURN

WITH
  E1(N) AS (select 1 from (values (1),(1),(1),(1),(1),(1),(1),(1),(1),(1))dt(n)),
  E2(N) AS (SELECT 1 FROM E1 a, E1 b), --10E+2 or 100 rows
  E4(N) AS (SELECT 1 FROM E2 a, E2 b), --10E+4 or 10,000 rows max
  Tally(N) AS 
  (
    SELECT  ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E4
  ),WithHTMLEntities 
  AS
  (
  
select STUFF(
(  
 SELECT 
    CASE 
      --ascii numbers are 48(for '0') thru 57 (for '9')
      --WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 48 AND  57  
      --THEN SUBSTRING(@OriginalText,Tally.N,1) 
      --ascii upper case letters A-Z is 65 thru 90
      WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 65 AND  90  
      THEN SUBSTRING(@OriginalText,Tally.N,1) 
      --ascii lower case letters a-z is 97 thru 122
      WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 97 AND  122  
      THEN SUBSTRING(@OriginalText,Tally.N,1) 
      ELSE ''   
      END
 FROM Tally
  WHERE Tally.N <= len(@OriginalText) -- added by ajb
 FOR XML PATH('')
), 1 ,0 , '') as CleanedText 
)
SELECT REPLACE(   --replacing known HTML entities that are an artifact of using the high speed FOR XML solution
         REPLACE(
           REPLACE(
             REPLACE(
               REPLACE(
                 REPLACE(
                   REPLACE(CleanedText,'&#x20;', ' ')
                 ,'&lt;','<')
               ,'&gt;','>')
             ,'&#x09;',' ')
           ,'&#x0D;',' ')
         ,'&#x0A;',' '),
      '&amp;','&') AS CleanedText FROM WithHTMLEntities

GO
