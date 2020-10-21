/*

Uses WHILE Logic to populate random dates, insert them into a table, and prevents the random number from appearing more than once

*/

-- Build test table
DECLARE @RandomDate TABLE (
	RandomDay DATETIME
)

-- Build a key part of the while logic
DECLARE @cnt INT
SET @cnt = 0

-- Use the while to insert 10 random dates
WHILE @cnt < 25
BEGIN

    SELECT DATEADD(DD, CAST(RAND() * 365 as int), '2012-01-01') D INTO #UniqueRandomDateTemp
    
    INSERT INTO @RandomDate
	SELECT D FROM #UniqueRandomDateTemp
	WHERE D NOT IN (SELECT RandomDay FROM @RandomDate)
	
	DROP TABLE #UniqueRandomDateTemp
    
    SET @cnt = @cnt + 1

END

SELECT *
FROM @RandomDate