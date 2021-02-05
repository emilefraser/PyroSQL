


CREATE PROC [DSQLT].[@DropProcedure] 
	@Database sysname
	,@Schema sysname
	,@Procedure sysname
	,@Print int=0
as
	exec DSQLT.[Execute] '@DropProcedure',@Schema,@Procedure,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP PROCEDURE [@1].[@2]
END









