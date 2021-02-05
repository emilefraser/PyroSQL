--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Commaseparated List of Columns
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[ColumnList]
(@Table NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result=''
	select @Result=DSQLT.Concat(ColumnQ,' , ',@Result)
	from DSQLT.Columns(@Table)
	order by [Order]
	RETURN @Result
END









