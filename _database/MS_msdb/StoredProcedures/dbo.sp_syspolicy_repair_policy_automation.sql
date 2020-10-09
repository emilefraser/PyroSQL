SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_repair_policy_automation]
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole';
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check;
	END

    BEGIN TRANSACTION;

    BEGIN TRY
        SET NOCOUNT ON
        
        DECLARE @policies_copy TABLE (
                            policy_id int ,
                            name sysname NOT NULL,
                            condition_id int NOT NULL,
                            root_condition_id int NULL,
                            execution_mode int NOT NULL,
                            policy_category_id int NULL,
                            schedule_uid uniqueidentifier NULL,
                            description nvarchar(max) NOT NULL ,
                            help_text nvarchar(4000) NOT NULL ,
                            help_link nvarchar(2083) NOT NULL ,
                            object_set_id INT NULL,
                            is_enabled bit NOT NULL,
                           	is_system bit NOT NULL);

        INSERT INTO @policies_copy 
            SELECT          policy_id,
                            name, 
                            condition_id, 
                            root_condition_id, 
                            execution_mode, 
                            policy_category_id, 
                            schedule_uid, 
                            description,
                            help_text,
                            help_link,
                            object_set_id,
                            is_enabled,
                            is_system
            FROM msdb.dbo.syspolicy_policies_internal;
        
        DELETE FROM syspolicy_policies_internal;
        
        SET IDENTITY_INSERT msdb.dbo.syspolicy_policies_internal ON
        INSERT INTO msdb.dbo.syspolicy_policies_internal (
                            policy_id,
                            name, 
                            condition_id, 
                            root_condition_id, 
                            execution_mode, 
                            policy_category_id, 
                            schedule_uid, 
                            description,
                            help_text,
                            help_link,
                            object_set_id,
                            is_enabled,
                            is_system)
            SELECT 
                            policy_id,
                            name, 
                            condition_id, 
                            root_condition_id, 
                            execution_mode, 
                            policy_category_id, 
                            schedule_uid, 
                            description,
                            help_text,
                            help_link,
                            object_set_id,
                            is_enabled,
                            is_system
            FROM @policies_copy;
            
        SET IDENTITY_INSERT msdb.dbo.syspolicy_policies_internal OFF;
        
        SET NOCOUNT OFF;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RAISERROR (14351, -1, -1);
        RETURN 1;
    END CATCH

    -- commit the transaction we started
    COMMIT TRANSACTION;
    
END

GO
