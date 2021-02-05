CREATE FUNCTION [DSQLT].[ColumnListCRLF]
(@Table NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result=''
	DECLARE @delim nvarchar(5)
	SET @delim=' , '+CHAR(13)+CHAR(10)
	-- mit Order by funktioniert das rekursive String-verketten nicht => 
	select @Result=DSQLT.Concat(ColumnQ,@delim,@Result)
	from (select Top 100 PERCENT * from DSQLT.Columns(@Table) order by [Order]) X

	RETURN @Result
END