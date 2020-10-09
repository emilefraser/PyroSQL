SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION [dbo].[syspolicy_fn_filter_complete] (@target_set_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @target_set_skeleton nvarchar(max), @skeleton nvarchar(max), @level sysname, @dummy nvarchar(max), @ret int, 
            @i int, @p int
    
    SELECT @target_set_skeleton = type_skeleton, @i=0, @p=CHARINDEX('/',type_skeleton)
        FROM msdb.dbo.syspolicy_target_sets 
        WHERE target_set_id = @target_set_id

    IF @@ROWCOUNT != 1 RETURN 0
    
    IF @target_set_skeleton = 'Server' RETURN 1    

    -- Count the number of levels in the skeleton past the root
    WHILE (@p <> 0)
        BEGIN
            SET @i = @i + 1
        SET @p = CHARINDEX('/', @target_set_skeleton, @p + 1)
        END

    -- Compare the number of levels in the skeleton with those in TSL
    IF (@i = (SELECT COUNT(*) FROM msdb.dbo.syspolicy_target_set_levels 
             WHERE target_set_id = @target_set_id))
        RETURN 1

    RETURN 0
END

GO
