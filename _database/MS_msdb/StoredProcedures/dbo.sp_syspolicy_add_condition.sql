SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_add_condition] 
@name sysname,
@description nvarchar(max) = N'',
@facet nvarchar(max),
@expression nvarchar(max),
@is_name_condition smallint = 0,
@obj_name sysname = NULL,
@condition_id int = NULL OUTPUT 
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
	DECLARE @null_column	sysname
	
	SET @null_column = NULL

    IF (@name IS NULL OR @name = N'')
        SET @null_column = '@name'
    ELSE IF( @description IS NULL)
        SET @null_column = '@description'
    ELSE IF( @facet IS NULL)
        SET @null_column = '@facet'
    ELSE IF( @expression IS NULL)
        SET @null_column = '@expression'

    IF @null_column IS NOT NULL
    BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_syspolicy_add_condition')
        RETURN(1)
    END

    IF EXISTS (SELECT * FROM msdb.dbo.syspolicy_conditions WHERE name = @name)
    BEGIN
        RAISERROR(34010, -1, -1, 'Condition', @name)
        RETURN(1)
    END

    SET @facet_id = (SELECT management_facet_id FROM [dbo].[syspolicy_management_facets] WHERE name = @facet)
    IF (@facet_id IS NULL)
    BEGIN
        RAISERROR (34014, -1, -1)
        RETURN(1)
    END

    INSERT INTO msdb.dbo.syspolicy_conditions_internal(name, description,facet_id,expression,is_name_condition,obj_name) 
        VALUES(@name, @description,@facet_id,@expression,@is_name_condition,@obj_name)
    SELECT @retval = @@error
    SET @condition_id = SCOPE_IDENTITY()
    RETURN(@retval)
END

GO
