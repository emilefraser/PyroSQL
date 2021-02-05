CREATE PROCEDURE [Sample].[@CopyTableFrom] 
AS RETURN -- schützt Template vor versehentlichem Aufruf
BEGIN
TRUNCATE TABLE [@1].[@2]
INSERT INTO [@1].[@2]
("@3")
SELECT "@4" 
FROM [@5].[@1].[@2]
END
