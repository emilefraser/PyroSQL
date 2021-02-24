/*Ver2*/
CREATE FUNCTION dbo.TestSelectStarIninlineTVF()
RETURNS TABLE
AS
RETURN(
	SELECT * FROM sys.objects
)