

CREATE PROCEDURE [DSQLT].[_addTransaction]
	@Template NVARCHAR (MAX) OUTPUT
,	@Database NVARCHAR (MAX)
,	@UseTransaction bit = 0
AS
BEGIN
IF @UseTransaction=1
BEGIN
declare	@TransactionTemplate NVARCHAR (max)
exec DSQLT._getTemplate 'DSQLT.[@_UseTransaction]', @TransactionTemplate OUTPUT
exec DSQLT._fillTemplate @p1=@Template,@Database=@Database,@Template=@TransactionTemplate OUTPUT
SET @Template=@TransactionTemplate
END

RETURN
END