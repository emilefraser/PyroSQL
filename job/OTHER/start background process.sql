/*
1. Create a 'StartBackgroundProcess' stored procedure that starts a job named 'BackgroundProcess'.
2. Create a test stored procedure to be called by the 'BackgroundProcess' job.
3. Create a 'BackgroundProcess' job that continuously loops, checking for jobs completed and then executing the 'TestSP' stored procedure.
4. Configure the 'StartBackgroundProcess' stored procedure to be called whenever SQL Server starts.
*/

-- 1. Create the 'StartBackgroundProcess' stored procedure that starts a job named 'BackgroundProcess'.

USE master
GO

IF EXISTS (SELECT * FROM master.dbo.sysobjects o WHERE o.xtype IN ('P') AND o.id = object_id('master.dbo.StartBackgroundProcess'))
DROP PROC StartBackgroundProcess
GO

CREATE PROCEDURE dbo.StartBackgroundProcess
AS
BEGIN
    EXEC msdb.dbo.sp_start_job 'BackgroundProcess'
END
GO


-- 2. Create a test stored procedure to be called by the 'BackgroundProcess' job.

USE Tempdb
GO

CREATE PROCEDURE [dbo].[TestSP]  
AS 
BEGIN
    SELECT 'Running Test', GETDATE()
END
GO


-- 3. Create the 'BackgroundProcess' job that continuously loops, checking for jobs completed and then executing a specified stored procedure.
-- ACTION REQUIRED: Copy/Paste the commented SQL below (up until Step 3) into a new job named 'BackgroundProcess' as a SQL Step and Save. No need to configure a schedule.
-- ACTION REQUIRED: Remove the beginning/ending comment tags from the job!
/* 
USE master
GO

DECLARE @whilecounter AS INT
DECLARE @i AS INT
DECLARE @ScriptToRun varchar(250)
DECLARE @LastRun datetime   
DECLARE @StatementToRun VARCHAR(5000)

IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects o WHERE o.xtype IN ('U') AND o.id = object_id('Tempdb.dbo.BackgroundProcess'))
DROP TABLE Tempdb.dbo.BackgroundProcess

CREATE TABLE Tempdb.dbo.BackgroundProcess
(
    CommandRun VARCHAR(100),
    TimeExecuted DATETIME
)

DECLARE @TimeMarker DATETIME

DECLARE @cmdQueue TABLE
(
    cmd VARCHAR(5000) NOT NULL
)

DECLARE @Runcommand TABLE
(
    cmd VARCHAR(5000) NOT NULL
)

SET @TimeMarker = (SELECT start_execution_date FROM msdb.dbo.sysjobactivity sja INNER JOIN msdb.dbo.sysjobs sj on sja.job_id = sj.job_id WHERE sj.enabled = 1 AND start_execution_date IS NOT NULL AND name = 'BackgroundProcess')

WHILE 1=1
BEGIN
        INSERT @cmdQueue
            SELECT 'EXEC ' + 'TempDB.dbo.TestSP' + ' ' + name + ', ' + @@SERVERNAME FROM msdb.dbo.sysjobactivity sja INNER JOIN msdb.dbo.sysjobs sj on sja.job_id = sj.job_id WHERE sj.enabled = 1 AND start_execution_date IS NOT NULL AND stop_execution_date >= @TimeMarker
        SET @whilecounter = (SELECT COUNT(*) FROM @cmdQueue)
        SET @i = 1
        WHILE @i <= @whilecounter
        BEGIN
            DELETE TOP(1) FROM @cmdQueue
            OUTPUT DELETED.cmd INTO @RunCommand
            INSERT Tempdb.dbo.BackgroundProcess
                SELECT cmd, GETDATE() FROM @RunCommand
            SET @StatementToRun = (SELECT TOP(1) cmd FROM @RunCommand)                      
            EXEC (@StatementToRun)
            DELETE FROM @RunCommand
            SET @i = @i + 1
        END
SET @TimeMarker = GETDATE()
WAITFOR DELAY '000:0:30.000' --Configure this to be the proper frequency for your situation. Ensure it is runs often enough to catch all executions of other jobs.
END
*/

-- 4. Configure the 'StartBackgroundProcess' stored procedure to be called whenever SQL Server starts.

USE master
GO

EXEC sp_procoption 'master.dbo.StartBackgroundProcess', 'startup', 'true' 
GO