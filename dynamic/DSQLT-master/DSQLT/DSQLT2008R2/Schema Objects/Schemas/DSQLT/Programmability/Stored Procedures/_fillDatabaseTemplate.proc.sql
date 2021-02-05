



CREATE PROCEDURE [DSQLT].[_fillDatabaseTemplate]
@p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database NVARCHAR (MAX) OUTPUT
AS
BEGIN
if @Database is null
	SET @Database=DB_NAME()

if LEN(@Database)=2 and LEFT(@Database,1)='@' and ISNUMERIC(right(@Database,1))=1  -- einfache Parameter
	exec DSQLT._fillTemplate @p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database=null,@Template=@Database OUTPUT

RETURN
END



