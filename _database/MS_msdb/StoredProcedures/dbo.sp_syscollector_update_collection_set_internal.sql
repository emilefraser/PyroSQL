SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_update_collection_set_internal]
    @collection_set_id          int,
    @collection_set_uid         uniqueidentifier,
    @name                       sysname,
    @new_name                   sysname,
    @target                     nvarchar(128),
    @collection_mode            smallint,         
    @days_until_expiration      smallint,
    @proxy_id                   int,              
    @proxy_name                 sysname,          
    @schedule_uid               uniqueidentifier, 
    @schedule_name              sysname,          
    @logging_level              smallint,
    @description                nvarchar(4000),   
    @schedule_id                int,
    @old_collection_mode        smallint,
    @old_proxy_id               int,
    @old_collection_job_id      uniqueidentifier,
    @old_upload_job_id          uniqueidentifier    
AS
BEGIN
    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_update_collection_set
    ELSE
        BEGIN TRANSACTION
    BEGIN TRY
        DECLARE @old_upload_schedule_id    int
        DECLARE @old_upload_schedule_uid uniqueidentifier

        SELECT  @old_upload_schedule_id = sv.schedule_id,
                @old_upload_schedule_uid = cs.schedule_uid
        FROM dbo.syscollector_collection_sets cs 
        JOIN sysschedules_localserver_view sv ON (cs.schedule_uid = sv.schedule_uid)
        WHERE collection_set_id = @collection_set_id

        -- update job names, schedule, and collection mode in a transaction to maintain a consistent state in case of failures
        IF (@collection_mode IS NOT NULL AND @collection_mode != @old_collection_mode)
        BEGIN
            IF (@schedule_id IS NULL)
            BEGIN
                -- if no schedules is supplied as a parameter to this update SP, 
                -- we can use the one that is already in the collection set table
                SET @schedule_uid = @old_upload_schedule_uid
                
                SELECT @schedule_id = schedule_id 
                FROM sysschedules_localserver_view 
                WHERE @schedule_uid = schedule_uid
            END

            IF (@schedule_name IS NOT NULL AND @schedule_name = N'')
            BEGIN
                SET @schedule_id = NULL 
            END

            -- make sure there exists a schedule we can use
            IF (@old_collection_mode = 1 AND @schedule_id IS NULL) -- a switch from non-cached to cached mode require a schedule
            BEGIN
                -- no schedules specified in input or collection set table, raise error
                RAISERROR(14683, -1, -1)
                RETURN (1)
            END

            -- Only update the jobs if we have jobs already created. Otherwise the right
            -- jobs will be created when the collection set starts for the first time.
            IF (@old_collection_job_id IS NOT NULL AND @old_upload_job_id IS NOT NULL)
            BEGIN
                -- create new jobs 
                DECLARE @collection_job_id        uniqueidentifier 
                DECLARE @upload_job_id            uniqueidentifier 

                DECLARE @collection_set_name sysname;
                SET @collection_set_name = ISNULL(@new_name, @name);
                EXEC [dbo].[sp_syscollector_create_jobs] 
                    @collection_set_id        = @collection_set_id,
                    @collection_set_uid     = @collection_set_uid,
                    @collection_set_name    = @collection_set_name,
                    @proxy_id                = @proxy_id,
                    @schedule_id            = @schedule_id,
                    @collection_mode        = @collection_mode,
                    @collection_job_id        = @collection_job_id OUTPUT,
                    @upload_job_id            = @upload_job_id OUTPUT

                UPDATE [dbo].[syscollector_collection_sets_internal]
                SET
                    upload_job_id        = @upload_job_id,
                    collection_job_id    = @collection_job_id
                WHERE @collection_set_id = collection_set_id
                
                -- drop old upload and collection jobs
                EXEC dbo.sp_syscollector_delete_jobs 
                    @collection_job_id        = @old_collection_job_id,
                    @upload_job_id            = @old_upload_job_id,
                    @schedule_id            = @old_upload_schedule_id,
                    @collection_mode        = @old_collection_mode
            END
        END
        ELSE -- collection mode unchanged, we do not have to recreate the jobs
        BEGIN
            -- we need to update the proxy id for all job steps
            IF (@old_proxy_id <> @proxy_id) OR (@old_proxy_id IS NULL AND @proxy_id IS NOT NULL)
            BEGIN
                IF (@old_collection_job_id IS NOT NULL)
                BEGIN
                    EXEC dbo.sp_syscollector_update_job_proxy
                        @job_id    = @old_collection_job_id, 
                        @proxy_id  = @proxy_id
                END

                IF (@old_upload_job_id IS NOT NULL)
                BEGIN
                    EXEC dbo.sp_syscollector_update_job_proxy
                        @job_id    = @old_upload_job_id, 
                        @proxy_id  = @proxy_id
                END
            END
            IF (@proxy_name = N'' AND @old_proxy_id IS NOT NULL) 
            BEGIN
                IF (@old_collection_job_id IS NOT NULL)
                BEGIN
                    EXEC dbo.sp_syscollector_update_job_proxy
                        @job_id    = @old_collection_job_id, 
                        @proxy_name = @proxy_name
                END

                IF (@old_upload_job_id IS NOT NULL)
                BEGIN
                    EXEC dbo.sp_syscollector_update_job_proxy
                        @job_id    = @old_upload_job_id, 
                        @proxy_name = @proxy_name
                END
            END

            -- need to update the schedule
            IF (@old_upload_schedule_id <> @schedule_id) OR (@old_upload_schedule_id IS NULL AND @schedule_id IS NOT NULL)
            BEGIN
                -- detach the old schedule 
                IF (@old_upload_job_id IS NOT NULL) AND (@old_upload_schedule_id IS NOT NULL)
                BEGIN
                    EXEC dbo.sp_detach_schedule 
                        @job_id            = @old_upload_job_id,
                        @schedule_id    = @old_upload_schedule_id,
                        @delete_unused_schedule = 0
                END

                -- attach the new schedule
                IF (@old_upload_job_id IS NOT NULL)
                BEGIN
                    EXEC dbo.sp_attach_schedule
                        @job_id            = @old_upload_job_id,
                        @schedule_id    = @schedule_id
                END
            END

            -- special case - remove the existing schedule
            IF (@schedule_name = N'') AND (@old_upload_schedule_id IS NOT NULL)
            BEGIN
                EXEC dbo.sp_detach_schedule 
                    @job_id            = @old_upload_job_id,
                    @schedule_id    = @old_upload_schedule_id,
                    @delete_unused_schedule = 0
            END
        END

        -- after the all operations succeed, update the sollection_sets table
        DECLARE @new_proxy_id int
        SET @new_proxy_id = @proxy_id
        IF (@proxy_name    = N'')    SET @new_proxy_id = NULL

        UPDATE [dbo].[syscollector_collection_sets_internal]
        SET
            name                    = ISNULL(@new_name, name),
            target                    = ISNULL(@target, target),
            proxy_id                = @new_proxy_id,
            collection_mode            = ISNULL(@collection_mode, collection_mode),
            logging_level            = ISNULL(@logging_level, logging_level),
            days_until_expiration   = ISNULL(@days_until_expiration, days_until_expiration)
        WHERE @collection_set_id = collection_set_id

        IF (@schedule_uid IS NOT NULL OR @schedule_name IS NOT NULL)
        BEGIN
            IF (@schedule_name = N'')    SET @schedule_uid = NULL

            UPDATE [dbo].[syscollector_collection_sets_internal]
            SET schedule_uid = @schedule_uid
            WHERE @collection_set_id = collection_set_id
        END

        IF (@description IS NOT NULL)
        BEGIN
            IF (@description = N'')      SET @description = NULL

            UPDATE [dbo].[syscollector_collection_sets_internal]
            SET description = @description
            WHERE @collection_set_id = collection_set_id
        END

        IF (@TranCounter = 0)
        COMMIT TRANSACTION
        RETURN (0)
    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_update_collection_set

        DECLARE @ErrorMessage   NVARCHAR(4000);
        DECLARE @ErrorSeverity  INT;
        DECLARE @ErrorState     INT;
        DECLARE @ErrorNumber    INT;
        DECLARE @ErrorLine      INT;
        DECLARE @ErrorProcedure NVARCHAR(200);
        SELECT @ErrorLine = ERROR_LINE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorNumber = ERROR_NUMBER(),
               @ErrorMessage = ERROR_MESSAGE(),
               @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

        RAISERROR (14684, @ErrorSeverity, -1 , @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage);
        
        RETURN (1)
    END CATCH
END

GO
