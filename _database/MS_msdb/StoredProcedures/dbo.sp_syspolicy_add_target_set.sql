SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_add_target_set] 
@object_set_id int = NULL,
@object_set_name sysname = NULL,
@type_skeleton nvarchar(max),
@type sysname,
@enabled bit,
@target_set_id int OUTPUT
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

	DECLARE @retval              INT

    EXEC @retval = dbo.sp_syspolicy_verify_object_set_identifiers @name = @object_set_name OUTPUT, @object_set_id = @object_set_id OUTPUT
    if( @retval <> 0)
        RETURN(1)
    
    INSERT INTO msdb.[dbo].[syspolicy_target_sets_internal]
                                        (object_set_id,
                                        type_skeleton,
                                        type,
                                        enabled)
    VALUES                            
                                        (@object_set_id, 
                                        @type_skeleton,
                                        @type,
                                        @enabled)

    SELECT @retval = @@error
    SET @target_set_id = SCOPE_IDENTITY()
    RETURN(@retval)
END

GO
