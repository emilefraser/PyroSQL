SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- This function returns filters that are not supported
-- It is used to prevent unsupported filters from being
-- created. It will only reject well formed filters, in 
-- other words it will not perform a full syntax check.
CREATE FUNCTION [dbo].[syspolicy_fn_get_bad_filters] (
    @inserted [dbo].[syspolicy_target_filters_type] READONLY
)
RETURNS TABLE
AS
    RETURN 
    (
        SELECT filter FROM @inserted 
        WHERE    
            -- do not accept filters for the next level 
            filter LIKE N'Server/%/%\[@%=%\]%' ESCAPE '\' AND 
            -- take out cases when the property contains the pattern
            filter NOT LIKE 'Server/%\[%\[%\]%\]%' ESCAPE '\'
    )

GO
