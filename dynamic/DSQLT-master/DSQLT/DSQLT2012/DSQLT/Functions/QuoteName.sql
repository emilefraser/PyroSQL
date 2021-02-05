CREATE FUNCTION [DSQLT].[QuoteName]
(@Text NVARCHAR (MAX), @Quote NVARCHAR (MAX)='[')
RETURNS NVARCHAR (MAX)
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
