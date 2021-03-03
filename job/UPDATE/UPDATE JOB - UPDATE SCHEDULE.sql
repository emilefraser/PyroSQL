CREATE OR ALTER PROCEDURE #sp_job_list (
    @JobNamePart AS SYSNAME = ''
   /* @enabled                  TINYINT         = NULL,
    @freq_type                INT             = NULL,
    @freq_interval            INT             = NULL,
    @freq_subday_type         INT             = NULL,
    @freq_subday_interval     INT             = NULL,
    @freq_relative_interval   INT             = NULL,
    @freq_recurrence_factor   INT             = NULL,
    @active_start_date        INT             = NULL,
    @active_end_date          INT             = NULL,
    @active_start_time        INT             = NULL,
    @active_end_time          INT             = NULL,
    @owner_login_name         sysname         = NULL,
    @automatic_post           BIT             = 1     */  
                                                        
)
AS  
BEGIN

DECLARE @sql NVARCHAR(MAX)
DECLARE @sqlstatus_current SMALLINT
DECLARE @sqlstatus_post NVARCHAR(MAX)
DECLARE @sqls_sysadmin INT  
DECLARE @job_owner   sysname  
  
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
   ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS rn 
,  j.job_id AS JobID
,  j.Name AS JobName  
, c.Name AS Category  
--, CASE j.enabled WHEN 1 THEN 'Yes' else 'No' END as Job_Enabled  
--, CASE s.enabled WHEN 1 THEN 'Yes' else 'No' END as Job_Scheduled  
, j.enabled as Job_Enabled  
, s.enabled AS Job_Scheduled
, j.Description   
, js.schedule_id 
, s.name AS schedule_name
, s.freq_type
, s.freq_interval
, s.freq_subday_type
, s.freq_subday_interval
, s.freq_relative_interval
, s.freq_recurrence_factor
, s.active_start_date
, s.active_start_time
, s.active_end_date
, s.active_end_time
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
                    + 
                    
              SELECT [active_start_time]  ,
                    STUFF(
                 STUFF(RIGHT('000000' + CAST([active_start_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
      FROM msdb.dbo.sysschedules s 
      
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

--SELECT * FROM #Jobs_All

DECLARE @c AS CURSOR
DECLARE @rn INT, @schedule_id INT, @schedule_name SYSNAME
DECLARE     @freq_type                INT             = NULL,
            @freq_interval            INT             = NULL,
            @freq_subday_type         INT             = NULL,
            @freq_subday_interval     INT             = NULL,
            @freq_relative_interval   INT             = NULL,
            @freq_recurrence_factor   INT             = NULL,
            @active_start_date        INT             = NULL,
            @active_end_date          INT             = NULL,
            @active_start_time        INT             = NULL,
            @active_end_time          INT             = NULL,
            @owner_login_name         sysname         = NULL


DECLARE @lag_seconds INT = 30
DECLARE @temp_time TIME

SET @freq_type = 4 --daily
SET @freq_interval = 1
SET @freq_subday_type = 8
SET @freq_subday_interval = 1
SET @active_start_date = 20200217
DECLARE @active_start_time_str VARCHAR(6) = '000000'
SET @active_end_date = 99991231
DECLARE @activeend_time_str VARCHAR(6)  = '235959'

SET @c = CURSOR
FOR
SELECT rn, schedule_id, schedule_name
FROM #Jobs_All
ORDER BY rn

OPEN @c
FETCH NEXT FROM @c INTO @rn, @schedule_id, @schedule_name

WHILE (@@FETCH_STATUS = 0)
BEGIN
    
   
    SET @temp_time = (SELECT (CONVERT(VARCHAR, DATEADD(SECOND, (@rn * @lag_seconds), CONVERT(time, SUBSTRING(@active_start_time_str, 1, 2) + ':' + SUBSTRING(@active_start_time_str, 3, 2) + ':' + SUBSTRING(@active_start_time_str, 5, 2))))))
    SET @active_start_time   = (SELECT CONVERT(INT, CONVERT(VARCHAR(2), DATEPART(HOUR, @temp_time)) + CONVERT(VARCHAR(2), DATEPART(MINUTE, @temp_time)) + IIF(CONVERT(VARCHAR(2), DATEPART(SECOND, @temp_time))='0','00', CONVERT(VARCHAR(2), DATEPART(SECOND, @temp_time)))))

    select @rn, @schedule_id, @schedule_name, @temp_time, @active_start_time

   

    EXEC msdb.[dbo].[sp_update_schedule]
          @schedule_id               = @schedule_id
        --  ,@name                     = @schedule_name          
          ,@enabled                  = 0
          ,@freq_type                = @freq_type
          ,@freq_interval            = @freq_interval
          ,@freq_subday_type         = @freq_subday_type
          ,@freq_subday_interval     = @freq_subday_interval
       
          ,@active_start_date        = @active_start_date
          ,@active_end_date          = @active_end_date
          ,@active_start_time        = @active_start_time
          ,@active_end_time          = @active_end_time
         -- @owner_login_name         sysname         = NULL,
          ,@automatic_post           = 1       
          
         

	FETCH NEXT FROM @c INTO @rn, @schedule_id, @schedule_name
    --------   @freq_recurrence_factor   INT             = NULL,
END

END
GO


EXEC #sp_job_list
        @JobNamePart = 'VaultLoad'
GO


DROP PROCEDURE #sp_job_list 
GO
