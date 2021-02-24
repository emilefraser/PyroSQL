CREATE Function dbo.udfTestSelectStar()
RETURNS @RetTable TABLE(
id INTEGER
)
as
BEGIN
	DECLARE @s INTEGER;
	WITH cteTest
	AS
	(  
		SELECT * FROM sys.objects
	)
	SELECT @s = cteTest.object_id
	FROM cteTest
	return
end