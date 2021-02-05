CREATE proc [Sample].[@ForEachTable] as
declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select * from dsqlt.tables('%')
exec DSQLT.iterate 'Sample.[@ForEachTable]',@Cursor=@Cursor
RETURN 
BEGIN
print '@1'
END
