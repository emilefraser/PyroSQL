/**********************************************************************/
    -- EXECUTES A JOB WITH A PRE OR POSRUN CHORE
/**********************************************************************/
DECLARE 
    @JobID                  UNIQUEIDENTIFIER = NULL
,   @JobName                SYSNAME = 'VaultLoad_HUB_SalesOrder'

DECLARE     
    @WhichToUse             NVARCHAR(MAX)
,   @RC                     INT

DECLARE 
    @sql_statement          NVARCHAR(MAX)
,   @sql_messsage           NVARCHAR(MAX)
,   @sql_parameters         NVARCHAR(MAX)
,   @sql_isdebug            BIT = 1
,   @sql_clrf               NCHAR(2) = CHAR(13) + CHAR(10)
,   @sql_eos                NCHAR(4) = CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
,   @sql_tab                NCHAR(1) = CHAR(9)

DECLARE 
    @sql_prerun_statement   NVARCHAR(MAX)
,   @sql_postrun_statement  NVARCHAR(MAX)

SET @sql_prerun_statement = 'DROP TABLE IF EXISTS [ODS_D365].[DV].[DMOD_vw_SalesOrder_20200309]'
SET @sql_postrun_statement = 'SELECT * INTO [ODS_D365].[DV].[DMOD_vw_SalesOrder_20200309] FROM [ODS_D365].[DV].[vw_DMOD_SalesOrder]'

-- Determine if we are using Job ID or JOB name 
IF(@JobID IS NOT NULL AND @JobName IS NULL)
BEGIN
    SET @WhichToUse = '@job_id'
END
IF(@JobID IS NULL AND @JobName IS NOT NULL)
BEGIN
    SET @WhichToUse = '@job_name'
END
IF(@JobID IS NOT NULL AND @JobName IS NOT NULL)
BEGIN
    SET @WhichToUse = '@job_name'
END
IF(@JobID IS NULL AND @JobName IS NULL)
BEGIN
    GOTO EXITGRACEFULLY
END

-- PERFORMS THE PRERUN STATEMENTS 
IF (@sql_prerun_statement IS NOT NULL)
BEGIN
    IF(@sql_isdebug = 1)
        RAISERROR(@sql_prerun_statement, 0, 1) WITH NOWAIT

    --EXEC sp_executesql @stmt = @sql_prerun_statement
END


-- PUT TOGETHER THE STATEMENT 
SET @sql_statement = (
    N'msdb.dbo.sp_start_job ' + @sql_clrf +
    @sql_tab + @WhichToUse + ' = ' + ISNULL(CONVERT(NVARCHAR(MAX), @JobID), @JobName)
)

SET @sql_parameters = '@sql_clrf NCHAR(2), @sql_tab NCHAR(1), @WhichToUse NVARCHAR(MAX), @job_id UNIQUEIDENTIFIER, @job_name SYSNAME'

-- DEBUG PRINT 
IF(@sql_isdebug = 1)
BEGIN
    RAISERROR(@WhichToUse, 0, 1) WITH NOWAIT
    RAISERROR(@sql_parameters, 0, 1) WITH NOWAIT
END    

-- Executes the job
EXEC sp_executesql @stmt = @sql_statement, @params = @sql_parameters
                            ,   @sql_clrf = @sql_clrf
                            ,   @sql_tab = @sql_tab
                            ,   @WhichToUse = @WhichToUse
                            ,   @job_id = @JobID
                            ,   @job_name = @JobName

/**********************************************************************/
    -- CHECKS IF THIS JOB IS STILL RUNNING EVERY 10 SECS, IF DONE, PostRUN Chorse
/**********************************************************************/
DECLARE @DelayLength char(8)= '00:00:10'  -- 10 seconds
DECLARE  @IsRunning INT = 1

WHILE (ISNULL(@IsRunning, 0) = 1)
BEGIN
    -- CHECKS OF THE JOB IS STILL RUNNING
    SET @IsRunning = (
        SELECT         
	        1
        FROM        
	         msdb.dbo.sysjobactivity AS ja
        LEFT JOIN
	        msdb.dbo.sysjobhistory AS jh
	        ON ja.job_history_id = jh.instance_id
        INNER JOIN
	        msdb.dbo.sysjobs AS j
	        ON ja.job_id = j.job_id
        INNER JOIN
	        msdb.dbo.sysjobsteps AS js
	        ON ja.job_id = js.job_id
	        AND ISNULL(ja.last_executed_step_id, 0) + 1 = js.step_id
        WHERE
            ja.session_id = (
                                SELECT TOP 1 
						            session_id
					            FROM 
						            msdb.dbo.syssessions
					            ORDER BY 
						            agent_start_date DESC
            )
            AND start_execution_date IS NOT NULL
            AND stop_execution_date IS NULL
            AND (
                j.job_id = @JobID
            OR  j.name = @JobName
            )
    )

    IF(ISNULL(@IsRunning, 0) = 1)
    BEGIN
        SET @sql_messsage = 'The Job {' + ISNULL(CONVERT(NVARCHAR, @JobId), @JobName) + '} is still running.... (' + CONVERT(VARCHAR(22), GETDATE(), 121) + ') waiting ' + @DelayLength
        IF(@sql_isdebug = 1)
            RAISERROR(@sql_messsage, 0, 1) WITH NOWAIT
    END 
END

-- PERFORMS THE POSTRUN STATEMENTS 
IF (@sql_postrun_statement IS NOT NULL)
BEGIN
    IF(@sql_isdebug = 1)
        RAISERROR(@sql_postrun_statement, 0, 1) WITH NOWAIT

     --EXEC sp_executesql @stmt = @sql_postrun_statement
END

EXITGRACEFULLY:
    SET @sql_messsage = 'Need to pass Job ID or Job Name'
    RAISERROR(@sql_messsage, 0, 1) WITH NOWAIT