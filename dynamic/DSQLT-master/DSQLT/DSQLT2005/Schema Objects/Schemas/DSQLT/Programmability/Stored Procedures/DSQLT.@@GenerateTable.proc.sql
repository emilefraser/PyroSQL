



CREATE PROCEDURE [DSQLT].[@@GenerateTable]
	 @Cursor CURSOR VARYING OUTPUT 
	,@Database sysname
	,@Print bit = 0
AS
	exec DSQLT.iterate '@GenerateTable',@Cursor,@Database=@Database,@Print=@Print
RETURN 0




