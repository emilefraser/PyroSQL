SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_reassign_proxy
	@current_proxy_id [int] = NULL,  -- must specify either @current_proxy_id or @current_proxy_name
	@current_proxy_name [sysname] = NULL,
	@target_proxy_id [int] = NULL,  -- must specify either @target_proxy_id or @target_proxy_name
	@target_proxy_name [sysname] = NULL -- N'' is a special case to allow change of an existing proxy as NULL (run job step in sql agent service account context)
AS
BEGIN
    DECLARE @retval   INT
    SET NOCOUNT ON

    -- validate current proxy id
    EXECUTE @retval = sp_verify_proxy_identifiers '@current_proxy_name',
                                                 '@current_proxy_id',
                                                @current_proxy_name OUTPUT,
                                                 @current_proxy_id   OUTPUT

    IF (@retval <> 0)
    BEGIN
        -- exception message was raised inside sp_verify_proxy_identifiers; we dont need to RAISERROR again here
        RETURN(1) -- Failure
    END

    -- @target_proxy_name = N'' is a special case to allow change of an existing proxy as NULL (run job step in sql agent service account context)
    IF (@target_proxy_id IS NOT NULL) OR (@target_proxy_name IS NOT NULL AND @target_proxy_name <> N'')
    BEGIN
        EXECUTE @retval = sp_verify_proxy_identifiers '@target_proxy_name',
                                                 '@target_proxy_id',
                                                 @target_proxy_name OUTPUT,
                                                 @target_proxy_id   OUTPUT

        IF (@retval <> 0)
        BEGIN
            -- exception message was raised inside sp_verify_proxy_identifiers; we dont need to RAISERROR again here
            RETURN(1) -- Failure
        END
    END

    -- Validate that  current proxy id and target proxy id are not the same
    IF(@current_proxy_id = @target_proxy_id)
    BEGIN
        RAISERROR(14399, -1, -1, @current_proxy_id, @target_proxy_id)
	RETURN(1) -- Failure
    END

    DECLARE @job_id UNIQUEIDENTIFIER
    DECLARE @step_id int
    DECLARE @proxy_id int
    DECLARE @subsystem_id int

    -- cursor to enumerate list of job steps what has proxy_id as current proxy_id
    DECLARE @jobstep_cursor CURSOR
    SET @jobstep_cursor = CURSOR FOR
    SELECT js.job_id, js.step_id,  js.proxy_id , subsys.subsystem_id
    FROM sysjobsteps js
    JOIN syssubsystems subsys ON js.subsystem = subsys.subsystem
    WHERE js.proxy_id = @current_proxy_id

    OPEN @jobstep_cursor
    FETCH NEXT FROM @jobstep_cursor INTO @job_id, @step_id, @proxy_id, @subsystem_id

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- current proxy might have been granted to be used by this specific subsystem
        -- making sure that the target proxy has been granted access to same subsystem
        -- Grant target proxy to subsystem if it was not granted before
        IF NOT EXISTS( SELECT  DISTINCT ps.proxy_id, subsyst.subsystem_id
                        FROM  syssubsystems subsyst
                        JOIN sysproxysubsystem  ps ON  (ps.subsystem_id = subsyst.subsystem_id
				                        AND ps.proxy_id = @target_proxy_id
				                        AND ps.subsystem_id = @subsystem_id)
                    )
        BEGIN
            -- throw error that user needs to grant permission to this target proxy
            IF @target_proxy_id IS NOT NULL
            BEGIN
		     RAISERROR(14400, -1, -1, @target_proxy_id, @subsystem_id)
		     RETURN(1) -- Failure
            END
        END

        -- Update proxy_id for job step with target proxy id using sp_update_jobstep
        EXEC sp_update_jobstep @job_id = @job_id, @step_id = @step_id , @proxy_name = @target_proxy_name

        FETCH NEXT FROM @jobstep_cursor INTO @job_id, @step_id, @proxy_id, @subsystem_id
    END

    CLOSE @jobstep_cursor
    DEALLOCATE @jobstep_cursor

    RETURN(0)
END

GO
