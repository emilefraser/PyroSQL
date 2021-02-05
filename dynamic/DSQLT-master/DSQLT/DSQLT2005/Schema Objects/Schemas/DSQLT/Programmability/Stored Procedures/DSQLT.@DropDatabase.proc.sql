
CREATE PROC [DSQLT].[@DropDatabase] 
	 @Database sysname =null
	, @Print bit = 0
AS
exec DSQLT.[Execute] '@DropDatabase' ,@p1=@Database,@Print=@Print
RETURN 0
BEGIN
DROP DATABASE [@1]
END
