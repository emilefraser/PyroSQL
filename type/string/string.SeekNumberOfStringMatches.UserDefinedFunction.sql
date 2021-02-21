CREATE OR ALTER string.SeekNumberOfStringMatches (
 @pattern varchar(20) 
, @columnToSearch VARCHAR(1000) 
)
RETURNS NVARCHAR(MAX)
BEGIN
-- MS SQL Server function LEN() does not count trailing spaces!

SELECT (DATALENGTH(@columnToSearch) - DATALENGTH(REPLACE(@columnToSearch, @pattern, ''))) / DATALENGTH(@pattern) DatalengthNumberOfMatches
     , (LEN(@columnToSearch) - LEN(REPLACE(@columnToSearch, @pattern, ''))) / Len(@pattern) AS LenNumberOfMatches
     , (LEN(@columnToSearch) - LEN(REPLACE(@columnToSearch, @pattern, ''))) AS LenPattern
     , LEN(@pattern) AS Len@pattern
     , DATALENGTH(@pattern) AS Datalength@pattern;
     
     END
