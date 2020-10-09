SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_update_policy] 
@name sysname = NULL,
@policy_id int = NULL,
@condition_id int=NULL,
@condition_name sysname = NULL,
@execution_mode int=NULL,
@policy_category sysname = NULL,
@schedule_uid uniqueidentifier = NULL,
@description nvarchar(max) = NULL,
@help_text nvarchar(4000) = NULL,
@help_link nvarchar(2083) = NULL,
@root_condition_id int = -1,
@root_condition_name sysname = NULL,
@object_set_id int = -1,
@object_set sysname = NULL,
@is_enabled bit = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

	--Check for the execution mode value
	IF (((@execution_mode IS NOT NULL)) AND (@execution_mode NOT IN (0,1,2,4,5,6)))
	BEGIN 
		RAISERROR(34004, -1, -1, @execution_mode)
		RETURN (1)
	END

    -- Turn [nullable] empty string parameters into NULLs
    IF @name = ''           SELECT @name = NULL
    IF @condition_name = '' SELECT @condition_name = NULL
    IF @root_condition_name = '' 
        BEGIN
        SELECT @root_condition_name = NULL
        IF @root_condition_id = -1
            -- root_condition is being reset
            SELECT @root_condition_id = NULL
        END
    IF @object_set = '' 
        BEGIN
        SELECT @object_set = NULL
        IF @object_set_id = -1
            -- object_set is being reset
            SELECT @object_set_id = NULL
        END

    DECLARE @retval              INT

    EXEC @retval = msdb.dbo.sp_syspolicy_verify_policy_identifiers @name, @policy_id OUTPUT
    IF (@retval <> 0)
        RETURN (1)

    SELECT  @execution_mode = ISNULL(@execution_mode, execution_mode),
            @is_enabled = ISNULL(@is_enabled, is_enabled) 
        FROM msdb.dbo.syspolicy_policies WHERE policy_id = @policy_id

    IF(@condition_id IS NOT NULL or @condition_name IS NOT NULL)
    BEGIN
        EXEC @retval = msdb.dbo.sp_syspolicy_verify_condition_identifiers @condition_name = @condition_name OUTPUT, @condition_id = @condition_id OUTPUT
        IF (@retval <> 0)
            RETURN (1)
    END

    IF((@root_condition_id IS NOT NULL and @root_condition_id != -1) or @root_condition_name IS NOT NULL)
    BEGIN
        IF (@root_condition_id = -1 and @root_condition_name IS NOT NULL)
            SET @root_condition_id = NULL
        EXEC @retval = msdb.dbo.sp_syspolicy_verify_condition_identifiers @condition_name = @root_condition_name OUTPUT, @condition_id = @root_condition_id OUTPUT
        IF (@retval <> 0)
            RETURN (1)
    END

    SET @schedule_uid = ISNULL (@schedule_uid, '{00000000-0000-0000-0000-000000000000}')

    IF (@schedule_uid = '{00000000-0000-0000-0000-000000000000}' AND (@execution_mode & 4) = 4)
    BEGIN
        RAISERROR (34011, -1, -1, 'schedule_uid', 4)
        RETURN(1)
    END

    IF (@is_enabled = 1 AND @execution_mode = 0)
    BEGIN
        RAISERROR (34011, -1, -1, 'is_enabled', @execution_mode)
        RETURN(1)
    END

    IF (@schedule_uid != '{00000000-0000-0000-0000-000000000000}')
    BEGIN
        -- verify the schedule exists
        IF NOT EXISTS (SELECT schedule_id FROM msdb.dbo.sysschedules WHERE schedule_uid = @schedule_uid)
        BEGIN
            RAISERROR (14365, -1, -1)
            RETURN(1)
        END
    END

    DECLARE @object_set_facet_id INT
    IF ((@object_set_id IS NOT NULL and @object_set_id != -1) or @object_set IS NOT NULL)
    BEGIN
        IF (@object_set_id = -1 and @object_set IS NOT NULL)
            SET @object_set_id = NULL
        EXEC @retval = msdb.dbo.sp_syspolicy_verify_object_set_identifiers @name = @object_set OUTPUT, @object_set_id = @object_set_id OUTPUT
        IF (@retval <> 0)
            RETURN (1)

        SELECT @object_set_facet_id = facet_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name = @object_set
        -- Ensure the object set has been created from the same facet that the policy condition has been created
        IF (@object_set_facet_id <> (SELECT facet_id FROM msdb.dbo.syspolicy_conditions_internal WHERE condition_id = @condition_id))
        BEGIN
            -- TODO: RAISEERROR that specified object_set isn't created from the facet that the policy condition has been created from
            RAISERROR(N'specified object set does not match facet the policy condition was created off', -1, -1)
            RETURN(1) -- Failure
        END
    END

    DECLARE @policy_category_id INT
    SET @policy_category_id = NULL
    BEGIN TRANSACTION 

    DECLARE @old_policy_category_id INT
    SELECT @old_policy_category_id = policy_category_id 
        FROM syspolicy_policies 
        WHERE policy_id = @policy_id 

    IF ( (@policy_category IS NOT NULL and @policy_category != '') )
    BEGIN
        IF NOT EXISTS (SELECT * from syspolicy_policy_categories WHERE name = @policy_category)
        BEGIN
            RAISERROR(34015, -1, -1,@policy_category)
            RETURN(1) -- Failure
        END
        ELSE
            SELECT @policy_category_id = policy_category_id FROM msdb.dbo.syspolicy_policy_categories WHERE name = @policy_category
    END

        -- If the caller gave us an empty string for the
        -- @policy_category, then that means to remove the group.
    DECLARE @new_policy_category_id INT
        SELECT  @new_policy_category_id = @old_policy_category_id
    IF ( (@policy_category = '') )
                SELECT @new_policy_category_id = NULL
    ELSE IF (@policy_category_id IS NOT NULL)
                SELECT @new_policy_category_id = @policy_category_id

    UPDATE msdb.dbo.syspolicy_policies_internal
    SET 
        condition_id = ISNULL(@condition_id, condition_id),
        root_condition_id = CASE @root_condition_id WHEN -1 THEN root_condition_id ELSE @root_condition_id END,
        execution_mode = ISNULL(@execution_mode, execution_mode ),
        schedule_uid = @schedule_uid,
        policy_category_id = @new_policy_category_id, 
        description = ISNULL(@description, description),
        help_text = ISNULL(@help_text, help_text),
        help_link = ISNULL(@help_link, help_link),
        is_enabled = ISNULL(@is_enabled, is_enabled),
        object_set_id = CASE @object_set_id WHEN -1 THEN object_set_id ELSE @object_set_id END
    WHERE policy_id = @policy_id

    COMMIT TRANSACTION
    RETURN (0)
END

GO
