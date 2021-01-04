/*

Using a TSQL WHILE to insert set number of values

*/
-- Builds a random number
DECLARE @num AS INT
SET @num = 100

-- Build test table
DECLARE @t TABLE (
	RandomNumber INT
)

-- Build a key part of the while logic
DECLARE @cnt INT
SET @cnt = 0

-- Use the while to insert 10 date records
WHILE @cnt < 10
BEGIN
	INSERT INTO @t
	VALUES (CAST(@num * RAND() AS INT))
	PRINT 'Random Number Inserted'
	SET @cnt = @cnt + 1
END

SELECT * FROM @t

-- On its own this builds a random integer
DECLARE @num AS INT
SET @num = 100

SELECT CAST(@num * RAND() AS INT)