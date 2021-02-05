
CREATE PROCEDURE [DSQLT].[iterate]
@DSQLTProc NVARCHAR (MAX)=null, @Cursor CURSOR VARYING OUTPUT, @p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database [sysname]=null, @Template NVARCHAR (MAX)=null OUTPUT, @Create NVARCHAR (MAX)=null, @Once BIT=0, @Print BIT=0
AS
Begin
SET NOCOUNT ON
if @Database is null
	SET @Database=DB_NAME()

-- Template holen
if @DSQLTProc is not null  -- es kann auch ein Template direkt übergeben werden
	exec DSQLT._getTemplate @DSQLTProc, @Template OUTPUT
	
-- Template iterieren 
exec DSQLT._iterateTemplate @Cursor,@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database,@Template OUTPUT,@Create,@Once,@Print

--  ausführen, falls einmalig
if @Once=1
	exec DSQLT._doTemplate @Database,@Template,@Print
end












