use master;
GO
IF OBJECT_ID('[dbo].[StripNonNumeric]') IS NOT NULL 
DROP  FUNCTION  [dbo].[StripNonNumeric] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE FUNCTION [dbo].[StripNonNumeric](@OriginalText VARCHAR(8000))
RETURNS VARCHAR(8000)  
WITH SCHEMABINDING 
BEGIN 
DECLARE @CleanedText VARCHAR(8000) 
;WITH
      E1(N) AS ( --=== Create Ten 1's
                 SELECT 1 UNION ALL SELECT 1 UNION ALL
                 SELECT 1 UNION ALL SELECT 1 UNION ALL
                 SELECT 1 UNION ALL SELECT 1 UNION ALL
                 SELECT 1 UNION ALL SELECT 1 UNION ALL
                 SELECT 1 UNION ALL SELECT 1 --10
               ),
      E2(N) AS (SELECT 1 FROM E1 a, E1 b),   --100
      E4(N) AS (SELECT 1 FROM E2 a, E2 b),   --10,000
Tally(N) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT N)) FROM E4) 
SELECT @CleanedText = ISNULL(@CleanedText,'') +  
CASE 
  --ascii numbers are 48(for '0') thru 57 (for '9')
  WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 48 AND  57  THEN SUBSTRING(@OriginalText,Tally.N,1) ELSE '' END
      
FROM tally           WHERE Tally.N <= LEN(@OriginalText)            
                
RETURN @CleanedText 
END
GO
--#################################################################################################
--Public permissions
GRANT EXECUTE ON [StripNonNumeric] TO PUBLIC
--#################################################################################################
GO