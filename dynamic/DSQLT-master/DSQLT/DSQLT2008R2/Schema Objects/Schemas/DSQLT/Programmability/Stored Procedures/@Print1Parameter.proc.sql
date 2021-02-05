CREATE PROCEDURE [DSQLT].[@Print1Parameter]
@p1 NVARCHAR (MAX)=null, @Print BIT=0
AS
exec DSQLT.[Execute] '@Print1Parameter' ,@p1,@Print=@Print
RETURN 0
BEGIN
	if '@1' = '"@1"' 	print '@1'
END
