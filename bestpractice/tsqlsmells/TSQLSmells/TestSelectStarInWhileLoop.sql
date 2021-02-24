CREATE PROCEDURE dbo.TestSelectStarInWhileLoop
AS
WHILE(0=0) begin
	SELECT * FROM sys.objects
end
