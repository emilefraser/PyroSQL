SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_update_condition] 
@name sysname = NULL,
@condition_id int = NULL,
@facet nvarchar(max) = NULL,
@expression nvarchar(max) = NULL,
@description nvarchar(max) = NULL,
@is_name_condition smallint = NULL,
@obj_name sysname = NULL
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

	DECLARE @retval              INT
	DECLARE @facet_id            INT

    EXEC @retval = msdb.dbo.sp_syspolicy_verify_condition_identifiers @name, @condition_id OUTPUT
    IF (@retval <> 0)
        RETURN (1)

    IF (@facet IS NOT NULL)
    BEGIN
        SET @facet_id = (SELECT management_facet_id FROM [dbo].[syspolicy_management_facets] WHERE name = @facet)
        IF (@facet_id IS NULL)
        BEGIN
            RAISERROR (34014, -1, -1)
            RETURN(1)
        END
    END

    UPDATE msdb.[dbo].[syspolicy_conditions_internal] 
    SET
        description = ISNULL(@description, description),
        facet_id = ISNULL(@facet_id, facet_id),
        expression = ISNULL(@expression, expression),
        is_name_condition = ISNULL(@is_name_condition, is_name_condition),
        obj_name = ISNULL(@obj_name, obj_name)
    WHERE condition_id = @condition_id
END

GO
