use master;
GO
IF OBJECT_ID('[dbo].[fn_parsename]') IS NOT NULL 
DROP  FUNCTION  [dbo].[fn_parsename] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--Lef tto right ParseName function, unlimited number of elements
--#################################################################################################
CREATE FUNCTION dbo.fn_parsename
        (
        @pString    VARCHAR(7999),
        @pDelimiter CHAR(1),
        @Occurrance int
        )
RETURNS VARCHAR(8000)
 AS
BEGIN 
DECLARE @Results VARCHAR(8000)
--===== "Inline" CTE Driven "Tally Table” produces values up to
     -- 10,000... enough to cover VARCHAR(8000)
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
cteTally(N) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT N)) FROM E4) , 
--===== Do the split
InterResults 
AS 
(
 SELECT ROW_NUMBER() OVER (ORDER BY N) AS ItemNumber,
        SUBSTRING(@pString, N, CHARINDEX(@pDelimiter, @pString + @pDelimiter, N) - N) AS Item
   FROM cteTally
  WHERE N < LEN(@pString) + 2
    AND SUBSTRING(@pDelimiter + @pString, N, 1) = @pDelimiter
)
SELECT @Results = Item FROM InterResults WHERE ItemNumber = @Occurrance
return @Results
END --FUNCTION
GO

--#################################################################################################
--Public permissions
GRANT EXECUTE ON [fn_parsename] TO PUBLIC
--#################################################################################################
GO
