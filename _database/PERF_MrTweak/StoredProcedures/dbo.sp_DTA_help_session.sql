SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

create procedure [dbo].[sp_DTA_help_session] 
	@SessionID int = 0,
	@IncludeTuningOptions int = 0
as 
begin
	declare @tuning_owner nvarchar(256)
	declare @retval  int
	declare @InteractiveStatus tinyint
	declare @delta int

	declare @cursessionID int
	declare @dbname nvarchar(128)
	declare @dbid int
	declare @retcode int
	declare @sql nvarchar(256)
	
	set nocount on

	-- List all Sessions mode
	if @SessionID = 0
	begin
		-- If sysadmin role then rowset has all the rows in the table
		-- Return everything
		if (isnull(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1)
		begin
		
			if (@IncludeTuningOptions = 0) 
			begin
				select	I.SessionID, I.SessionName, I.InteractiveStatus,
						I.CreationTime, I.ScheduledStartTime, O.StopTime,I.GlobalSessionID
						from msdb.dbo.DTA_input I left outer join msdb.dbo.DTA_output  O
						on I.SessionID = O.SessionID	
				order by
						I.SessionID	desc					
			end
			
			else if (@IncludeTuningOptions = 1)
			begin
				select	I.SessionID, I.SessionName, I.InteractiveStatus,
						I.CreationTime, I.ScheduledStartTime, O.StopTime,I.TuningOptions,I.GlobalSessionID
						from msdb.dbo.DTA_input  I left outer join msdb.dbo.DTA_output as O
						on I.SessionID = O.SessionID
				order by
						I.SessionID	desc
			end									
	
		end
		
		else 
		begin
			-- Temporary table to store sessionid and databases passed in by user
			create table #allDistinctDbIds (DatabaseID int)
			-- Init variables			
			set @dbid = 0
			set @retcode = 1
			-- Get all database names passed in by user (IsDatabaseSelectedToTune =1)
			declare db_cursor cursor for
			select distinct(DatabaseName) from DTA_reports_database
			where  IsDatabaseSelectedToTune  = 1
			-- Open cursor
			open db_cursor
			-- Fetch first session id and db name
			fetch next from db_cursor
			into @dbname
			
			-- loop and get all the databases selected to tune
			while @@fetch_status = 0
			-- Loop
			begin
				-- set @retcode = 1 in the beginning to indicate success
				set @retcode = 1
				-- Get database id
				select  @dbid = DB_ID(@dbname)
				-- In Yukon this masks the error messages.If not owner dont return
				-- error message in SP
				set @sql = N'begin try
					dbcc autopilot(5,@dbid) WITH NO_INFOMSGS 
				end try
				begin catch
					set @dbid = 0
					set @retcode = 0
				end catch'
				execute sp_executesql @sql
					, N'@dbid int output, @retcode int OUTPUT' 
					, @dbid output 
					, @retcode output
		
				-- dbid is 0 if user doesnt have permission to do dbcc call
				insert into #allDistinctDbIds(DatabaseID) values
								(@dbid)
				-- fetch next								
				fetch from db_cursor into @dbname		
			-- end the cursor loop				
			end		
			-- clean up cursor
			close db_cursor
			deallocate db_cursor


			select SessionID 
			into #allValidSessionIds
			from DTA_input as I
			where
				((select count(*) from
				#allDistinctDbIds ,DTA_reports_database as D
				where #allDistinctDbIds.DatabaseID = DB_ID(D.DatabaseName)
				and I.SessionID = D.SessionID
				group by D.SessionID ) = 
				(select count(*) from DTA_reports_database as D
				where I.SessionID = D.SessionID
				and D.IsDatabaseSelectedToTune = 1
				group by D.SessionID )
				) 
			group by I.SessionID
			

			-- Return only sessions with matching user name
			-- If count of rows with DatabaseID = 0 is > 0 then permission denied
			if ( @IncludeTuningOptions = 0 )
			begin
				select	I.SessionID , I.SessionName, I.InteractiveStatus,
						I.CreationTime, I.ScheduledStartTime, O.StopTime,I.GlobalSessionID
						from msdb.dbo.DTA_input I left outer join msdb.dbo.DTA_output  O 
						on  I.SessionID = O.SessionID
						inner  join #allValidSessionIds S
						on	I.SessionID = S.SessionID
								
						
				order by
						I.SessionID	desc					
			end
			
			else if (@IncludeTuningOptions = 1)
			begin
				select	I.SessionID , I.SessionName, I.InteractiveStatus,
						I.CreationTime, I.ScheduledStartTime, O.StopTime,I.TuningOptions,I.GlobalSessionID
						from msdb.dbo.DTA_input I left outer join msdb.dbo.DTA_output O 
						on  I.SessionID = O.SessionID
						inner  join #allValidSessionIds S
						on	I.SessionID = S.SessionID

						
				order by
						I.SessionID	desc					
										
			end
			drop table #allDistinctDbIds
			drop table #allValidSessionIds
		end
	end

	else
	begin
		exec @retval =  sp_DTA_check_permission @SessionID
		if @retval = 1
		begin
			raiserror(31002,-1,-1)
			return(1)
		end	
	
		if ( @IncludeTuningOptions = 0) 
		begin
			select	I.SessionID, I.SessionName, I.InteractiveStatus,
					I.CreationTime, I.ScheduledStartTime, O.StopTime,I.GlobalSessionID
			from msdb.dbo.DTA_input I left outer join msdb.dbo.DTA_output O
			on  I.SessionID = O.SessionID
			where I.SessionID = @SessionID	
		end
		else if (@IncludeTuningOptions = 1)
		begin
			select	I.SessionID, I.SessionName, I.InteractiveStatus,
					I.CreationTime, I.ScheduledStartTime, O.StopTime,I.TuningOptions,I.GlobalSessionID
			from msdb.dbo.DTA_input I left outer join msdb.dbo.DTA_output O
			on  I.SessionID = O.SessionID
			where	I.SessionID = @SessionID				
		end
	
		-- Second rowset returned for DTA to process progress information
		select	ProgressEventID,TuningStage,WorkloadConsumption,EstImprovement,
				ProgressEventTime ,ConsumingWorkLoadMessage,PerformingAnalysisMessage,GeneratingReportsMessage
		from	msdb.dbo.DTA_progress 
		where	SessionID=@SessionID
		order by ProgressEventID
				

		-- Set interactive status to 6 if a time of 5 mins has elapsed
		-- Next time help session is called DTA will exit
		
		select	 @InteractiveStatus=InteractiveStatus
		from msdb.dbo.DTA_input
		where SessionID = @SessionID	

		if (@InteractiveStatus IS NOT NULL and( @InteractiveStatus <> 4 and  @InteractiveStatus <> 6)) 
		begin
			select @delta=DATEDIFF(minute ,ProgressEventTime,getdate())
			from msdb.dbo.DTA_progress 
			where  SessionID =@SessionID	
			order by TuningStage ASC
			
			if(@delta > 30)
			begin
				update [MrTweak].[dbo].[DTA_input] set InteractiveStatus = 6
				where SessionID = @SessionID
			end
		end

		
	end
end								

GO
