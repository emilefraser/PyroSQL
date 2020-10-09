SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysdac_rollback_committed_step]  
    @action_id INT,
    @sequence_id INT
AS  
SET NOCOUNT ON;
BEGIN  
    DECLARE @retval INT  

    DECLARE @null_column sysname    
    SET @null_column = NULL

    IF (@action_id IS NULL)
        SET @null_column = '@action_id'
    ELSE IF (@sequence_id IS NULL)
        SET @null_column = '@sequence_id'

    IF @null_column IS NOT NULL
    BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_sysdac_rollback_committed_step')
        RETURN(1)
    END

    DECLARE @instance_id UNIQUEIDENTIFIER
    DECLARE @part_name NVARCHAR(128)
    DECLARE @action_type TINYINT
    DECLARE @dac_object_type TINYINT        
    DECLARE @action_status TINYINT
    DECLARE @dac_object_name_pretran SYSNAME
    DECLARE @dac_object_name_posttran SYSNAME
    DECLARE @sqlstatement NVARCHAR(1000)        

    SELECT @instance_id = instance_id, 
            @action_id = action_id, 
            @action_type = action_type, 
            @sequence_id = sequence_id,
            @dac_object_type = dac_object_type,
            @action_status = action_status, 
            @dac_object_name_pretran = dac_object_name_pretran, 
            @dac_object_name_posttran = dac_object_name_posttran
    FROM sysdac_history_internal
    WHERE action_id = @action_id AND sequence_id = @sequence_id
    
    --Below are the constants set based on history table    
    DECLARE @create TINYINT
    DECLARE @rename TINYINT
    DECLARE @register TINYINT
    DECLARE @database TINYINT
    DECLARE @rollback TINYINT
    DECLARE @rollback_pending TINYINT
    DECLARE @rollback_success TINYINT
    DECLARE @setreadonly TINYINT
    DECLARE @setreadwrite TINYINT

    SET @create = 1
    SET @rename = 2
    SET @register = 3
    SET @database = 2
    SET @rollback = 4
    SET @rollback_pending = 0
    SET @rollback_success = 1
    SET @setreadonly = 12
    SET @setreadwrite = 16
    
    IF @action_type = @create AND @dac_object_type = @database --database create
    BEGIN
        RAISERROR(N'%d, %d, %s', -1, 1, @sequence_id, @rollback_pending, NULL) WITH NOWAIT

        EXEC dbo.sp_sysdac_drop_database @database_name = @dac_object_name_pretran
        
        RAISERROR(N'%d, %d, %s', -1, 1, @sequence_id, @rollback_success, NULL) WITH NOWAIT
    END
    ELSE IF @action_type = @rename AND @dac_object_type = @database --database rename
    BEGIN
        RAISERROR(N'%d, %d, %s', -1, 1, @sequence_id, @rollback_pending, NULL) WITH NOWAIT

        EXEC dbo.sp_sysdac_rename_database @dac_object_name_posttran, @dac_object_name_pretran

        RAISERROR(N'%d, %d, %s', -1, 1, @sequence_id, @rollback_success, NULL) WITH NOWAIT
    END
    ELSE IF @action_type = @register --register DAC
    BEGIN
        SET @instance_id = (
            SELECT instance_id 
            FROM dbo.sysdac_instances_internal 
            WHERE instance_name = @dac_object_name_pretran)

        RAISERROR(N'%d, %d, %s', -1, 1, @sequence_id, @rollback_pending, NULL) WITH NOWAIT

        EXEC dbo.sp_sysdac_delete_instance @instance_id = @instance_id

        RAISERROR(N'%d, %d, %s', -1, 1, @sequence_id, @rollback_success, NULL) WITH NOWAIT
    END
    ELSE IF @action_type = @setreadonly  --readonly step
    BEGIN
        RAISERROR(N'%d, %d, %s', -1, 1, @sequence_id, @rollback_pending, NULL) WITH NOWAIT

        EXEC dbo.sp_sysdac_setreadonly_database @database_name = @dac_object_name_pretran, @readonly = 1

        RAISERROR(N'%d, %d, %s', -1, 1, @sequence_id, @rollback_success, NULL) WITH NOWAIT        
    END
    ELSE IF @action_type = @setreadwrite  --readonly step
    BEGIN
        RAISERROR(N'%d, %d, %s', -1, 1, @sequence_id, @rollback_pending, NULL) WITH NOWAIT

        EXEC dbo.sp_sysdac_setreadonly_database @database_name = @dac_object_name_pretran, @readonly = 0

        RAISERROR(N'%d, %d, %s', -1, 1, @sequence_id, @rollback_success, NULL) WITH NOWAIT        
    END
    
    --mark the entry as rolledback
    UPDATE sysdac_history_internal
    SET action_status = @rollback
    WHERE action_id = @action_id AND sequence_id = @sequence_id
    
    SELECT @retval = @@error
    RETURN(@retval)
END

GO
