--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Check, if Stored Proc exists
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isProc](@sp nvarchar(max))
RETURNS bit
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@sp) AND type in (N'P', N'PC'))
		SET @Result=1
	RETURN @Result
END

