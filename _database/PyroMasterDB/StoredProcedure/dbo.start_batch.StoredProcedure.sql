SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[start_batch]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[start_batch] AS' 
END
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-12-21 BvdB continue batch if running or start new batch. allow custom code integration 
--  with external batch administration
declare @batch_id int 
exec dbo.start_batch @batch_id output 
print @batch_id 
select * from dbo.batch 
where batch_id = @batch_id 
*/
ALTER   PROCEDURE [dbo].[start_batch] 
	@batch_id int output 
	, @batch_name as varchar(255) ='adhoc' 
	, @guid as bigint= null  
as 
begin 
   declare 
		@prev_batch_id as int 
		,@prev_status as varchar(255) 
		,@status as varchar(255) 
		,@legacy_status as varchar(255) 
		,@prev_batch_start_dt datetime
		,@prev_batch_name varchar(100) = null 
		,@status_id as int 
		,@nu as datetime = getdate() 
		,@proc_name as varchar(255) =  object_name(@@PROCID)
		,@continue_batch as bit =0 
		,@prev_seq_nr as int 
		,@sql as varchar(max) 
	-- first check for aborted jobs in ssisdb execution history -> update batch status accordingly

	-- standard BETL header code... 
	set nocount on 
	exec dbo.log -1, 'Header', '? ?', @proc_name , @batch_name
	-- END standard BETL header code... 

	set @sql = '
	update b set status_id = 
		CASE e.Status 
               WHEN 4 THEN 200 -- error 
               else 700  -- stopped
			end 
	from dbo.batch b
	inner join static.Status s on b.status_id = s.status_id 
	inner join ssisdb.catalog.executions e on e.execution_id  = b.guid
	where s.status_name in (  ''running'' , ''continue'') 
	and 	 CASE e.Status 
               WHEN 1 THEN ''created'' 
               WHEN 2 THEN ''running'' 
               WHEN 3 THEN ''canceled'' 
               WHEN 4 THEN ''failed'' 
               WHEN 5 THEN ''pending'' 
               WHEN 6 THEN ''ended unexpectedly'' 
               WHEN 7 THEN ''succeeded'' 
               WHEN 8 THEN ''stopping'' 
               WHEN 9 THEN ''completed'' 
			   else ''unknown''
			end <> ''running''
	'
	if db_id('ssisdb') is not null
		exec(@sql) 
	-- update status of running batches which are started from visual studio. 
	update b
	set status_id = 700 
	from dbo.batch b
	--inner join static.Status s on b.status_id = s.status_id 
	where guid =-1 and status_id = 400 -- started in visual studio
	--and exec_user = suser_sname() 
	and batch_name=@batch_name
	-- also stop transfers for stopped batches
	update t
	set status_id = 700 
	from dbo.Transfer t
	inner join dbo.Batch b on t.batch_id = b.batch_id 
	where b.status_id = 700 and t.status_id in ( 600, 400) 
	begin try 
	begin transaction		
   if not isnull(@batch_id ,-1) > 0   -- no batch given-> create one... 
   begin 
		-- reset betl nesting etc. 
		exec dbo.setp 'nesting' , 0
		 -- first check to see if there is one running. 
		 select @prev_batch_id = max(batch_id) 
		 from dbo.Batch  b
		 inner join static.Status s on b.status_id = s.status_id 
		 where batch_name = @batch_name
			and isnull(status_name, '')   not in ( 'Not started', 'deleted') 
		
		 select @prev_status=status_name
		, @continue_batch=continue_batch
		, @prev_seq_nr = batch_seq
		 from dbo.Batch  b
		 left join static.Status s on b.status_id = s.status_id 
		 where b.batch_id = @prev_batch_id 
		set @status= 
		case @prev_status 
			when 'Success'		then 'Running'
			when 'Error'		then 'Continue'
			when 'Running'		then 'Not started' 
			when 'Restart'		then 'Running'
			when 'Continue'		then 'Not started' 
			when 'Stopped'		then 'Continue'
			else 'Running'
		end 
		if @continue_batch=0 and @status='Continue'
			set @status='running' 
		select @status_id = status_id 
		from static.Status 
		where status_name = @status
		insert into dbo.Batch(batch_name, batch_start_dt, status_id, prev_batch_id, guid, batch_seq )
		values (@batch_name, @nu, @status_id, @prev_batch_id, @guid, isnull(@prev_seq_nr+1,0) ) 
		set @batch_id = SCOPE_IDENTITY()
	end 
	footer: 
	
	commit transaction
	end try
	begin catch 
		declare @msg2 as varchar(255) =ERROR_MESSAGE() 
				, @sev as int = ERROR_SEVERITY()
				, @number as int = ERROR_NUMBER() 
		IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION
		exec dbo.log_error 0, @msg=@msg2,  @severity=@sev, @number=@number 
	end catch 
	if not isnull(@batch_id, -1) > 0 
		RAISERROR( 'failed to start batch' ,15,1) WITH SETERROR
	
	if @status='Not started' 
	begin 
		-- for logging we need a transfer_id 
		set @status_id = 300 -- not started
		declare @transfer_id as int 
		-- create transfer
		insert into dbo.Transfer(batch_id, transfer_start_dt, transfer_name, target_name,src_obj_id, status_id, prev_transfer_id, transfer_seq)
		values (@batch_id, @nu, 'empty' , '', null, @status_id, null, 0) 
		set @transfer_id = SCOPE_IDENTITY()
		exec dbo.log @transfer_id , 'Info', 'batch was not started because there is already one instance running with name ?, namely ? ', @batch_name , @prev_batch_id 
	    set @batch_id = -1 
	end 
	exec dbo.log -1, 'footer', '? ?(b?)..? (?)', @proc_name , @batch_name, @batch_id, @prev_batch_id, @status
end












GO
