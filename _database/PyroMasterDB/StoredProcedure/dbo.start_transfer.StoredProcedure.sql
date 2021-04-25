SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[start_transfer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[start_transfer] AS' 
END
GO
  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-12-21 BvdB create transfer if not exist 
declare @batch_id int ,
	@transfer_id int
exec dbo.start_transfer @batch_id output , @transfer_id output , 'test'
select * from dbo.batch where batch_id = @batch_id 
select * from dbo.transfer where transfer_id = @transfer_id
*/
ALTER   PROCEDURE [dbo].[start_transfer]
	@batch_id int output
	, @transfer_id int output 
	, @transfer_name as varchar(255) 
	, @target varchar(255) ='' 
	, @src_obj_id int=null 
	, @batch_name as varchar(255) =null
	, @guid as bigint =null
as 
begin 
	set nocount on 
	declare 
		@prev_batch_id as int 
		,@prev_transfer_id as int 
		,@batch_status as varchar(255) 
		,@status as varchar(255) 
		,@prev_batch_status as varchar(255) 
		,@prev_status as varchar(255) 
		,@prev_transfer_end_dt as datetime
		,@new_status as varchar(255) 
		,@prev_batch_start_dt datetime
		,@prev_batch_name varchar(100) = null 
		,@status_id as int 
		,@msg as varchar(255) =''
		,@nu as datetime = getdate() 
		,@proc_name as varchar(255) =  object_name(@@PROCID)
		,@continue_batch as bit
		,@prev_seq_nr as int =0 

	-- standard BETL header code... 
	set nocount on 
	exec dbo.log -1, 'Header', '?(b?) ?', @proc_name , @batch_id, @transfer_name
	-- END standard BETL header code... 
	
	set @batch_name = isnull(@batch_name , isnull( @transfer_name ,'')) 
   	if not isnull(@batch_id,-1)>0 
		exec dbo.start_batch @batch_id output , @batch_name, @guid
	
	begin try 
	begin transaction		
	
	if not isnull(@batch_id,-1)>0 -- error no batch.. 
		goto footer
    -- exec dbo.log 0, 'var', 'batch_id ?, transfer_id ? ', @batch_id, @transfer_id 
	-- check @transfer_id
	if not isnull(@transfer_id,-1) > 0   -- no transfer_id given-> create one... 
	begin 
		select @transfer_id=transfer_id , @status =s.status_name
		from dbo.[Transfer] t
		inner join static.Status s on t.status_id = s.status_id
		where transfer_name = @transfer_name and batch_id = @batch_id 
		if @transfer_id >0 -- already exists
			goto footer 
		select @batch_status = s.status_name 
			, @prev_batch_id = prev_batch_id
		from dbo.Batch  b
		inner join static.Status s on b.status_id = s.status_id 
		where batch_id = @batch_id 
		select @prev_batch_status = s.status_name 
			, @continue_batch = continue_batch
		from dbo.Batch  b
		inner join static.Status s on b.status_id = s.status_id 
		where batch_id = @prev_batch_id 
		select @prev_status = s.status_name 
			, @prev_transfer_end_dt = t.transfer_end_dt
			, @prev_transfer_id = t.transfer_id 
			, @prev_seq_nr = transfer_seq
		from dbo.[Transfer] t 
		inner join static.status s on t.status_id = s.status_id
		where t.batch_id=@prev_batch_id
		and t.transfer_name = @transfer_name -- same name 
		if @batch_status is null 
		begin 
			-- a batch should always have a batch_status
			-- probably the batch_id that was supplied is invalid-> quit
			-- set batch status to running
			update dbo.Batch
			set status_id = (select status_id from static.status where status_name = 'running') 
			where batch_id = @batch_id 
			if @@ROWCOUNT = 0  
			begin 
				set @msg = 'Invalid batch id '+convert(varchar(255), @batch_id ) 
				set @status = 'error' 
				goto footer
			end
			set @batch_status = 'running' 
		end 
		if @status is null and @batch_status in ( 'error', 'stopped') 
		begin
			set @status = 'Not started' 
			set @msg = 'Transfer is not started because batch has status '+@batch_status 
		end 
		if @status is null and @continue_batch = 1 
		begin 
			--if @prev_batch_status in ( 'error', 'running', 'continue', 'stopped') 
			if isnull(@prev_status,'')  in ( 'success', 'skipped')
			--	and datediff(hour, @prev_transfer_end_dt , getdatE()) < 20 -- binnen 20 uur herstart ->continue
				set @status = 'skipped' -- skip this step 
			else
				set @status = 'running' -- run this step
			 set @msg = 'Batch status '+ @batch_status  + ', transfer status: '+ @status+ ' prev_status: '+@prev_status
		end 
		if @status is null and @batch_status in ( 'success') 
		begin 
			set @msg = 'Batch status changed from success to running'
			-- set batch status to running
			update dbo.Batch
			set status_id = (select status_id from static.status where status_name = 'running') 
			where batch_id = @batch_id 
			set @status = 'running' 
		end
		if @status is null and @batch_status in (  'running', 'restart') -- note that Restart should not occur. Because this 
		--- status is only set to previous batch
		begin 
			set @status = 'running' 
			set @msg = 'Batch status '+ @batch_status  + ', transfer status: '+ @status
		end 
		if @status is null 
		begin
			set @status='error'
			set @msg = 'error starting transfer for batch status '+ @batch_status  
		end 
		select @status_id = status_id from static.Status where status_name = @status

		insert into dbo.Transfer( batch_id, transfer_start_dt, transfer_name, target_name,src_obj_id, status_id, prev_transfer_id, transfer_seq)
		values (@batch_id, @nu, @transfer_name , @target, @src_obj_id, @status_id, @prev_transfer_id, isnull(@prev_seq_nr,0) +1) 
		select @transfer_id = SCOPE_IDENTITY()
		
		--exec dbo.log @transfer_id, 'INFO', @msg
	end  -- create transfer
	footer: 
	
	commit transaction
	end try
	begin catch 
		declare @msg2 as varchar(255) =ERROR_MESSAGE() 
				, @sev as int = ERROR_SEVERITY()
				, @number as int = ERROR_NUMBER() 
		IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION
		exec dbo.log_error @transfer_id, @msg=@msg2,  @severity=@sev, @number=@number 
	end catch 
	
	if @status in ( 'error', 'not started', 'stopped') 
	begin 
		set @msg = 'failed to start transfer '+isnull(@msg,'')+ isnull(', @batch_id = '+convert(varchar(10), @batch_id),'') 
		exec dbo.log @transfer_id, 'error', '? batch_id ?, transfer ?(transfer_id) : ? ? ? ', @proc_name , @msg
	end 
	if 	@status in ('skipped', 'error', 'Not started', 'stopped') 
		set @transfer_id = 0

	exec dbo.log @transfer_id, 'footer', '?(?) ?', @proc_name , @transfer_id, @msg

end











GO
