CREATE OR ALTER PROCEDURE #sp_job_list 
    @JobNamePart AS SYSNAME
,   @SetJobStatus SMALLINT
AS  
BEGIN

DECLARE @sql NVARCHAR(MAX)
DECLARE @sqlstatus_current SMALLINT
DECLARE @sqlstatus_post NVARCHAR(MAX)
DECLARE @sqls_sysadmin INT  
DECLARE @job_owner   sysname  
  
SET @sqlstatus_post = CASE @SetJobStatus 
                        WHEN -1 THEN ''
                        WHEN 0 THEN ', @Enabled = 0'
                        WHEN 1 THEN ', @Enabled = 1'
                        ELSE ''
                    END

SET @sqlstatus_current = CASE @SetJobStatus 
                        WHEN -1 THEN -1
                        WHEN 0 THEN 1
                        WHEN 1 THEN 0
                        ELSE -1
                    END                  

DROP TABLE IF EXISTS #xp_results  

  
CREATE TABLE #xp_results (  
     job_id                UNIQUEIDENTIFIER NOT NULL,  
     last_run_date         INT              NOT NULL,  
     last_run_time         INT              NOT NULL,  
     next_run_date         INT              NOT NULL,  
     next_run_time         INT              NOT NULL,  
     next_run_schedule_id  INT              NOT NULL,  
     requested_to_run      INT              NOT NULL,   
     request_source        INT              NOT NULL,  
     request_source_id     sysname          COLLATE database_default NULL,  
     running               INT              NOT NULL,   
     current_step          INT              NOT NULL,  
     current_retry_attempt INT              NOT NULL,  
     job_state             INT              NOT NULL)  
  
SELECT @sqls_sysadmin = ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0)  
SELECT @job_owner = SUSER_SNAME()  
  
INSERT INTO #xp_results  
    EXECUTE master.dbo.xp_sqlagent_enum_jobs @sqls_sysadmin, @job_owner  
  
DROP TABLE IF EXISTS #Jobs_All

SELECT   
  j.Name AS JobName  
, c.Name AS Category  
--, CASE j.enabled WHEN 1 THEN 'Yes' else 'No' END as Job_Enabled  
--, CASE s.enabled WHEN 1 THEN 'Yes' else 'No' END as Job_Scheduled  
, j.enabled as Job_Enabled  
, s.enabled AS Job_Scheduled
, j.Description   
, CASE s.freq_type   
     WHEN  1 THEN 'Once'  
     WHEN  4 THEN 'Daily'  
     WHEN  8 THEN 'Weekly'  
     WHEN 16 THEN 'Monthly'  
     WHEN 32 THEN 'Monthly relative'  
     WHEN 64 THEN 'When SQL Server Agent starts'   
     WHEN 128 THEN 'Start whenever the CPU(s) become idle' END as Occurs    
, CASE s.freq_type   
     WHEN  1 THEN 'O'  
     WHEN  4 THEN 'Every '   
        + convert(varchar,s.freq_interval)   
        + ' day(s)'  
     WHEN  8 THEN 'Every '   
        + convert(varchar,s.freq_recurrence_factor)   
        + ' weeks(s) on '   
        + CONVERT(VARCHAR, s.freq_interval)         
     WHEN 16 THEN 'Day ' + convert(varchar,s.freq_interval)   
        + ' of every '   
        + convert(varchar,s.freq_recurrence_factor)   
        + ' month(s)'   
     WHEN 32 THEN 'The '   
        + CASE s.freq_relative_interval   
            WHEN  1 THEN 'First'  
            WHEN  2 THEN 'Second'  
            WHEN  4 THEN 'Third'   
            WHEN  8 THEN 'Fourth'  
            WHEN 16 THEN 'Last' END   
        + CASE s.freq_interval   
            WHEN  1 THEN ' Sunday'  
            WHEN  2 THEN ' Monday'  
            WHEN  3 THEN ' Tuesday'  
            WHEN  4 THEN ' Wednesday'  
            WHEN  5 THEN ' Thursday'  
            WHEN  6 THEN ' Friday'  
            WHEN  7 THEN ' Saturday'  
            WHEN  8 THEN ' Day'  
            WHEN  9 THEN ' Weekday'  
            WHEN 10 THEN ' Weekend Day' END   
        + ' of every '   
        + convert(varchar,s.freq_recurrence_factor)   
        + ' month(s)' END AS Occurs_detail   
