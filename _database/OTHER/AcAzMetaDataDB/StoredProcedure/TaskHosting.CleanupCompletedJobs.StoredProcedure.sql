SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[CleanupCompletedJobs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[CleanupCompletedJobs] AS' 
END
GO

--Job will not be deleted automatically like message. Upload/Download job will be removed when clean up blob.
--This SP is to remove other type of jobs which has been completed. It will be invoked in Scheduler.
ALTER PROCEDURE [TaskHosting].[CleanupCompletedJobs]
AS
BEGIN

    DECLARE @RowsAffected BIGINT
    DECLARE @DeleteBatchSize BIGINT

    SET @DeleteBatchSize = 1000
    SET @RowsAffected = @DeleteBatchSize

    WHILE (@RowsAffected = @DeleteBatchSize)
    BEGIN
        DELETE TOP (@DeleteBatchSize) [TaskHosting].[Job] FROM [TaskHosting].[Job] AS j WHERE DATEADD(Hour, 1, j.InitialInsertTimeUTC) < GETDATE()
        AND j.JobType<>7 --Exclude upload and download tasks
        AND NOT EXISTS
        (SELECT 1 FROM [TaskHosting].[MessageQueue] m WHERE m.jobId = j.jobId)
        SET @RowsAffected = @@ROWCOUNT
    END
END
GO
