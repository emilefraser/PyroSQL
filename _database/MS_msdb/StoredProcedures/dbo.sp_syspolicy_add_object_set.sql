SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_add_object_set]
@object_set_name sysname,
@facet nvarchar (max),
@object_set_id int OUTPUT
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

	DECLARE @retval             INT
	
	DECLARE @facet_id           INT
	DECLARE @null_column		sysname
	
	IF( @facet IS NULL)
		SET @null_column = '@facet'
		
	IF @null_column IS NOT NULL
	BEGIN
		RAISERROR(14043, -1, -1, @null_column, 'sp_syspolicy_add_object_set')
		RETURN(1)
	END

    SET @facet_id = (SELECT management_facet_id FROM [dbo].[syspolicy_management_facets] WHERE name = @facet)
        
    IF (@facet_id IS NULL)
    BEGIN
        RAISERROR (34014, -1, -1)
        RETURN(1)
    END

    INSERT INTO msdb.[dbo].[syspolicy_object_sets_internal]
                                        (object_set_name,
                                        facet_id)
    VALUES                            
                                        (@object_set_name,
                                        @facet_id)

    SELECT @retval = @@error
    SET @object_set_id = SCOPE_IDENTITY()
    RETURN(@retval)
END

GO
