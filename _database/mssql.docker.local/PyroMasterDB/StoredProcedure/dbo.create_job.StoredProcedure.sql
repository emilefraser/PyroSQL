SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[create_job]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[create_job] AS' 
END
GO
	  

/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2018-01-25 BvdB creates job in msdb from betl job meta data (dbo.Job_ext) 
select * from dbo.job_ext
exec dbo.create_job 10 , 1 
*/ 
ALTER   PROCEDURE [dbo].[create_job] @job_id as int, @drop as bit = 1 as 
begin 
	set nocount on 
	declare 
--		@job_id as int = 10 
		@step_id as int
		,@transfer_id as int = 0 
	--	,@drop as bit = 1 
		,@sql as varchar(max) = ''
		,@sql_header as varchar(max) = ''
		,@step_sql as varchar(max) = ''
		,@job_sql as varchar(max) = ''
		,@ReturnCode INT=0
		,@jobId BINARY(16)
		,@prefix as varchar(100) = 'dev'
		,@schedule_enabled as bit = 0 
		--,@drop as bit = 1 
		, @job_params as ParamTable
		, @step_params as ParamTable
set @sql_header = '
declare 
	@ReturnCode INT=0
	,@jobId BINARY(16)
	,@schedule_enabled as bit = 0 
	
'
select @sql = @sql_header + '
declare @drop as bit =<drop>
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N''<category_name>'' AND category_class=1)
BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N''<category_name>''
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END
select @jobId= job_id from msdb.dbo.sysjobs where name=''<job_name>''
if @drop=1 and @jobId is not null 
begin
	exec msdb.dbo.sp_delete_job @jobId
	set @jobId = null 
end
if @jobId is null 
begin 
	BEGIN TRANSACTION
	EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=''<job_name>'', 
			@enabled=<job_enabled>, 
			@notify_level_eventlog=0, 
			@notify_level_email=0, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=''<job_description>'',
			@category_name=''<category_name>'', 
			@job_id = @jobId OUTPUT
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N''<schedule_name>'', 
			@enabled=<schedule_enabled>, 
			@freq_type=<freq_type>, 
			@freq_interval=<freq_interval>, 
			@freq_subday_type=<freq_subday_type>, 
			@freq_subday_interval=<freq_subday_interval>, 
			@freq_relative_interval=<freq_relative_interval>, 
			@freq_recurrence_factor=<freq_recurrence_factor>, 
			@active_start_date=<active_start_date>, 
			@active_end_date=<active_end_date>, 
			@active_start_time=<active_start_time>, 
			@active_end_time=<active_end_time>
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
'
;
with params as ( 
	select [name], [value]
	fROM ( 
		SELECT convert(varchar(255), [job_id])  job_id 
			  ,convert(varchar(255), [job_name]) [job_name]
			  , convert(varchar(255), [job_description]) [job_description]
			  ,convert(varchar(255), [job_enabled]) [job_enabled]
			  ,convert(varchar(255), [category_name]) [category_name]
			  ,convert(varchar(255), [schedule_name]) [schedule_name]
			  ,convert(varchar(255), [schedule_enabled]) [schedule_enabled]
			  ,convert(varchar(255),[freq_type]) [freq_type]
			  ,convert(varchar(255),[freq_interval]) [freq_interval]
			  ,convert(varchar(255),[freq_subday_type]) [freq_subday_type]
			  ,convert(varchar(255),[freq_subday_interval]) [freq_subday_interval]
			  ,convert(varchar(255),[freq_relative_interval]) [freq_relative_interval]
			  ,convert(varchar(255),[freq_recurrence_factor]) [freq_recurrence_factor]
			  ,convert(varchar(255),[active_start_date]) [active_start_date]
			  ,convert(varchar(255),[active_end_date]) [active_end_date]
			  ,convert(varchar(255),[active_start_time]) [active_start_time]
			  ,convert(varchar(255),[active_end_time]) [active_end_time]
		FROM dbo.[Job_ext]
    	where job_id = @job_id 
		) p 
		unpivot( [value] for [name] in ( 
			  job_id 
			  ,[job_name]
			  ,[job_description]
			  ,[job_enabled]
			  ,[category_name]
			  ,[schedule_name]
			  ,[schedule_enabled]
			  ,[freq_type]
			  ,[freq_interval]
			  ,[freq_subday_type]
			  ,[freq_subday_interval]
			  ,[freq_relative_interval]
			  ,[freq_recurrence_factor]
			  ,[active_start_date]
			  ,[active_end_date]
			  ,[active_start_time]
			  ,[active_end_time]
			) 
			) as unpvt 
		) 
		insert into @job_params
		select * from  params 
		insert into @job_params values ('drop', @drop) 
		EXEC util.apply_params @sql output, @job_params
	set @sql += '
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		
	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)''
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	COMMIT TRANSACTION
	goto EndSave
