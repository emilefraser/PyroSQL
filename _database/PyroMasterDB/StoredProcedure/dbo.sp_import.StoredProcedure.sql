SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_import]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[sp_import] AS' 
END
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
declare @run_id as int =0
	, @target_table as varchar(255) = 'f_subs_cd_subscription'
	, @schema as varchar(255) ='idv' 
declare @target_table_full as varchar(255) = @schema +'.'+ @target_table 
exec dbo.sp_import @src_sql, @target_table_full, @run_id 
*/
ALTER   PROCEDURE [dbo].[sp_import]
	@src_sql as varchar(8000) 
	, @target_table as varchar(255) 
	, @batch_id as int=0 
as
begin 
	set nocount on 
	declare 
		@transfer_id int =0 
		, @proc_name as varchar(255) =  object_name(@@PROCID)
		, @sql as varchar(8000) 
		, @is_running_in_batch as bit = 0
	declare 
		 @transfer_name as varchar(255) = @proc_name+ ' '+ @target_table
	if @batch_id>0 -- meaning: a batch_id was given as parameter.
		set @is_running_in_batch=1
   exec betl.dbo.start_batch @batch_id output
   exec betl.dbo.start_transfer @batch_id output , @transfer_id output , @transfer_name 
   if @is_running_in_batch=0 -- this push is running in a batch 
	 update betl.dbo.Batch set batch_name = @transfer_name where batch_id = @batch_id 
	exec betl.dbo.log @transfer_id , 'header', 'start ?(?) target table ?', @proc_name , @transfer_id, @target_table 
	declare @p as ParamTable 
	set @sql = '
if object_id("<target_table") is not null -- exists 
	truncate table <target_table> 
	insert into <target_table> 
	<src_sql>
else 
	
	select * into <target_table> 
	from ( 
		<src_sql> 
	) q 
select @@ROWCOUNT
'
	INSERT into @p values ('target_table', @target_table)  
	INSERT into @p values ('src_sql', @src_sql)  
	EXEC util.apply_params @sql output, @p
	
	print @sql 
	exec betl.dbo.log @transfer_id , 'footer', 'start ?(?) target table ?', @proc_name , @transfer_id, @target_table 
end












GO
