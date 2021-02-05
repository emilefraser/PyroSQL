--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Check, if View exists
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isView](@view varchar(max))
RETURNS bit
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@view) AND type in (N'V'))
		SET @Result=1
	RETURN @Result
END


