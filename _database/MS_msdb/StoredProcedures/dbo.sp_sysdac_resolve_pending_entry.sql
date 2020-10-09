SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysdac_resolve_pending_entry]  
    @action_id INT,
    @sequence_id INT
AS  
SET NOCOUNT ON;
BEGIN  
    DECLARE @null_column sysname    
    SET @null_column = NULL

    IF (@action_id IS NULL)
        SET @null_column = '@action_id'
    ELSE IF (@sequence_id IS NULL)
        SET @null_column = '@sequence_id'

    IF @null_column IS NOT NULL
    BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_sysdac_resolve_pending_entry')
        RETURN(1)
    END

    DECLARE @instance_id UNIQUEIDENTIFIER
    DECLARE @action_type TINYINT
    DECLARE @dac_object_type TINYINT        
    DECLARE @action_status TINYINT
    DECLARE @dac_object_name_pretran SYSNAME
    DECLARE @dac_object_name_posttran SYSNAME

    SELECT @instance_id = instance_id, 
            @action_type = action_type, 
            @dac_object_type = dac_object_type,
            @dac_object_name_pretran = dac_object_name_pretran, 
            @dac_object_name_posttran = dac_object_name_posttran
    FROM sysdac_history_internal
    WHERE action_id = @action_id AND sequence_id = @sequence_id

   
    --Below are the constants set based on history table    
    DECLARE @create TINYINT
    DECLARE @rename TINYINT
    DECLARE @database TINYINT
    DECLARE @success TINYINT
    DECLARE @rollback TINYINT
    DECLARE @fail TINYINT
    DECLARE @register TINYINT
    DECLARE @unregister TINYINT
    DECLARE @upgrade TINYINT
    DECLARE @readonly TINYINT
    DECLARE @readwrite TINYINT
    DECLARE @disconnectusers TINYINT
    DECLARE @readonlymode INT

    SET @create = 1
    SET @rename = 2
    SET @database = 2
    SET @success = 2
    SET @rollback = 4
    SET @fail = 3
    SET @register = 3
    SET @unregister = 14
    SET @upgrade = 15
    SET @readonly = 12
    SET @readwrite = 16
    SET @disconnectusers = 17
    SET @readonlymode = 1024
    
    SET @action_status = @fail --initialize result of the action to failure and adjust if below cases succeed!
    
    IF @action_type = @create AND @dac_object_type = @database --database create
    BEGIN
        IF EXISTS(SELECT 1 FROM sys.sysdatabases WHERE name = @dac_object_name_pretran)
            SET @action_status = @success
    END
    ELSE IF @action_type = @rename AND @dac_object_type = @database --database rename
    BEGIN
        IF (EXISTS(SELECT 1 FROM sys.sysdatabases WHERE name = @dac_object_name_posttran)) AND 
            (NOT EXISTS(SELECT 1 FROM sys.sysdatabases WHERE name = @dac_object_name_pretran))
            SET @action_status = @success 
    END
    ELSE IF @action_type = @register --register DAC
    BEGIN
        IF (EXISTS(SELECT 1 FROM dbo.sysdac_instances_internal WHERE instance_name = @dac_object_name_pretran))
            SET @action_status = @success
    END
    ELSE IF @action_type = @unregister --unregister DAC
    BEGIN
        IF (NOT EXISTS(SELECT 1 FROM dbo.sysdac_instances_internal WHERE instance_name = @dac_object_name_pretran))
            SET @action_status = @success
    END
    ELSE IF @action_type = @upgrade --upgrade DAC
    BEGIN
        IF (EXISTS(SELECT 1 FROM dbo.sysdac_instances_internal WHERE instance_name = @dac_object_name_posttran)) AND 
            (NOT EXISTS(SELECT 1 FROM dbo.sysdac_instances_internal WHERE instance_name = @dac_object_name_pretran))
            SET @action_status = @success     
    END
    ELSE IF @action_type = @readonly OR @action_type = @disconnectusers -- readonly/disconnect users state
    BEGIN
        IF (EXISTS(SELECT 1 FROM sys.sysdatabases 
                            WHERE ((status & @readonlymode) = @readonlymode) AND name=@dac_object_name_pretran))
            SET @action_status = @success
    END
    ELSE IF @action_type = @readwrite -- readwrite state
    BEGIN
        IF (EXISTS(SELECT 1 FROM sys.sysdatabases 
                            WHERE ((status & @readonlymode) != @readonlymode) AND name=@dac_object_name_pretran))
            SET @action_status = @success
    END

    UPDATE sysdac_history_internal
    SET action_status = @action_status
    WHERE action_id = @action_id AND sequence_id = @sequence_id
    
END

GO