END
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave: print ''job created'' 
'
	exec [dbo].[exec_sql] @transfer_id, @sql
	------------------------------
	--- STEPS 
	------------------------------
	set @sql = @sql_header+ '
BEGIN
	select @jobId= job_id from msdb.dbo.sysjobs where name=''<job_name>''
	BEGIN TRANSACTION
'
		
	DECLARE c CURSOR FOR   
	SELECT step_id 
	FROM dbo.Job_step_ext
	WHERE job_id = @job_id 
	order by step_id asc
	OPEN c
	FETCH NEXT FROM c INTO @step_id 
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
--		print 'step_id' + convert(varchar(255), @step_id ) 
		delete from @step_params
		;
		with params as ( 
			select [name], [value]
			fROM ( 
				SELECT
						--convert(varchar(255), [job_id])  job_id 
						-- ,convert(varchar(255), [job_name]) [job_name]
						-- , convert(varchar(255), [job_description]) [job_description]
						-- ,convert(varchar(255), [job_enabled]) [job_enabled]
						-- ,convert(varchar(255), [category_name]) [category_name]
						-- ,convert(varchar(255), [schedule_name]) [schedule_name]
						-- ,convert(varchar(255), [schedule_enabled]) [schedule_enabled]
						convert(varchar(255), [step_id]) [step_id]
						,convert(varchar(255), [step_name]) [step_name]
						,convert(varchar(255), [subsystem]) [subsystem]
						,convert(varchar(255), [command]) [command]
						,convert(varchar(255), [on_success_action]) [on_success_action]
						,convert(varchar(255), [on_success_step_id]) [on_success_step_id]
						,convert(varchar(255), [on_fail_action]) [on_fail_action]
						,convert(varchar(255), [on_fail_step_id]) [on_fail_step_id]
						,convert(varchar(255), [database_name]) [database_name]
				FROM dbo.[Job_step_ext]
    			where job_id = @job_id 
				and step_id = @step_id 
				) p 
				unpivot( [value] for [name] in ( 
						--job_id 
						--,[job_name]
						--,[job_description]
						--,[job_enabled]
						--,[category_name]
						--,[schedule_name]
						--,[schedule_enabled]
						[step_id]
						,[step_name]
						,[subsystem]
						,[command]
						,[on_success_action]
						,[on_success_step_id]
						,[on_fail_action]
						,[on_fail_step_id]
						,[database_name]
					) 
			) as unpvt 
		) 
		insert into @step_params
		select * from params 
		--select * from  @step_params
		set @step_sql = '
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''<step_name>'', 
		@step_id=<step_id>, 
		@cmdexec_success_code=0, 
		@on_success_action=<on_success_action>, 
		@on_success_step_id=<on_success_action>, 
		@on_fail_action=<on_fail_action>, 
		@on_fail_step_id=<on_fail_step_id>, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, 
		@subsystem=N''<subsystem>'', 
		@command=N''<command>'', 
		@database_name=N''<database_name>'', 
		@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
'
			
		--update @step_params set param_value = replace( convert(varchar(255), param_value) , '''', '"') 
		--where param_name = 'command'
		EXEC util.apply_params @step_sql output, @step_params, 0
		set @sql += @step_sql 
		--print @step_sql 
			
		FETCH NEXT FROM c INTO @step_id 
	end
	CLOSE c;  
	DEALLOCATE c;  
	set @sql += '
	COMMIT TRANSACTION
	goto EndSave
END
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave: print ''job created''
'
	EXEC util.apply_params @sql output, @job_params, 0 
	--print @sql 
	exec [dbo].[exec_sql] @transfer_id, @sql
end












GO
