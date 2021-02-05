

CREATE PROC [DSQLT].[@DropFunction] 
	@Database sysname
	,@Schema sysname
	,@Function sysname
	,@Print int=0
as
	exec DSQLT.[Execute] '@DropFunction',@Schema,@Function,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP FUNCTION [@1].[@2]
END








