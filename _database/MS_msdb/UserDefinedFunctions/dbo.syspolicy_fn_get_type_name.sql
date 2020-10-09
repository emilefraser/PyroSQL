SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[syspolicy_fn_get_type_name](@event_type_name sysname)
RETURNS sysname
AS
BEGIN
    RETURN 
    (CASE LOWER(@event_type_name)
        WHEN 'procedure' THEN 'StoredProcedure'
        WHEN 'function' THEN 'UserDefinedFunction'
        WHEN 'type' THEN 'UserDefinedType'
        WHEN 'sql user' THEN 'User'
        WHEN 'certificate user' THEN 'User'
        WHEN 'asymmetric key user' THEN 'User'
        WHEN 'windows user' THEN 'User'
        WHEN 'group user' THEN 'User'
        WHEN 'application role' THEN 'ApplicationRole'
        ELSE UPPER(SUBSTRING(@event_type_name, 1,1)) + LOWER(SUBSTRING(@event_type_name, 2,LEN(@event_type_name)))
    END)
END

GO