,       CASE [freq_subday_type]
        WHEN 1 THEN 'Occurs once at ' 
                    + STUFF(
                 STUFF(RIGHT('000000' + CAST([active_start_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
        WHEN 2 THEN 'Occurs every ' 
                    + CAST([freq_subday_interval] AS VARCHAR(3)) + ' Second(s) between ' 
                    + STUFF(
                   STUFF(RIGHT('000000' + CAST([active_start_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
                    + ' & ' 
                    + STUFF(
                    STUFF(RIGHT('000000' + CAST([active_end_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
        WHEN 4 THEN 'Occurs every ' 
                    + CAST([freq_subday_interval] AS VARCHAR(3)) + ' Minute(s) between ' 
                    + STUFF(
                   STUFF(RIGHT('000000' + CAST([active_start_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
                    + ' & ' 
                    + STUFF(
                    STUFF(RIGHT('000000' + CAST([active_end_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
        WHEN 8 THEN 'Occurs every ' 
                    + CAST([freq_subday_interval] AS VARCHAR(3)) + ' Hour(s) between ' 
                    + STUFF(
                    STUFF(RIGHT('000000' + CAST([active_start_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
                    + ' & ' 
                    + STUFF(
                    STUFF(RIGHT('000000' + CAST([active_end_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
      END [Frequency]
    , STUFF(
            STUFF(CAST([active_start_date] AS VARCHAR(8)), 5, 0, '-')
                , 8, 0, '-') AS [ScheduleUsageStartDate]
    , STUFF(
            STUFF(CAST([active_end_date] AS VARCHAR(8)), 5, 0, '-')
                , 8, 0, '-') AS [ScheduleUsageEndDate]

, CONVERT(VARCHAR, xp.next_run_date) + ' '   
    + REPLICATE('0', ROUND((((1.00 * DATEPART(HOUR, xp.next_run_time) / 10) - 0.5)), 0))
    + CONVERT(VARCHAR, xp.next_run_time) AS Next_Run_Date  
    
     , s.[date_created] AS [ScheduleCreatedOn]
    , s.[date_modified] AS [ScheduleLastModifiedOn]
INTO #Jobs_All
FROM  msdb.dbo.sysjobs j (NOLOCK)  
INNER JOIN msdb.dbo.sysjobschedules js (NOLOCK) ON j.job_id = js.job_id  
INNER JOIN msdb.dbo.sysschedules s (NOLOCK) ON js.schedule_id = s.schedule_id  
INNER JOIN msdb.dbo.syscategories c (NOLOCK) ON j.category_id = c.category_id  
INNER JOIN #xp_results xp (NOLOCK) ON j.job_id = xp.job_id  
WHERE (j.Name LIKE + '%' +  @JobNamePart + '%')  
ORDER BY j.name

SELECT * FROM #Jobs_All

DECLARE @job_tv AS TABLE(query NVARCHAR(MAX))
DECLARE @c CURSOR

SET @c = CURSOR LOCAL FAST_FORWARD
FOR
WITH job_cte AS (
    SELECT JobName 
    FROM #Jobs_All
    ---WHERE Job_Enabled = @sqlstatus_current
)
SELECT 'msdb.dbo.sp_update_job @job_name=''' + job_cte.JobName + '''' + @sqlstatus_post + ', @category_name=''Data Vault Load'''
FROM job_cte
ORDER BY 1

OPEN @c
FETCH @c INTO @sql

IF(@@FETCH_STATUS = 0)
BEGIN
    RAISERROR('UPDATING THE FOLLOWING JOBS:', 0, 1) WITH NOWAIT
END

WHILE @@FETCH_STATUS = 0
    BEGIN
     --   SELECT @sql

	    RAISERROR(@sql, 0, 1) WITH NOWAIT
        EXEC(@sql)
	    FETCH @c INTO @sql;
    END

 IF(@SetJobStatus <> - 1)
 BEGIN
     EXEC #sp_job_list @JobNamePart = @JobNamePart, @SetJobStatus = -1
 END
END 
GO


EXEC #sp_job_list
        @JobNamePart = ''
    ,   @SetJobStatus = 0
GO

DROP PROCEDURE #sp_job_list 
GO

