SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[push_all]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[push_all] AS' 
END
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-12-21 BvdB wrapper to call push for several objects
exec betl.dbo.push '%[dm].[stgd_%' , @batch_id =-1,  @scope = 'shared'
exec betl.dbo.push '%[idv].[stgl_%' , @batch_id =-1,  @scope = 'shared'
exec betl.dbo.push '%[medcare].[%' , @batch_id =0
-----------------------------------------------------------------------------------------------
*/
ALTER   PROCEDURE [dbo].[push_all]
    @full_obj_names as varchar(255)
	, @batch_id as int 
	, @template_id as smallint=0
	, @scope as varchar(255) = null 
	, @transfer_id as int =null
AS
BEGIN
	set nocount on 
	declare   @proc_name as varchar(255) =  object_name(@@PROCID)
		,@transfer_name as varchar(255) = 'push_all '+ @full_obj_names + isnull(' --' + convert(varchar(10), @template_id) ,'') 
	exec dbo.start_transfer @batch_id output , @transfer_id output , @transfer_name
	-- standard BETL header code... 
	exec dbo.log @transfer_id, '-------', '--------------------------------------------------------------------------------'
	exec dbo.log @transfer_id, 'header', '? ?(?) batch_id ? transfer_id ? template_id ?', @proc_name , @full_obj_names, @scope, @batch_id, @transfer_id, @template_id
	exec dbo.log @transfer_id, '-------', '--------------------------------------------------------------------------------'
	-- END standard BETL header code... 
	
	if not isnull(@transfer_id,0)  > 0 and isnull(@batch_id,0)  > 0 
	begin
		exec dbo.log @transfer_id, 'ERROR', '? needs to be called via dbo.push', @proc_name
		goto footer
	end
	
	if not charindex('%', @full_obj_names )  >0 
	begin
		exec dbo.log @transfer_id, 'ERROR', '? needs % sign in @full_obj_names: ?', @proc_name, @full_obj_names
		goto footer
	end
	
	-- refresh @full_obj_names..  it will fail at %, but then it will try to refresh the parent ( without %)
	exec betl.[dbo].refresh @full_obj_names

	declare @sql as varchar(max)
			, @p as ParamTable
			, @betl varchar(100) =db_name() 
	set @full_obj_names = replace(@full_obj_names, '[', '\[') 
	set @full_obj_names = replace(@full_obj_names, ']', '\]') 
	set @sql = '
		declare @sql as varchar(max) =''begin try
''
		;
		with q As( 
			SELECT betl.full_obj_name 
			FROM <betl>.dbo.obj_ext betl
			where 
				1=1
				<scope_sql>
				and full_obj_name like "<full_obj_names>" ESCAPE "\"
		) 
		select @sql+= ''	exec <betl>.dbo.push @full_obj_name=''''''+ q.full_obj_name  + '''''', @batch_id =<batch_id>, @async=1
''
		from q
		
		select @sql+= ''
			declare @result as int=0 
			exec betl.dbo.log <transfer_id>, ""INFO"", ""done push_all <full_obj_names>""
		end try 
		begin catch
				declare @msg_<transfer_id> as varchar(255) =ERROR_MESSAGE() 
						, @sev_<transfer_id> as int = ERROR_SEVERITY()
						, @number_<transfer_id> as int = ERROR_NUMBER() 
				set @result =@number_<transfer_id>

				IF @@TRANCOUNT > 0
                      ROLLBACK TRANSACTION
				exec dbo.log_error @transfer_id=<transfer_id>, @msg=@msg_<transfer_id>,  @severity=@sev_<transfer_id>, @number=@number_<transfer_id> 
		end catch 
	   -- make sure that caller ( e.g. ssis) also receives error 
	   if @result<>0
	   begin 
			-- exec dbo.log <transfer_id>, ""ERROR"", ""push_all caught error code ?"", @result
			RAISERROR(""error in [dbo].[push_all]"" , 15 , 0)  WITH NOWAIT
		end
''
		declare @result as int=0
		exec @result = dbo.exec_sql <transfer_id>, @sql 
		if @result<>0 
			exec dbo.log <transfer_id>, "ERROR", "push_all result indicates an error ?", @result
		
	'
	insert into @p values ('full_obj_names'			, @full_obj_names) 
	declare @scope_sql as varchar(255) 
	set @scope_sql = 'and scope = "'+@scope+ '"'
	insert into @p values ('scope_sql'					, isnull(@scope_sql, '') ) 
	insert into @p values ('betl'						, @betl) 
	insert into @p values ('batch_id'					, @batch_id) 
	insert into @p values ('transfer_id'				, @transfer_id) 
	EXEC util.apply_params @sql output, @p
	declare @result as int=0
	exec @result = dbo.exec_sql @transfer_id, @sql 
	if @result<>0 
		exec dbo.log @transfer_id, 'error', '? returned error code ?', @proc_name, @result
    footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? scope ? transfer_id ?', @proc_name , @full_obj_names, @scope, @transfer_id
	return @result
end












GO
