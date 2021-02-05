--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Embrace text with quotes. Quotes within text get doubled. Special support for braces as quotes.
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Quote]
(@Text NVARCHAR (MAX), @Quote NVARCHAR (1)='[')
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Prefix nchar(1) 
	DECLARE @Postfix nchar(1) 
	
	-- Klammerung richtig abarbeiten
	IF @Quote='['
		SET @Quote=']'
	SET @Prefix=@Quote
	SET @Postfix=@Quote
	IF @Quote=']'
		SET @Prefix='['
		
	SET @Text=@Prefix+REPLACE(@Text,@Quote,@Quote+@Quote)+@Postfix
	
	RETURN @Text
END

