SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION [dbo].[syspolicy_fn_eventing_filter] (@target_set_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @cnt int, @level sysname, @condition_id int, @ret int

    SELECT @cnt = count(*) FROM msdb.dbo.syspolicy_target_set_levels 
        WHERE target_set_id = @target_set_id AND condition_id IS NOT NULL
    IF @cnt = 0 
        RETURN 1
    ELSE IF @cnt > 1
        RETURN 0
    ELSE
        BEGIN
        SELECT @level = level_name, @condition_id = condition_id FROM msdb.dbo.syspolicy_target_set_levels 
            WHERE target_set_id = @target_set_id AND condition_id IS NOT NULL
        IF @level != 'Database'
            RETURN 0

		IF @condition_id IS NOT NULL
			BEGIN
			IF EXISTS (SELECT * FROM msdb.dbo.syspolicy_conditions  
				WHERE condition_id = @condition_id AND   
				(1 = CONVERT(xml, expression).exist('//FunctionType/text()[.="ExecuteSql"]') OR
				1 = CONVERT(xml, expression).exist('//FunctionType/text()[.="ExecuteWql"]') ) )
				RETURN 0
			END

        SELECT @ret = is_name_condition 
        FROM msdb.dbo.syspolicy_conditions    
        WHERE condition_id = @condition_id
        END

    RETURN @ret
END

GO
