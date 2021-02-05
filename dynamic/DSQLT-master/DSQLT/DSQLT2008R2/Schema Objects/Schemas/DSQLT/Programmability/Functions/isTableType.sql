CREATE FUNCTION [DSQLT].[isTableType]
(@SchemaType [sysname])
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	SET @SchemaType=[DSQLT].[QuoteNameSB](@SchemaType)
	IF  EXISTS (
		SELECT * 
		FROM sys.types T
		join sys.schemas S on T.schema_id=S.schema_id
		WHERE T.is_table_type = 1 
		and [DSQLT].[QuoteSB](S.name)+'.'+[DSQLT].[QuoteSB](T.name)=@SchemaType
			)
		SET @Result=1
	RETURN @Result
END