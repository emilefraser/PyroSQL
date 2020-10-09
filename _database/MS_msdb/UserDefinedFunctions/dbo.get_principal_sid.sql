SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE FUNCTION dbo.get_principal_sid(@principal_id int)
RETURNS varbinary(85)
AS
BEGIN
    DECLARE @principal_sid varbinary(85)
    SELECT @principal_sid=sid FROM msdb.sys.database_principals WHERE principal_id=@principal_id
    RETURN @principal_sid
END

GO
