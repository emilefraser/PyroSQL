SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[onPreExecute]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[onPreExecute] AS' 
END
GO
	  
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-07-12 BvdB this is used in ssis event handling. 
declare @batch_id int ,
	@transfer_id int
exec dbo.start_transfer @batch_id output , @transfer_id output , 'test'
select * from dbo.batch where batch_id = @batch_id 
select * from dbo.transfer where transfer_id = @transfer_id
-- HEADER: onPreExecute batch_id 0, transfer_id 0,@src_obj_name :shared(?), @step_name ververs_kubus_cluster
declare @batch_id int =0
, @transfer_id int=0
, @package_name varchar(255) = ? 
, @scope varchar(255) = ?
, @schema varchar(255) = ?
, @src_obj_name varchar(255) =?
, @package_batch_id int =?
, @step_name as varchar(255) =?
exec betl.dbo.onPreExecute @batch_id output , @transfer_id output , @package_name, @scope , @schema , @src_obj_name , @package_batch_id , @step_name 
select @batch_id batch_id, @transfer_id transfer_id
*/
ALTER   PROCEDURE [dbo].[onPreExecute]
	@batch_id int output
	, @transfer_id int output 
	, @package_name as varchar(255) 
	, @scope varchar(255) =null  
	, @schema varchar(255) ='' 
	, @src_obj_name varchar(255) ='' 
	, @package_batch_id int =null 
	, @step_name as varchar(255) =null
	, @guid as bigint = null 
	, @interactive_mode as int =null
as 
begin 
	set nocount on 
	declare 
		@msg as varchar(255) =''
		,@nu as datetime = getdate() 
		,@proc_name as varchar(255) =  object_name(@@PROCID)
		,@target as varchar(255) 
		,@batch_name as varchar(255) 
		,@src_obj_id as int
	if @step_name in ('onPreExecute', 'onPostExecute')
		goto footer
	set @target = isnull(@schema+'_','') + isnull(@package_name,'') 
	set @batch_name = convert(Varchar(255), 
	isnull(@schema+'_','') + isnull(@scope,'') + 
		case when @package_name <> 'master' then isnull('_'+ @package_name,'') else '' end) 
	if @interactive_mode=1 	--If a package is running in SSIS Designer, 
	-- this property is set to True. If a package is running using the DTExec command prompt utility
	--, the property is set to False.
		set @guid = -1 
	--if @guid is null or len(@guid) <2 
	--	set @guid =   isnull(suser_sname() ,'')  + isnull('@'+ host_name() ,'') 
	if len(isnull(@src_obj_name,'')) > 0 
	begin
		select @src_obj_id  = dbo.obj_id(@src_obj_name, @scope) 
		if @src_obj_id  is null --try without scope 
			select @src_obj_id  = dbo.obj_id(@src_obj_name, null) 
	end
	--exec dbo.log @transfer_id, 'header', '? batch_id ?, transfer_id ?,@src_obj_name ?:?(?), @step_name ?', @proc_name , @batch_id, @transfer_id , @src_obj_name, @scope, @src_obj_id, @step_name
	--exec dbo.log @transfer_id, 'var', 'package_name ?',  @package_name
	--exec dbo.log @transfer_id, 'var', 'batch_name ?',  @batch_name
	--exec dbo.log @transfer_id, 'var', 'target ?',  @target
	if isnull( @package_batch_id  , -1 ) > 0 -- package batch id known-> if not then start_transfer will start the batch also
		set @batch_id = @package_batch_id  
	--exec dbo.log @transfer_id, 'step', 'pre start_transfer'
	if isnull( @transfer_id , -1 ) <=0 -- no transfer id known
		exec dbo.start_transfer @batch_id output , @transfer_id output , @package_name, @target, @src_obj_id, @batch_name , @guid
	--exec dbo.log @transfer_id, 'step', 'post start_transfer'
	
	--if isnull( @transfer_id , -1 ) <=0 -- no transfer id known
	--begin
	--	set @msg =  isnull( @step_name , '?')
	--	RAISERROR( @msg ,15,1) WITH SETERROR
	--end 
	--else
	begin
		if @step_name not in ('onPreExecute', 'onPostExecute')
		begin 
			--exec dbo.log @transfer_id, 'var', '@step_name ?', @step_name	
			exec dbo.log @transfer_id, 'header', '? ?', @proc_name , @step_name	
		end
	end
	
	footer: 
	
	--exec dbo.log 0, 'footer', '? batch_id ?, transfer_id ? ', @proc_name , @batch_id, @transfer_id 
end











GO
