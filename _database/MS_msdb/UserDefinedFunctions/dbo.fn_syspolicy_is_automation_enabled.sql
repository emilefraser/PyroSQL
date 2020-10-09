SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION fn_syspolicy_is_automation_enabled()
RETURNS bit
AS
BEGIN
    DECLARE @ret bit;
    SELECT @ret = CONVERT(bit, current_value)
        FROM msdb.dbo.syspolicy_configuration 
        WHERE name = 'Enabled' 

    RETURN @ret;
END

GO
