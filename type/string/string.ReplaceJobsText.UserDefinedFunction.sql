CREATE OR ALTER PROCEDURE string.ReplaceJobText 
 @Find nvarchar(max) = N'\\SERVERA\Backups'
, @Replace nvarchar(max) = N'\\SERVERB\Backups'
, @DebugOnly bit = 1
AS
BEGIN

IF OBJECT_ID(N'tempdb..#excludeJobs', N'U') IS NOT NULL
BEGIN
    DROP TABLE #excludeJobs;
END
CREATE TABLE #excludeJobs
(
    JobName sysname NOT NULL
        PRIMARY KEY CLUSTERED
);

INSERT INTO #excludeJobs (JobName)
VALUES ('The Name of a job you want to skip');

IF OBJECT_ID(N'tempdb..#deets', N'U') IS NOT NULL
DROP TABLE #deets;

CREATE TABLE #deets 
(
    JobName sysname NOT NULL
    , StepName sysname NOT NULL
    , OldCommand nvarchar(max) NOT NULL
    , NewCommand nvarchar(max) NOT NULL
    , PRIMARY KEY (JobName, StepName)
);
DECLARE @JobName sysname;
DECLARE @StepName sysname;
DECLARE @StepID int;
DECLARE @Command nvarchar(max);
DECLARE @NewCommand nvarchar(max);

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE cur CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY
    FOR
    SELECT sj.name
        , sjs.step_name
        , sjs.step_id
        , sjs.command
    FROM dbo.sysjobsteps sjs
        INNER JOIN dbo.sysjobs sj ON sjs.job_id = sj.job_id
    WHERE sjs.command LIKE N'%' + @Find + N'%' ESCAPE N'|' COLLATE SQL_Latin1_General_CP1_CI_AS
        AND sj.enabled = 1
        AND NOT EXISTS (
            SELECT 1
            FROM #excludeJobs ej
            WHERE ej.JobName = sj.name
            )
    ORDER BY sj.name
        , sjs.step_name;

    OPEN cur;
    FETCH NEXT FROM cur INTO @JobName
        , @StepName
        , @StepID
        , @Command;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @NewCommand = REPLACE(@Command, @Find, @Replace) COLLATE SQL_Latin1_General_CP1_CI_AS;
        INSERT INTO #deets (JobName, StepName, OldCommand, NewCommand)
        SELECT JobName = @JobName
            , StepName = @StepName
            , PriorCommand = @Command
            , NewCommand = @NewCommand;

        IF @DebugOnly = 0
        BEGIN
            EXEC dbo.sp_update_jobstep @job_name = @JobName, @step_id = @StepID, @command = @NewCommand;
            PRINT N'Updated ' + @JobName;
        END
    
        FETCH NEXT FROM cur INTO @JobName
            , @StepName
            , @StepID
            , @Command;
    END
    CLOSE cur;
    DEALLOCATE cur;

    SELECT *
    FROM #deets;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT N'Transaction rolled back';
    END
    PRINT ERROR_MESSAGE();
    PRINT ERROR_LINE();
END CATCH

END