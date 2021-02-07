use master;
GO
IF OBJECT_ID('[dbo].[StripNonNumeric]') IS NOT NULL 
DROP  FUNCTION  [dbo].[StripNonNumeric] 
GO
CREATE FUNCTION StripNonNumeric(@OriginalText VARCHAR(8000))
RETURNS VARCHAR(8000)  
BEGIN 
DECLARE @CleanedText VARCHAR(8000) 
;WITH tally (N) as
(SELECT TOP 10000 row_number() OVER (ORDER BY sc1.id)
 FROM Master.dbo.SysColumns sc1
 CROSS JOIN Master.dbo.SysColumns sc2)
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