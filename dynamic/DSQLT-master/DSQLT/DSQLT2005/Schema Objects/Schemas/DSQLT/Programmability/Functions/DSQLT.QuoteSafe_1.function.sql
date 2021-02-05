CREATE FUNCTION [DSQLT].[QuoteSafe]
(@Text NVARCHAR (MAX), @Quote NVARCHAR (1)='[')
RETURNS NVARCHAR (MAX)
AS
BEGIN
	-- Wollen wir null oder einen Leerstring wirklich Quoten??
	IF len(isnull(@Text,''))=0
		RETURN ''  -- Nein, wir geben lieber Leeren String zurück.
		
	-- Nur, wenn nicht bereits gequoted
	IF DSQLT.isQuoted(@Text,@Quote)=0
		SET @Text=[DSQLT].[Quote](@Text,@Quote)
	
	RETURN @Text
END