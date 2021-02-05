CREATE PROCEDURE [DSQLT].[@CreateTableFrom]
AS
RETURN
BEGIN
IF DSQLT.isTable('[@1].[@2]')=0
	BEGIN
	select top 0 * 
	into [@1].[@2]
	from [@3].[@4]
	END
END