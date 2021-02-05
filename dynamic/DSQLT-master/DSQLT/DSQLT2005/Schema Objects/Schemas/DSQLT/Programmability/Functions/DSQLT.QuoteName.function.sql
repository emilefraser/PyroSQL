--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Quote all nameparts of the objectname in text.
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[QuoteName] (@Text nvarchar(max) ,@Quote nvarchar(max)='[')
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @Server sysname
	DECLARE @Database sysname
	DECLARE @Schema sysname
	DECLARE @Object sysname
	
	SET @Server=PARSENAME(@Text,4)
	IF @Server is not null
		SET @Server=DSQLT.QUOTE(@Server,@Quote)+'.'
	ELSE
		SET @Server=''
	
	SET @Database=PARSENAME(@Text,3)
	IF @Database is not null
		SET @Database=DSQLT.QUOTE(@Database,@Quote)+'.'
	ELSE
		IF LEN(@Server) = 0
			SET @Database=''
		ELSE
			SET @Database='.'
			
	SET @Schema=PARSENAME(@Text,2)
	IF @Schema is not null
		SET @Schema=DSQLT.QUOTE(@Schema,@Quote)+'.'
	ELSE
		IF LEN(@Database) = 0
			SET @Schema=''
		ELSE
			SET @Schema='.'
			
	SET @Object=PARSENAME(@Text,1)
	IF @Object is not null
		SET @Object=DSQLT.QUOTE(@Object,@Quote)
	ELSE	-- verrückter Name , hat mehr wie 4 Bestandteile. Quoten wir ihn einfach, falls nötig
		SET @Text=DSQLT.QUOTE(@Text,@Quote)
	
	-- Wenn es ein gültiger Name war, bauen wir ihn aus den Bestandteilen wieder zusammen		
	IF @Object is not null
		SET @Text=@Server+@Database+@Schema+@Object
	
	RETURN @Text
END

