/*

Uses WHILE Logic to populate random numbers, insert them into a table, and prevents the random number from appearing more than once

*/

-- Builds a random number
DECLARE @num AS INT
SET @num = 100

-- Build test table
DECLARE @random TABLE (
	RandomNumber INT
)

-- Build a key part of the while logic
DECLARE @cnt INT
SET @cnt = 0

-- Use the while to insert 10 date records
WHILE @cnt < 10
BEGIN
	
	SELECT (CAST(@num * RAND() AS INT)) N INTO #UniqueRandomTemp
	
	INSERT INTO @random
	SELECT N FROM #UniqueRandomTemp
	WHERE N NOT IN (SELECT RandomNumber FROM @random)
	
	DROP TABLE #UniqueRandomTemp
	
	SET @cnt = @cnt + 1
END

SELECT * FROM @random