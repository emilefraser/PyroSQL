SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_sysdac_delete_history]  
    @dac_instance_name sysname, 
    @older_than datetime
AS  
SET NOCOUNT ON;
BEGIN  
    DECLARE @retval INT  
    DECLARE @instanceId UniqueIdentifier

    SELECT @older_than = COALESCE(@older_than, GETDATE())


    IF @dac_instance_name IS NULL
    BEGIN
       -- Delete everyone who is not orphaned that you have visibility to 
       DELETE FROM dbo.sysdac_history_internal
              WHERE instance_id IN (SELECT instance_id FROM dbo.sysdac_instances)
              AND (date_modified < @older_than)

       -- Also remove orphans (note that we need to look into sysdac_instances_internal table)
       DELETE FROM dbo.sysdac_history_internal
              WHERE instance_id NOT IN( SELECT instance_id FROM dbo.sysdac_instances_internal)
              AND (date_modified < @older_than)
    END
    ELSE
    BEGIN
        -- Delete all entries that the user can view (i.e own the DAC or be sysadmin)
        DELETE FROM dbo.sysdac_history_internal
        WHERE instance_id IN (
            SELECT instance_id 
            FROM dbo.sysdac_instances 
            WHERE instance_name = @dac_instance_name)
        AND (date_modified < @older_than)
    END


    SELECT @retval = @@error
    RETURN(@retval)
END

GO
