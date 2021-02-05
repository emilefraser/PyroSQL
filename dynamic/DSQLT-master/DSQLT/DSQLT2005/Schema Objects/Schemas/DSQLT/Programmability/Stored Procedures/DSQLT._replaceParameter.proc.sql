
-- ersetzt in einem SQL-Quelltext (@Template) einen Parameter (@Parameter) durch einen Wert (@Value).
-- für anderweitige Verwendung wurde der Parametername mit sysname definiert, obwohl nchar(2) für @0-@9 ausreichen würde.

CREATE PROCEDURE [DSQLT].[_replaceParameter]
@Parameter NVARCHAR (MAX), @Template NVARCHAR (MAX) OUTPUT, @Value NVARCHAR (MAX), @Pos INT OUTPUT
AS
BEGIN
DECLARE @Pattern nvarchar(max)
DECLARE @From int
DECLARE @To int
set @From =0
set @To =0
if @Pos between 1 and LEN(@Template)-1
	BEGIN
	-- 2 zurück
	SET @From=@Pos-2
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='"'''+@Parameter+'''"'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteSQ(@Parameter)  -- Parameter bleibt erhalten Single Quoted
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='""'+@Parameter+'""'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=@Parameter  -- Parameter bleibt erhalten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='"['+@Parameter+']"'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteSB(@Parameter)  -- Parameter bleibt erhalten mit Klammern
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='"('+@Parameter+'"="'+@Parameter+'")'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
	
	-- 1 zurück
	IF @To=0 --and @From>0
		SET @From=@Pos-1
		
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='['+@Parameter+'].['+@Parameter+']'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteNameSB(@Value) -- mit Zerlegung in Namensbestandteile, dann Quoten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='['+@Parameter+']'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteSB(@Value) --  Quoten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='('+@Parameter+'='+@Parameter+')'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='"'+@Parameter+'"'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern=''''+@Parameter+''''
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteSQ(@Value) --  Quoten mit '
		END
	END
	-- ab Position
	IF @To=0 --and @From>0
		SET @From=@Pos  
		
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern=@Parameter+'='+@Parameter
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
	
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern=@Parameter
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
END
if @Value is not null and (@From between 1 and LEN(@Template)) and (@To between 1 and LEN(@Template))
	BEGIN
		Set @Template=STUFF(@Template,@From,@To-@From+1,@Value)
		SET @Pos=@From+len(@Value)-1  -- 13.05.2010. _fillTemplate geht eine Position weiter!!
	END
ELSE
	SET @Pos=0
END
RETURN





