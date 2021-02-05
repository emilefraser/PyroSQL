/* 

Function Table Example that converts pounds to kilograms and returns a table with both values

*/

-- Build our pound-based weight table and insert some test values (the select just verifies these)
CREATE TABLE WeightTable(
	Pounds DECIMAL(25,4)
)

INSERT INTO WeightTable VALUES (25),(50),(75),(100),(125),(150),(175),(200),(225),(250)

SELECT *
FROM WeightTable

-- Function converts pounds to kilograms
CREATE FUNCTION PoundsToKilograms()
RETURNS @lbtokg TABLE
(
	Pounds DECIMAL(25,4),
	Kilograms DECIMAL(25,4)
)
AS
BEGIN
	-- We insert the pounds into our lbtokdg variable table
	INSERT INTO @lbtokg (Pounds)
	SELECT Pounds
	FROM WeightTable
	
	-- We update the lbtokg table to calculate the kilogram weight based on the pound weight
	UPDATE @lbtokg
	SET Kilograms = Pounds/2.2046226218
	
	-- We return the table with the values for when we select from it
	RETURN
END

-- Returns the kilogram values per pound value in WeightTable
SELECT *
FROM PoundsToKilograms()
-- If we add to our WeightTable, this function will continue to return the kilogram weight for the pound weight listed