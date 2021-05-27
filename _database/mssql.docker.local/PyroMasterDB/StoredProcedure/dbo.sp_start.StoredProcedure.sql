SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_start]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[sp_start] AS' 
END
GO
	  

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-03-21 BvdB this sp is handles the logging administation and skip logic for every customer stored procedure. 
exec betl.dbo.sp_start 'dm.sp_imp_benchmarktype'
*/    
ALTER  procedure [dbo].[sp_start] ( @sp_name as varchar(4000) , @batch_id int=0  ) 
as
begin
	set nocount on 
	if object_id(@sp_name)  is null 
		set @sp_name = 'AdventureWorks2014.' + @sp_name  -- default db
	-- betl batch admin
	declare 
			@rec_cnt_src as int 
			, @rec_cnt_new as int 
			, @rec_cnt_changed as int 
			, @rec_cnt_deleted as int 
			, @status as varchar(100) = 'success'
			, @transfer_id as int
			, @param_string as varchar(4000) 
			, @sql as nvarchar(4000) 
			, @msg varchar(1000)
			, @sev as int 
			, @error_number as int 
			, @param_def as nvarchar(255) = '' 
			
	exec dbo.start_transfer @batch_id output, @transfer_id output , @sp_name
	if @transfer_id = 0  -- skip this sp. e.g. because the batch is continuing a previous batch. 
		goto footer
	-- end betl batch admin
	set @param_def = N'@transfer_id int, @rec_cnt_src int output, @rec_cnt_new int output, @rec_cnt_changed int output, @rec_cnt_deleted int output'
	set @sql= N'exec '+ @sp_name +' @transfer_id , @rec_cnt_src output, @rec_cnt_new output, @rec_cnt_changed output, @rec_cnt_deleted output'
	
	begin try 
		execute sp_executesql @sql, @param_def, @transfer_id=@transfer_id, @rec_cnt_src=@rec_cnt_src output 
				, @rec_cnt_new=@rec_cnt_new output , @rec_cnt_changed=@rec_cnt_changed output , @rec_cnt_deleted=@rec_cnt_deleted output 
--		exec betl.dbo.exec_sql @transfer_id , @sql
	end try
	begin catch
		set @msg =ERROR_MESSAGE() 
		set @sev = ERROR_SEVERITY()
		set @error_number = ERROR_NUMBER() 
		IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION
		exec dbo.log_error @transfer_id=@transfer_id, @msg=@msg,  @severity=@sev, @number=@error_number 
		set @status = 'error'
	end catch 
	footer:
		exec dbo.end_transfer @transfer_id, @status, @rec_cnt_src, @rec_cnt_new, @rec_cnt_changed , @rec_cnt_deleted 
	if @status = 'error'
	begin 
		set @msg = 'error in ' + @sp_name +  isnull(@msg,'') 
		RAISERROR(@msg , 15 , 0)  WITH NOWAIT
	end 
end











GO
