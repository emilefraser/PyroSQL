SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION dbo.fn_encode_sqlname_for_powershell
(
	@sql_name SYSNAME
)
RETURNS SYSNAME
AS
BEGIN
	DECLARE @encoded_name SYSNAME = @sql_name

	SET @encoded_name = REPLACE(@encoded_name, N'%', N'%25')
	SET @encoded_name = REPLACE(@encoded_name, N'\', N'%5C')
	SET @encoded_name = REPLACE(@encoded_name, N'/', N'%2F')
	SET @encoded_name = REPLACE(@encoded_name, N':', N'%3A')
	SET @encoded_name = REPLACE(@encoded_name, N'<', N'%3C')
	SET @encoded_name = REPLACE(@encoded_name, N'>', N'%3E')
	SET @encoded_name = REPLACE(@encoded_name, N'*', N'%2A')
	SET @encoded_name = REPLACE(@encoded_name, N'?', N'%3F')
	SET @encoded_name = REPLACE(@encoded_name, N'[', N'%5B')
	SET @encoded_name = REPLACE(@encoded_name, N']', N'%5D')
	SET @encoded_name = REPLACE(@encoded_name, N'|', N'%7C')

	RETURN @encoded_name
END

GO
