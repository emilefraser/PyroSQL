--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Checks, if text is embraced text with quotes. Special support for braces or quotes within text.
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isQuoted] (@Text nvarchar(max) ,@Quote nvarchar(max)='[')
RETURNS bit
AS
BEGIN
	DECLARE @Prefix nchar(1) 
	DECLARE @Postfix nchar(1) 
	DECLARE @Replace nchar(2) 
	DECLARE @Pos int
	
	-- mindestens 2 Zeichen, sonst nicht gequoted
	IF LEN(@Text) < 2
		RETURN 0
		
	-- Klammerung richtig abarbeiten
	IF @Quote='['
		SET @Quote=']'
	-- Falls Bedarf für diese Klammern, dann aktivieren.
	--IF @Quote='('
	--	SET @Quote=')'
	--IF @Quote='<'
	--	SET @Quote='>'
	SET @Prefix=@Quote
	SET @Postfix=@Quote
	IF @Quote=']'
		SET @Prefix='['
	-- Falls Bedarf für diese Klammern, dann aktivieren.
	--IF @Quote=')'
	--	SET @Prefix='('
	--IF @Quote='>'
	--	SET @Prefix='<'

	-- Prüfen, ob links und rechts gequoted
	IF SUBSTRING(@Text,1,1) <> @Prefix or SUBSTRING(@Text,LEN(@Text),1) <> @Postfix
		RETURN 0
		
	SET @Text=SUBSTRING(@Text,2,LEN(@Text)-2)
	
	SET @Pos=-1
	WHILE @Pos < LEN(@Text) 
	BEGIN
		SET @Pos=Charindex(@Quote,@Text,@Pos+2)
		-- nix gequoted
		IF @Pos = 0 
			RETURN 1
		-- Quote ist einzeln!
		IF @Pos = LEN(@Text) 
			RETURN 0
		-- nächstes Zeichen nicht identisch??
		IF SUBSTRING(@Text,@Pos,1) <> SUBSTRING(@Text,@Pos+1,1)
			RETURN 0
	END
	-- alles regelgerecht. Der Text könnte gequoted sein.
	RETURN 1
END




