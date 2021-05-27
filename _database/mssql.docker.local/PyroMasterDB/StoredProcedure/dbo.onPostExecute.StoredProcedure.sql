SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[onPostExecute]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[onPostExecute] AS' 
END
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-07-12 BvdB this is used in ssis event handling. 
declare 
@batch_id int =?
, @transfer_id int=?
, @package_name varchar(255) = ? 
, @status as varchar(255) = ?
, @package_batch_id int = ?
, @step_name as varchar(255) = ?
, @rec_cnt_src as int = ?
, @rec_cnt_new as int = ?
, @rec_cnt_changed as int = ?
, @rec_cnt_deleted as int = ?
exec betl.dbo.onPostExecute @batch_id, @transfer_id, @package_name, @status, @package_batch_id , @step_name 
, @rec_cnt_src , @rec_cnt_new , @rec_cnt_changed , @rec_cnt_deleted 
*/
ALTER   PROCEDURE [dbo].[onPostExecute]
	@batch_id int 
	, @transfer_id int 
	, @package_name as varchar(255) 
	, @status as varchar(255) 
	, @package_batch_id int =null 
	, @step_name as varchar(255) =null
	, @rec_cnt_src as int =null 
	, @rec_cnt_new as int =null 
	, @rec_cnt_changed as int =null 
	, @rec_cnt_deleted as int =null 
as 
begin 
	set nocount on 
	declare 
		@msg as varchar(255) =''
		,@nu as datetime = getdate() 
		,@proc_name as varchar(255) =  object_name(@@PROCID);	
	if @step_name not in ('onPreExecute', 'onPostExecute')
	--exec dbo.log @transfer_id, 'header', '? batch_id ?, transfer_id ? ', @proc_name , @batch_id, @transfer_id 
	set @rec_cnt_src = case when isnull(@rec_cnt_src ,-1) < 0 then null else @rec_cnt_src  end 
	set @rec_cnt_new = case when isnull(@rec_cnt_new ,-1) < 0 then null else @rec_cnt_new  end 
	set @rec_cnt_changed = case when isnull(@rec_cnt_changed ,-1) < 0 then null else @rec_cnt_changed  end 
	set @rec_cnt_deleted = case when isnull(@rec_cnt_deleted ,-1) < 0 then null else @rec_cnt_deleted  end 
	if @rec_cnt_src >=0 and @rec_cnt_new is null 
		set @rec_cnt_new = @rec_cnt_src  -- simple truncate insert
	--exec dbo.log @transfer_id, 'var', '@rec_cnt_src ?, @rec_cnt_new ?,@rec_cnt_changed ?,@rec_cnt_deleted ?', @rec_cnt_src , @rec_cnt_new ,@rec_cnt_changed ,@rec_cnt_deleted 
	if isnull(@package_name,'') = isnull(@step_name,'')  -- post execute of package. 
	begin
		exec betl.dbo.end_transfer @transfer_id, @status
				, @rec_cnt_src 
				, @rec_cnt_new 
				, @rec_cnt_changed 
				, @rec_cnt_deleted 
		if isnull(@package_batch_id  ,-1) <= 0 -- package is not part of bigger batch-> end batch
			exec betl.dbo.end_batch @batch_id, @status, @transfer_id
	end
	if @step_name not in ('onPreExecute', 'onPostExecute')
		exec dbo.log @transfer_id, 'footer', '? ?', @proc_name ,@step_name
	footer: 
	
end












GO
