SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[exec_template]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[exec_template] AS' 
END
GO

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-09-24 BvdB execute template @template_name on object @full_object_name 
-- =============================================

select @@nestlevel
exec reset
exec debug

exec exec_template 'trig_betl_meta_data', 'DDP_IDW'

*/
ALTER   PROCEDURE [dbo].[exec_template]
	 @template_name as varchar(255)
	, @full_obj_name as nvarchar(255)
	, @transfer_id as int =0 
	, @batch_id as int = 0 -- see logging hierarchy above.
	, @async as bit=0 -- run asynchronously 


AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ?(?) ', @proc_name , @template_name, @full_obj_name
	-- END standard BETL header code... 

	declare 
		@sql as nvarchar(max) 
		, @p as ParamTable
		, @template_id int
		, @template_description as varchar(255)
		, @result as int =0 

		, @src_obj_id as int
		, @src_obj_type as varchar(255) 
		, @src_srv_name as varchar(255)
		, @src_db_name as varchar(255) 
		, @src_schema_name as varchar(255) 
		, @src_obj_name as varchar(255) 
		, @src_prefix as varchar(255) 
		, @src_obj_name_no_prefix as varchar(255) 


	-- retrieve sql template code 
	select @sql = template_sql , @template_id = template_id , @template_description= template_description
	from static.Template
	where template_name = @template_name

	if @sql is null 
	begin
		exec dbo.log @transfer_id, 'error', 'template [?] not found.', @template_name
		goto footer
	end

    ----------------------------------------------------------------------------
	exec dbo.log @transfer_id, 'STEP', 'retrieve obj_id from name ?', @full_obj_name
	----------------------------------------------------------------------------
	exec dbo.get_obj_id @full_obj_name, @src_obj_id output, @transfer_id=@transfer_id

	if @src_obj_id is null or @src_obj_id < 0 
	begin
		exec dbo.log @transfer_id, 'error', 'object ? not found.', @full_obj_name
		goto footer
	end


	select 
	@src_obj_type = obj_type
	, @src_srv_name = srv_name
	, @src_db_name = db_name
	, @src_schema_name = [schema_name] 
	, @src_obj_name = [obj_name]
	, @src_prefix = [prefix]
	, @src_obj_name_no_prefix = [obj_name_no_prefix]
	from dbo.obj_ext 
	where [obj_id] = @src_obj_id


	-- now we have an obj_id and a template sql --> let's merge these two and replace the placeholders with values. 
	-- there are a set of parameters which are default supplied. these are:
	-- generic parameters. Like betl ( what is the name of the betl database). 
	-- object source and target properties. Like db_name, schema_name etc. 
	-- generate a list of default parameters:

	delete from @p

	-- insert generic global variables
	insert into @p values ('betl'					, db_name() ) -- name of the betl database is current database name.
	insert into @p values ('build_dt'				, getdate()) 
	insert into @p values ('record_user'			, suser_sname()) 

	-- insert stored procedure scoped variables
	insert into @p values ('template_id'			, @template_id) 
	insert into @p values ('template_name'			, @template_name) 
	insert into @p values ('template_description'	, @template_description) 
	insert into @p values ('batch_id'				, @batch_id ) 
	insert into @p values ('transfer_id'			, @transfer_id ) 

	-- insert object dependent variables
	insert into @p values ('src_full_obj_name'		, @full_obj_name) 
	insert into @p values ('src_obj_type'			, @src_obj_type) 
	insert into @p values ('src_srv_name'			, @src_srv_name) 
	insert into @p values ('src_db_name'			, @src_db_name) 
	insert into @p values ('src_schema_name'		, @src_schema_name) 
	insert into @p values ('src_obj_name'			, @src_obj_name) 
	insert into @p values ('src_prefix'				, @src_prefix) 
	insert into @p values ('src_obj_name_no_prefix'	, @src_obj_name_no_prefix) 
	insert into @p values ('src_obj_id'				, @src_obj_id) 
	
	EXEC util.apply_params @sql output, @p

	exec @result = dbo.exec_sql @transfer_id=@transfer_id, @sql=@sql,  @async=@async, @trg_db_name = @src_db_name

	footer:
	exec dbo.log @transfer_id, 'footer', 'done ? ?(?) ', @proc_name , @template_name, @full_obj_name
	-- END standard BETL footer code... 

END

GO
