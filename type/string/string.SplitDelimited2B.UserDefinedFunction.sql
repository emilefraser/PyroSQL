CREATE OR ALTER FUNCTION string.SplitDelimitedSplit2B (
  @pString    varchar(max), 
  @pDelimiter char(1)
)
RETURNS TABLE WITH SCHEMABINDING 
AS 
RETURN
WITH L1(N) AS 
(
  SELECT N 
  FROM (VALUES 

   (0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),

   (0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),

   (0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),

   (0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),

   (0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),

   (0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),

   (0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),

   (0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),

   (0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),

   (0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),

   (0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) t(N)

), --216 values

 cteTally(N) AS 

(
  SELECT 0 UNION ALL
  SELECT TOP (DATALENGTH(ISNULL(@pString,1))) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
  FROM L1 a CROSS JOIN L1 b CROSS JOIN L1 c

  --2,176,782,336 rows: enough to handle  2,147,483,647 characters (the varchar(max) limit)

), 

cteStart(N1) AS 

(

  SELECT t.N+1

  FROM cteTally t

  WHERE (SUBSTRING(@pString,t.N,1) = @pDelimiter OR t.N = 0) 

)

SELECT 

  ItemNumber = ROW_NUMBER() OVER(ORDER BY s.N1),

  Item = SUBSTRING(@pString,s.N1,ISNULL(NULLIF((LEAD(s.N1,1,1) 

           OVER (ORDER BY s.N1) - 1),0)-s.N1,DATALENGTH(ISNULL(@pString,1))))

FROM cteStart s;

GO

