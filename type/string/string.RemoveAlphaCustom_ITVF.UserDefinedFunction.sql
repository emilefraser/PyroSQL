CREATE OR ALTER FUNCTION strip.StripAlphaCustom_ITVF (
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

      WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 32  --space

            THEN SUBSTRING(@OriginalText,Tally.N,1) 

      WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 45  --hyphen

      THEN CHAR(45)

       WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 62  -- > SELECT ASCII('9')

      THEN CHAR(62)

       WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 60  --<

      THEN CHAR(60)

       WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 61  --=

      THEN CHAR(61)

      WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 37  --%

      THEN CHAR(37)

      --ascii upper case letters A-Z

      WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 48 AND  57  

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
