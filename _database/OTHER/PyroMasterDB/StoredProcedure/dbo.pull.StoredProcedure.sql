SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pull]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pull] AS' 
END
GO

	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-09-30 BvdB @full_obj_name can be a table or a schema_name. when @full_obj_name is a schema_name then 
-- pull will apply itself to all tables in this schema in the following way: 
-- construct a control flow for pulling all tables in @schema_name in the right order (based on foreign key dependencies). 
-- pull each table. 

-- when @full_obj_name is a table_name then pull will 
-- apply the push procedure on the source of this table. 

-- Pull is a top-down approach ( e.g. for the integrated datawarehouse). The target database model is leading. 
-- Push is a botom-up approach ( e.g. for staging layer and raw data warehouse). The raw source data is leading. 

exec reset
exec debug
exec verbose

exec dbo.pull 'betl.[dbo]' 
select * from dbo.obj_dep
where obj_id = 195
*/

ALTER   PROCEDURE [dbo].[pull]
    @full_obj_name as sysname
	, @batch_id as int = null
	, @transfer_id as int = -1
	, @async as bit=0 -- run asynchronously 
AS

BEGIN
	begin try 

		declare 
			-- source
			@betl varchar(100) =db_name() 
			, @obj_id as int
			, @obj_name as sysname
			, @prefix as nvarchar(255) 
			, @obj_name_no_prefix as sysname
			, @obj_type as varchar(255) 
			, @srv_name as sysname
			, @schema_name as sysname
			, @db_name as sysname
			, @schema_id as int 

			-- other
			, @proc_name as varchar(255) =  object_name(@@PROCID)
			, @msg as varchar(255)
			, @sev as int = 15
			, @number as int =0
			, @result as int =0 
			, @status as varchar(100) = 'success'
			, @transfer_name as varchar(255) = 'pull '+ @full_obj_name 
		
		set @msg = 'error in '+@proc_name

		-- standard BETL header code... 
		set nocount on 
		exec dbo.log @transfer_id, 'Header', '?(t?,b?) ?, async=?', @proc_name ,  @transfer_id, @batch_id, @full_obj_name, @async
		-- END standard BETL header code... 

		exec dbo.start_transfer @batch_id output , @transfer_id output , @transfer_name

		exec dbo.log @transfer_id, 'INFO', 'START ? ?, ?(?), async=?', @proc_name , @full_obj_name, @batch_id, @transfer_id, @async


		if @transfer_id = 0 
		begin
			set @status= 'skipped' --  select * from betl.static.status
			exec dbo.log @transfer_id, 'info', 'transfer_id is zero->skipping push'
			goto footer
		end

		exec dbo.get_obj_id @full_obj_name, @obj_id output, @obj_tree_depth=DEFAULT, @transfer_id=@transfer_id

		if @obj_id is null or @obj_id < 0 
		begin
			exec dbo.log @transfer_id, 'error',  'object ? not found.', @full_obj_name
			goto footer
		end
		else 
			exec dbo.log @transfer_id, 'step' , 'obj_id resolved: ?', @obj_id 

		select 
			@obj_type = obj_type
			, @obj_name = [obj_name]
			, @prefix = [prefix]
			, @obj_name_no_prefix = [obj_name_no_prefix]
			, @db_name = db_name
			, @schema_name = [schema_name] 
		from dbo.obj_ext 
		where [obj_id] = @obj_id 

		if @obj_type = 'schema'
		begin 
			exec dbo.log @transfer_id, 'step' , 'pull schema ?', @schema_name
			-- retrieve all foreign key dependencies for this schema
			-- exec dbo.get_dep @full_obj_name, 0, 1
			exec dbo.get_dep_obj_id @obj_id =@obj_id, @dependency_tree_depth = 0
					, @obj_tree_depth = 1,	@transfer_id=@transfer_id, @display = 0
			
			-- the stack may contain dependency searches for children or dependent objects of @obj_id. 
			exec dbo.process_stack @transfer_id

			exec [dbo].[top_sort_obj_dep] @transfer_id

			-- construct a control flow for pulling all tables in @schema_name in the right order (based on foreign key dependencies). 
			select d.* 
			from [dbo].[Obj_dep_ext] d
			inner join dbo.obj o on d.obj_id=o.obj_id
			where o.parent_id = @obj_id and obj_type ='table'


		end
		else
			begin 
				if @obj_type = 'table'
				begin
					exec dbo.log @transfer_id, 'step' , 'pull table ?', @obj_name

				end
				else
				begin 
					exec dbo.log @transfer_id, 'error' , 'pull can only be applied on schemas and tables. Not on a ?, for object= ?(?)', @obj_type, @full_obj_name, @obj_id
					goto footer
				end
			end


		-- standard BETL footer code... 
		footer:

	end try 
	begin catch
		set @msg  =isnull(error_procedure()+ ', ','')+ ERROR_MESSAGE() 
		set @sev = ERROR_SEVERITY()
		set @number = ERROR_NUMBER() 
		exec dbo.log_error @transfer_id=@transfer_id, @msg=@msg,  @severity=@sev, @number=@number
		set @result = -3
		set @status='error'
	end catch 
	
	if @result is null
		set @result =-1
	if @result<>0 and @result<> -3
	begin
		set @status='error'
		exec dbo.log @transfer_id, 'error' , '? received error code ?', @proc_name, @result
	end

	exec dbo.end_transfer @transfer_id  ,@status
   
	exec dbo.log @transfer_id, 'footer', '? ?, ?(?), async=?', @proc_name , @full_obj_name, @batch_id, @transfer_id, @async
  
	-- make sure that caller also receives error 
	if @result <> 0 
	begin 
		set @msg  =isnull(error_procedure()+ ' ','')+ ' ended with error status.'
		RAISERROR(@msg , 15 , 0)  WITH NOWAIT
	end
		
   return @result 
END







GO
