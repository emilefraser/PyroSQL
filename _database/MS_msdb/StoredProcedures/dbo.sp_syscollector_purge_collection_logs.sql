SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_purge_collection_logs]
    @reference_date datetime = NULL,
    @delete_batch_size int = 500
AS
BEGIN
    SET NOCOUNT ON

    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_proxy'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_proxy')
        RETURN(1) -- Failure
    END

    IF (@reference_date IS NULL)
    BEGIN
        SET @reference_date = GETDATE()
    END
    
    -- An expired log record is any record of a collection set that is older than 
    -- the reference date minus the collection set's days_until_expiration
    CREATE TABLE #purged_log_ids (log_id BIGINT, package_execution_id uniqueidentifier)
    
    -- Identify logs to purge based on following criteria
    -- a) limit max batch size 
    -- b) do not delete last log record that is a root log record for a collection set
    INSERT INTO #purged_log_ids
    SELECT TOP (@delete_batch_size) log_id, package_execution_id
    FROM syscollector_execution_log_internal as l
    INNER JOIN syscollector_collection_sets s ON l.collection_set_id = s.collection_set_id
    WHERE s.days_until_expiration > 0
    AND @reference_date >= DATEADD(DAY, s.days_until_expiration, l.finish_time)
    AND log_id NOT IN (
                        SELECT TOP 1 log_id  from syscollector_execution_log_internal 
                        WHERE parent_log_id IS NULL 
                        AND collection_set_id = l.collection_set_id
                        ORDER BY start_time DESC
                        )

    DECLARE @purge_log_count int
    SELECT @purge_log_count  = COUNT(log_id) 
    FROM  #purged_log_ids

    -- Delete all ssis log records pertaining to expired logs
    DELETE FROM dbo.sysssislog
        FROM dbo.sysssislog AS s
        INNER JOIN #purged_log_ids AS i ON i.package_execution_id = s.executionid
        
    -- Then delete the actual logs
    DELETE FROM syscollector_execution_log_internal
        FROM syscollector_execution_log_internal AS l
        INNER Join #purged_log_ids AS i ON i.log_id = l.log_id


    DROP TABLE #purged_log_ids

    -- making sure that delete # record does not exceed given delete batch size
    DECLARE @orphaned_record_cleanup_count int
    SET @orphaned_record_cleanup_count = @delete_batch_size - @purge_log_count

    -- Go for another round to cleanup the orphans
    -- Ideally, the log heirarchy guarantees that a finish time by a parent log will always
    -- be higher than the finish time of any of its descendants.
    -- The purge step however does not delete log records with a null finish time
    -- A child log can have a null finish time while its parent is closed if there is an
    -- error in execution that causes the log to stay open.
    -- If such a child log exists, its parent will be purged leaving it as an orphan
    
    -- get orphan records and all their descendants in a cursor and purge them
    DECLARE orphaned_log_cursor INSENSITIVE CURSOR FOR
            SELECT TOP (@orphaned_record_cleanup_count) log_id 
            FROM syscollector_execution_log_internal
            WHERE parent_log_id NOT IN (
                SELECT log_id FROM syscollector_execution_log_internal
            )
            FOR READ ONLY
            
    DECLARE @log_id BIGINT

    -- for every orphan, delete all its remaining tree
    -- this is supposedly a very small fraction of the entire log
    OPEN orphaned_log_cursor    
    FETCH orphaned_log_cursor INTO @log_id
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC sp_syscollector_delete_execution_log_tree @log_id = @log_id, @from_collection_set = 0
        FETCH orphaned_log_cursor INTO @log_id
    END
    
    CLOSE orphaned_log_cursor
    DEALLOCATE orphaned_log_cursor
END

GO
