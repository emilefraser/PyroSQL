SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_sqlagent_refresh_job
  @job_id      UNIQUEIDENTIFIER = NULL,
  @server_name sysname          = NULL -- This parameter allows a TSX to use this SP when updating a job
AS
BEGIN
  DECLARE @server_id INT

  SET NOCOUNT ON

  IF (@server_name IS NULL) OR (UPPER(@server_name collate SQL_Latin1_General_CP1_CS_AS) = '(LOCAL)')
    SELECT @server_name = CONVERT(sysname, SERVERPROPERTY('ServerName'))

  SELECT @server_name = UPPER(@server_name)

  SELECT @server_id = server_id
  FROM msdb.dbo.systargetservers_view
  WHERE (UPPER(server_name) = ISNULL(@server_name, UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))))

  SELECT @server_id = ISNULL(@server_id, 0)

  SELECT sjv.job_id,
         sjv.name COLLATE SQL_Latin1_General_CP1_CI_AS,
         sjv.enabled,
         sjv.start_step_id,
         owner = dbo.SQLAGENT_SUSER_SNAME(sjv.owner_sid),
         sjv.notify_level_eventlog,
         sjv.notify_level_email,
         sjv.notify_level_netsend,
         sjv.notify_level_page,
         sjv.notify_email_operator_id,
         sjv.notify_netsend_operator_id,
         sjv.notify_page_operator_id,
         sjv.delete_level,
         has_step = (SELECT COUNT(*)
                     FROM msdb.dbo.sysjobsteps sjst
                     WHERE (sjst.job_id = sjv.job_id)),
         sjv.version_number,
         last_run_date = ISNULL(sjs.last_run_date, 0),
         last_run_time = ISNULL(sjs.last_run_time, 0),
         sjv.originating_server,
         sjv.description COLLATE SQL_Latin1_General_CP1_CI_AS,
         agent_account = CASE sjv.owner_sid
              WHEN 0xFFFFFFFF THEN 1
              ELSE                 0
         END,
		 0 AS is_system
  FROM msdb.dbo.sysjobservers sjs,
       msdb.dbo.sysjobs_view  sjv
  WHERE ((@job_id IS NULL) OR (@job_id = sjv.job_id))
    AND (sjv.job_id = sjs.job_id)
    AND (sjs.server_id = @server_id)
  UNION
  SELECT
	job_id,
	name COLLATE SQL_Latin1_General_CP1_CI_AS,
	enabled,
	start_step_id,
	dbo.SQLAGENT_SUSER_SNAME(0x01) AS [owner],
	notify_level_eventlog,
	0 AS notify_level_email,          -- notify_level_email
	0 AS notify_level_netsend,        -- notify_level_netsend
	0 AS notify_level_page,           -- notify_level_page
	0 AS notify_email_operator_id,    -- notify_email_operator_id
	0 AS notify_netsend_operator_id,  -- notify_netsend_operator_id
	0 AS notify_page_operator_id,     -- notify_page_operator_id
	delete_level,
	has_step = (SELECT COUNT(*)
                     FROM sys.fn_sqlagent_jobsteps(j.job_id, NULL) js
                     ),
	0 AS version_number,				-- version_number
	0 AS last_run_date,
	0 AS last_run_time,
	@server_name AS originating_server,
	description COLLATE SQL_Latin1_General_CP1_CI_AS,
	0 AS agent_account,
	1 AS is_system
  FROM sys.fn_sqlagent_jobs(NULL) j
  WHERE ((@job_id IS NULL) OR (@job_id = j.job_id))

  RETURN(@@error) -- 0 means success
END

GO
