--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Check, if Function exists
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isFunc] (@fn nvarchar(max))
RETURNS bit
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@fn) AND type in (N'AF',N'FN',N'FS',N'FT',N'IF',N'TF'))
		SET @Result=1
	RETURN @Result
END


