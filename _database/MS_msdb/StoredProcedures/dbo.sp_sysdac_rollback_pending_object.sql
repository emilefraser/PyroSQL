SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysdac_rollback_pending_object]  
    @action_id INT
AS  
SET NOCOUNT ON;
BEGIN  
    IF (@action_id IS NULL)
    BEGIN
        RAISERROR(14043, -1, -1, '@action_id', 'sp_sysdac_rollback_pending_object')
        RETURN(1)
    END

    DECLARE @sequence_id INT
    DECLARE @action_status TINYINT

    --Below are the constants set based on history table    
    DECLARE @header_id bit
    DECLARE @pending TINYINT
    DECLARE @success TINYINT
    DECLARE @true bit
    DECLARE @rollback TINYINT
    DECLARE @fail TINYINT
    DECLARE @rollback_failure TINYINT

    SET @header_id = 0
    SET @pending = 1
    SET @success = 2
    SET @true = 1
    SET @rollback = 4
    SET @fail = 3
    SET @rollback_failure = 2
    
    --if step 0 is not pending, exit
    IF ((SELECT action_status 
        FROM sysdac_history_internal 
        WHERE action_id = @action_id AND sequence_id = @header_id) != @pending)
        RETURN;

    
    --STEP 1. Resolve pending entry 
    SET @sequence_id = (SELECT TOP 1 sequence_id 
                        FROM sysdac_history_internal 
                        WHERE sequence_id != @header_id AND action_id = @action_id AND action_status = @pending)

    IF (@sequence_id IS NOT NULL)
        EXEC dbo.sp_sysdac_resolve_pending_entry @action_id = @action_id, @sequence_id = @sequence_id
    
    --check if all required steps are committed(success). If so, mark the action success and return!
    IF NOT EXISTS (SELECT 1
                    FROM sysdac_history_internal 
                    WHERE action_id = @action_id AND sequence_id != @header_id AND required = @true AND action_status != @success)
    BEGIN
        UPDATE dbo.sysdac_history_internal
        SET action_status = @success
        WHERE action_id = @action_id AND sequence_id = @header_id
    
        RETURN
    END
     
    BEGIN TRY
        
        --STEP 2. rollback commit entries
        WHILE EXISTS( SELECT 1 
                        FROM sysdac_history_internal 
                        WHERE action_status = @success AND action_id = @action_id AND sequence_id > 0)
        BEGIN
            SELECT TOP 1 @sequence_id = sequence_id,
                        @action_status = action_status
            FROM sysdac_history_internal
            WHERE action_status = @success AND action_id = @action_id AND sequence_id != @header_id
            ORDER BY sequence_id DESC

            EXEC dbo.sp_sysdac_rollback_committed_step @action_id = @action_id, @sequence_id = @sequence_id
            
        END

        --Mark the header entry as rolledback
        SET @action_status = @rollback    

    END TRY
    BEGIN CATCH
        DECLARE @error_message NVARCHAR(4000);
        
        SELECT @error_message = ERROR_MESSAGE()

        RAISERROR(N'%d, %d, %s', -1, 1, @sequence_id, @rollback_failure, @error_message) WITH NOWAIT

        --Mark the header entry as failed
        SET @action_status = @fail
    END CATCH

    --STEP 3. Mark the header entry with final action status
    UPDATE dbo.sysdac_history_internal
    SET action_status = @action_status
    WHERE action_id = @action_id AND sequence_id = @header_id    

END

GO
