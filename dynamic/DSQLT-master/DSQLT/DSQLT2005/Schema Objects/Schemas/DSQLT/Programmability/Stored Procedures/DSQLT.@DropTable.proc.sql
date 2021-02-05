


CREATE PROC [DSQLT].[@DropTable] 
	@Database sysname
	,@Schema sysname
	,@Table sysname
	,@Print int=0
as
	exec DSQLT.[Execute] '@DropTable',@Schema,@Table,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP TABLE [@1].[@2]
END











