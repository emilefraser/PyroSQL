CREATE Function dbo.udfTestSelectStar()
RETURNS integer
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

	RETURN @s
end