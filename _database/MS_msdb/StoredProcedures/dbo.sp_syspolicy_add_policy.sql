SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_add_policy] 
@name sysname,
@condition_id int = NULL,
@condition_name sysname = NULL,
@schedule_uid uniqueidentifier = NULL,
@policy_category sysname = NULL,
@description nvarchar(max) = N'',
@help_text nvarchar(4000) = N'',
@help_link nvarchar(2083) = N'',
@execution_mode int,
@is_enabled bit = 0,
@root_condition_id int = NULL,
@root_condition_name sysname = NULL,
@object_set sysname = NULL,
@policy_id int = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
    DECLARE @retval_check int;
    EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
    IF ( 0!= @retval_check)
    BEGIN
        RETURN @retval_check
    END

    DECLARE @retval         INT
    DECLARE @null_column    sysname
    
    SET @null_column = NULL

    IF (@name IS NULL OR @name = N'')
        SET @null_column = '@name'
    ELSE IF (@execution_mode IS NULL )
        SET @null_column = '@execution_mode'
    ELSE IF( @is_enabled IS NULL)
        SET @null_column = '@is_enabled'
    ELSE IF( @description IS NULL)
        SET @null_column = '@description'
    ELSE IF( @help_text IS NULL)
        SET @null_column = '@help_text'
    ELSE IF( @help_link IS NULL)
        SET @null_column = '@help_link'
    

    IF @null_column IS NOT NULL
    BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_syspolicy_add_policy')
        RETURN(1)
    END

    IF EXISTS (SELECT * FROM msdb.dbo.syspolicy_policies WHERE name = @name)
    BEGIN
        RAISERROR(34010, -1, -1, 'Policy', @name)
        RETURN(1)
    END

    SET @schedule_uid = ISNULL (@schedule_uid, '{00000000-0000-0000-0000-000000000000}')

    --Check for the execution mode value
    IF (@execution_mode NOT IN (0,1,2,4,5,6))
    BEGIN 
        RAISERROR(34004, -1, -1, @execution_mode)
        RETURN (1)
    END

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

    -- Turn [nullable] empty string parameters into NULLs
    IF @condition_name = '' SELECT @condition_name = NULL
    IF @policy_category = ''   SELECT @policy_category = NULL
    IF @root_condition_name = '' SELECT @root_condition_name = NULL

    -- verify that the condition exists
    EXEC @retval = msdb.dbo.sp_syspolicy_verify_condition_identifiers @condition_name = @condition_name OUTPUT, @condition_id = @condition_id OUTPUT
    IF (@retval <> 0)
        RETURN(1)
        
    -- convert @object_set into id if needed
    DECLARE @object_set_id INT
    DECLARE @object_set_facet_id INT
    IF (@object_set IS NOT NULL)
    BEGIN
        SELECT @object_set_id = object_set_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name = @object_set
        IF @object_set_id IS NULL
        BEGIN
            -- TODO: RAISERROR that specified object set doesn't exist
            RAISERROR(N'specified object set does not exists', -1, -1)
            RETURN(1) -- Failure
        END
        ELSE
        BEGIN
            SELECT @object_set_facet_id = facet_id FROM msdb.dbo.syspolicy_object_sets WHERE object_set_name = @object_set
            -- Ensure the object set has been created from the same facet that the policy condition has been created
            IF (@object_set_facet_id <> (SELECT facet_id FROM msdb.dbo.syspolicy_conditions_internal WHERE condition_id = @condition_id))
            BEGIN
                -- TODO: RAISEERROR that specified object_set isn't created from the facet that the policy condition has been created from
                RAISERROR(N'specified object set does not match facet the policy condition was created off', -1, -1)
                RETURN(1) -- Failure
            END
        END
    END

    IF (@root_condition_name IS NOT NULL) OR (@root_condition_id IS NOT NULL)
    BEGIN
        -- verify that the root condition exists
        EXEC @retval = msdb.dbo.sp_syspolicy_verify_condition_identifiers @condition_name = @root_condition_name OUTPUT, @condition_id = @root_condition_id OUTPUT
        IF (@retval <> 0)
            RETURN(1)
            
        -- Check execution mode for compatibility with root_condition
        IF (@execution_mode = 1) OR (@execution_mode = 2) -- Enforce or Check on Change
        BEGIN
            RAISERROR (34011, -1, -1, 'root_condition', @execution_mode)
            RETURN(1)
        END

    END

    -- verify schedule
    IF (@schedule_uid != '{00000000-0000-0000-0000-000000000000}')
    BEGIN
        IF NOT EXISTS (SELECT * FROM msdb.dbo.sysschedules WHERE schedule_uid = @schedule_uid)
        BEGIN
            RAISERROR(14365, -1, -1)
            RETURN(1) -- Failure
        END
    END

    -- convert group_name into id if needed
    DECLARE @policy_category_id INT
    IF ( (@policy_category IS NOT NULL) )
    BEGIN 
        IF NOT EXISTS (SELECT * from msdb.dbo.syspolicy_policy_categories WHERE name = @policy_category)
        BEGIN
            RAISERROR(34015, -1, -1,@policy_category)
            RETURN(1) -- Failure
        END
        ELSE
            SELECT @policy_category_id = policy_category_id FROM msdb.dbo.syspolicy_policy_categories WHERE name = @policy_category
    END
    
    INSERT INTO msdb.dbo.syspolicy_policies_internal
                                        (name, 
                                        execution_mode, 
                                        schedule_uid,
                                        policy_category_id,
                                        description,
                                        help_text,
                                        help_link,
                                        condition_id,
                                        root_condition_id,
                                        object_set_id,
                                        is_enabled)
    VALUES                            
                                        (@name, 
                                        @execution_mode, 
                                        @schedule_uid,
                                        @policy_category_id,
                                        @description,
                                        @help_text,
                                        @help_link,
                                        @condition_id,
                                        @root_condition_id,
                                        @object_set_id,
                                        @is_enabled)

    SELECT @retval = @@error
    SET @policy_id = SCOPE_IDENTITY()
    RETURN(@retval)
END

GO
