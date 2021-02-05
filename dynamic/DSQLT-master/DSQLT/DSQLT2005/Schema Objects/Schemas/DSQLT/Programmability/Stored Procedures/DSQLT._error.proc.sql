CREATE PROCEDURE [DSQLT].[_error] 
	@Msg nvarchar(max)=''
AS
BEGIN
SET @Msg='DSQLT ERROR : '+@Msg
print @Msg
END


