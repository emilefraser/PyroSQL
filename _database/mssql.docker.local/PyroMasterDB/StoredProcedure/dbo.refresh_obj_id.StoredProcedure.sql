SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[refresh_obj_id]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[refresh_obj_id] AS' 
END
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 02-03-2012 BvdB This proc will refresh the meta data of servers, 
--	databases, schemas, tables and views (also ssas) 
-- 2018-03-26 BvdB added stored procedures to schema refresh
-- 2018-04-10 BvdB added server_type_id. Note that sql server via linked server is not finished.
select * from dbo.obj_ext where full_obj_name like '%[idv]%'
select * from dbo.obj_ext where full_obj_name like '%stgl%'
exec betl.dbo.reset
exec betl.dbo.setp 'exec_sql', 0
-- instead of executing the dynamic sql, betl will print it, so you can execute and debug it yourself.
delete from dbo.obj 
where server_type_id =20
exec [dbo].[refresh_obj_id] 9453,1
exec dbo.reset
exec dbo.setp 'exec_sql', 0 
exec dbo.setp 'log_level', 'verbose'
select * from dbo.obj_ext
where server_type_id = 20
order by 1 desc
*/
ALTER   PROCEDURE [dbo].[refresh_obj_id]
    @obj_id int
	, @obj_tree_depth as int = 0 -- 0->only refresh full_obj_name, if 1 -> refresh childs under this object as well. 
						---if 2 then for each child also refresh it's childs.. e.g. 
						-- dbo.refresh 'LOCALHOST', 0 will only create a record in [dbo].[Obj] for the server BETL
						-- dbo.refresh 'LOCALHOST', 1 will also create a record for all db's in this server (e.g. BETL). 
						-- dbo.refresh 'LOCALHOST', 2 will create records in object for each table and view on this server in every database.
						-- dbo.refresh 'LOCALHOST', 3 will create records in object for each table and view on this server in every database and
						-- also fill dbo.Col_hist with all columns meta data for each table and view. 
	, @transfer_id as int = -1
AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'Header', '? ? , depth ?', @proc_name , @obj_id, @obj_tree_depth
	-- END standard BETL header code... 
	
	-- delete columns not related to objects... 
	delete c
	from dbo.col c
	left join dbo.obj o on c.obj_id = o.obj_id 
	where o.obj_id is null 
	-- in this proc. no matter what exec_sql says: always exec sql. 
	declare @exec_sql as int 
	exec dbo.getp 'exec_sql', @exec_sql output
	exec dbo.setp 'exec_sql', 1
	declare
			@obj_name as varchar(255) 
			, @full_obj_name2 varchar(255) 
			, @obj_type_id as int
			, @obj_tree_depth2 as int
             ,@sql as varchar(8000)
             ,@sql2 as varchar(8000)
             ,@sql3 as varchar(8000)
			 ,@sql_lookup_prefix as varchar(8000)
			
			, @sql_from as varchar(8000)
			, @sql_from2 as varchar(8000)
			, @sql_openrowset_ssas as varchar(8000) 
			, @sql_openquery as varchar(8000) 
             ,@cols_sql as varchar(8000)
             ,@cols_sql_select as varchar(8000)
             ,@db_name as varchar(100)
             ,@srv_name as varchar(100)
             ,@schema_name as varchar(255)
             ,@server_type as  varchar(255)
			, @nl as varchar(2) = char(13)+char(10)
			, @schema_id int
			, @p as ParamTable
			, @is_linked_server as bit 
			 ,@temp_table varchar(255)
			, @from varchar(8000) 
			, @from2 varchar(8000) 
			, @current_db varchar(255) 
			, @full_obj_name varchar(255)
			, @entity_name as varchar(255) 
			, @server_type_id as int 
			, @identifier as int 
			, @obj_type as varchar(255) 
	set @current_db = db_name() 
	set @sql_lookup_prefix   =  'cross join (select null prefix_name) prefix'
	select 
	@full_obj_name = full_obj_name
	,@obj_type = obj_type
	, @server_type_id = isnull(server_type_id, 10) -- default -> sql server
	, @server_type = server_type
	, @obj_name = [obj_name]
	, @srv_name = srv_name
	, @db_name = isnull(db_name,'') 
	, @schema_name = [schema_name] 
	, @is_linked_server = dbo.get_prop_obj_id('is_linked_server', @obj_id ) 
	, @entity_name = lower(obj_name)
	, @identifier = identifier
	from dbo.obj_ext 
	where obj_id = @obj_id
	exec dbo.log @transfer_id, 'step', 'refreshing ? ? ?', @server_type , @obj_type, @obj_name
	if @obj_type = 'server'  -- get all databases
	begin 
		if @server_type_id = 10 -- sql server
		begin
			set @from  = 'select name as obj_name, null as identifier, <const_database> as obj_type_id from sys.databases
						  where name not in ("master","model","msdb","tempdb") '
		end
		if @server_type_id = 20 -- ssas
			set @from   = 'select [CATALOG_NAME] as obj_name, null as identifier, "<const_database>" as obj_type_id from $System.DBSCHEMA_CATALOGS'
	end 
	if @obj_type = 'database' -- get all schemas and ssas roles
	begin 
		if @server_type_id = 10 -- sql server
--			set @from  = 'select schema_name as obj_name , null as identifier, "<const_schema>" as obj_type_id from <db>.information_schema.SCHEMATA	'
			set @from  = 'select s.name as obj_name , null as identifier, "<const_schema>" as obj_type_id 
						  FROM <db>.sys.schemas s inner join sys.sysusers u on u.uid = s.principal_id 
						  where u.issqluser = 1 and u.name not in ("sys", "guest", "INFORMATION_SCHEMA")	'
		if @server_type_id = 20 -- ssas
		begin	
			set @from   = 'select [Name] as obj_name, [ID] as identifier, "<const_schema>" as obj_type_id FROM [$System].[TMSCHEMA_MODEL]'
			set @from2  = 'select [Name] as obj_name, [ID] as identifier, "<const_role>" as obj_type_id FROM [$System].[TMSCHEMA_ROLES]'
		end 
	end 
	if @obj_type = 'role' 
	begin 
		if @server_type_id = 20 -- ssas
			set @from   = 'select [MemberName] as obj_name, [ID] as identifier, "<const_user>" as obj_type_id FROM 
							    SYSTEMRESTRICTSCHEMA([$System].[TMSCHEMA_ROLE_MEMBERSHIPS], [RoleID]=""<identifier>"" )'
	end 
	if @obj_type = 'schema' 
	begin 
		if @server_type_id = 10 -- sql server
		begin 
			set @from =  '
						select distinct o.name as obj_name , null as identifier, 
						case 
							when o.type = "V" then <const_view> 
							when o.type = "U" then <const_table> 
							when o.type = "P" then <const_procedure> 
						end obj_type_id 
						from <db>.sys.objects o
						inner join <db>.sys.schemas s on o.schema_id = s.schema_id
						where o.type in ( "U","V", "P") 
								  and s.name = "<schema>"
						and o.object_id not in (select major_id from <db>.sys.extended_properties 
									where name = N"microsoft_database_tools_support" and minor_id = 0 and class = 1) -- exclude ssms diagram procedures


'
			set @sql_lookup_prefix ='left join [dbo].Prefix prefix on [tool].[prefix_first_underscore](obj_name) = prefix.prefix_name
			'
		end
		if @server_type_id = 20 -- ssas
			set @from   = 'select [Name] as obj_name, [ID] as identifier, "<const_table>" as obj_type_id FROM 
						          SYSTEMRESTRICTSCHEMA ([$System].[TMSCHEMA_TABLES], [IsHidden]=""0"")'
	end 

	set @sql_openrowset_ssas =  'select * from openrowset("MSOLAP", "DATASOURCE=<srv>;Initial Catalog=<db>;<credentials>", "<from>" )  '
	set @sql_openquery       =  'select * from openquery([<srv>], "<from>" )'
	if @from2 is null -- single from 
	begin
		if @is_linked_server =1 -- use linked server
			if @server_type_id = 10 -- sql server
				set @sql_from = @sql_openquery
			else 								
				set @sql_from = 'linked server not supported for non sql server servertype'
		else -- @is_linked_server =0
			if @server_type_id = 10 
				set @sql_from = 'select * from (<from>) q_from'
			else  --if @server_type_id = 20 
				set @sql_from = @sql_openrowset_ssas 	
	end 
	else -- composite from  (2 froms) 
		if @is_linked_server =1 -- use linked server
			if @server_type_id = 10 -- sql server
				set @sql_from = @sql_openquery +' union all '+ replace(@sql_openquery, '<from>', '<from2>') 
			else 								
				set @sql_from = 'linked server not supported for non sql server servertype'
		else -- @is_linked_server =0
			if @server_type_id = 10 
				set @sql_from = 'select * from (<from>) q_from1 union all select * from (<from2>) q_from2'
			else  --if @server_type_id = 20 
				set @sql_from = @sql_openrowset_ssas +' union all '+ replace(@sql_openrowset_ssas, '<from>', '<from2>') 
	
	set @sql2 = '
begin try 
begin transaction 
	if object_id("tempdb..<temp_table>") is not null 
		drop table <temp_table>
   
    -- create temp table using default collation ( instead of select into ) 
	CREATE TABLE <temp_table>(
		[obj_type_id] [int] NULL,
		[obj_name] [varchar](255) NULL,
		[parent_id] [int] NOT NULL,
		[server_type_id] [int] NOT NULL,
		[identifier] [int] NULL,
		[prefix_name] [varchar](255) NULL,
		[obj_name_no_prefix] [varchar](255) NULL
	) 
	insert into <temp_table> with (tablock)
	select q.*, prefix_name 
	, case when prefix_name is not null and len(prefix_name)>0 then substring(q.obj_name, len(prefix_name)+2, len(q.obj_name) - len(prefix_name)-1) else q.obj_name end obj_name_no_prefix
	from (
		select convert(int, convert(nvarchar(255), obj_type_id)) obj_type_id, convert(varchar(255), obj_name) obj_name, <parent_id> parent_id, <server_type_id> server_type_id, convert(int, convert(nvarchar(255), identifier)) identifier
		from ( <sql_from> ) q2
	) q
	<sql_lookup_prefix>
'
	set @sql = '<sql2>
	insert into [dbo].[Obj] (obj_type_id, obj_name, parent_id, server_type_id, identifier, prefix, obj_name_no_prefix) 
	select q.* 
	from <temp_table> q 
	left join [dbo].[Obj] obj on q.obj_name = obj.obj_name and q.obj_type_id = obj.obj_type_id and q.parent_id = obj.parent_id 
	where obj.obj_name is null -- not exist 
					
	update [dbo].[Obj] 				 			 
	set delete_dt = 
		case when q.obj_name is null and Obj.delete_dt is null then <dt> 
		when q.obj_name is not null and Obj.delete_dt is not null then null end
		,record_dt = getdate(), record_user = suser_sname()
	from [dbo].[Obj] 
	left join <temp_table> q on Obj.obj_name = q.obj_name and obj.obj_type_id = q.obj_type_id 
	where obj.parent_id = <parent_id> 
	and  ( (q.obj_name is null     and Obj.delete_dt is null ) or 
  	       (q.obj_name is not null and Obj.delete_dt is not null ) )
	
	drop table <temp_table>
	commit transaction 
end try 
begin catch 
	declare 
		@msg as varchar(255)
		, @sev as int
	
	set @msg = convert(varchar(255), isnull(ERROR_MESSAGE(),""))
	set @sev = ERROR_SEVERITY()
	RAISERROR("Error Occured in [refresh_columns]: %s", @sev, 1,@msg) WITH LOG
	IF @@TRANCOUNT > 0  
		rollback transaction 
end catch 
'
		-- refresh columns 
	if @obj_type in ( 'table', 'view' ) and @server_type_id in (  10,20)  -- sql server
	begin 
		exec dbo.log @transfer_id, 'step', 'refreshing ? ? ?', @obj_type, @obj_name, @server_type_id 
		if @server_type_id = 10 
		begin 
			set @from   = 'something'
			set @cols_sql_select = '
	select 
		<obj_id> obj_id 
	, ordinal_position
	, column_name collate database_default   column_name
	, case when is_nullable="YES" then 1 when is_nullable="NO" then 0 else NULL end is_nullable
	, data_type 
	, character_maximum_length max_len
	, case when DATA_TYPE in ("int", "bigint", "smallint", "tinyint", "bit") then cast(null as int) else numeric_precision end numeric_precision
	, case when DATA_TYPE in ("int", "bigint'', ''smallint", "tinyint'', "bit") then cast(null as int) else numeric_scale end numeric_scale
	, case when util.suffix(column_name, 4) = "_key" then 
				case when lower(util.prefix(column_name, 4)) = "<entity_name>" then 100 else 110 end -- nat_key
			when util.suffix(column_name, 4) = "_sid" 
				then case when util.prefix_first_underscore(column_name) = ''hub'' then 200 else 210 end 
			when column_name= ''etl_data_source'' then 999 
			when left(column_name, 4) = "etl_" then 999
			else 300 -- attribute
		end derived_column_type_id 
	'
			if @is_linked_server = 1 
				set @cols_sql = '
	<cols_sql_select>
	from openquery( [<srv>], 
	"select ordinal_position, COLUMN_NAME collate database_default column_name
	, IS_NULLABLE, DATA_TYPE data_type, CHARACTER_MAXIMUM_LENGTH max_len
	, numeric_precision
	, numeric_scale
	from <db>.information_schema.columns where TABLE_SCHEMA = ""<schema>""
	and table_name = ""<obj_name>""
	order by ordinal_position asc"
			'
			else
				set @cols_sql = '
	<cols_sql_select>
	from <db>.information_schema.columns where TABLE_SCHEMA = "<schema>"
	and table_name = "<obj_name>"
				'
		end -- if @server_type_id = 10 
		if @server_type_id = 20 --ssas
		begin
			exec dbo.log @transfer_id, 'step', 'refreshing ssas ? ?', @obj_type, @obj_name
			-- set @sql_openrowset_ssas =  'select * from openrowset("MSOLAP", "DATASOURCE=<srv>;Initial Catalog=<db>;<credentials>", "<from>" )  '
			set @from = 'select 
	columnStorageID
	, sourceColumn as column_name
	, IsNullable as is_nullable
	, ExplicitDataType
	, isHidden
	, [TableID]
	FROM SYSTEMRESTRICTSCHEMA ([$System].[TMSCHEMA_COLUMNS], [TableID]=""<identifier>"", [IsHidden]=""0"", [Type]=""1"")'
		set @sql_from = @sql_openrowset_ssas
	
		set @cols_sql = ' 
	select 
		<obj_id> obj_id 
	, row_number() over (partition by <obj_id> order by columnStorageID) ordinal_position
	, convert(varchar(255), column_name) column_name
	, case when is_nullable="True" then 1 when is_nullable="False" then 0 else NULL end is_nullable
	, case when ExplicitDataType = 6 then "int" 
		when ExplicitDataType = 2 then "varchar" 
	  end data_type 
	, null max_len
	, null numeric_precision
	, null numeric_scale
	, null derived_column_type_id 
	from (<sql_from>) sql_from '
		end --if @server_type_id = 20 
			set @sql = '
	-----------------------------------------
	-- START refresh_obj_id <full_obj_name>(<obj_id>)
	-----------------------------------------
	BEGIN TRANSACTION T_refresh_columns
	BEGIN TRY
		if object_id("tempdb..<temp_table>") is not null drop table <temp_table>;
		with cols as ( 
			<cols_sql> 
		) 
		, q as ( 
		select 
		case when src.obj_id is null then trg.obj_id else src.obj_id end obj_id 
		, case when src.column_name is null then trg.column_name else src.column_name end column_name
		, src.ordinal_position
		, src.is_nullable
		, util.trim(src.data_type, 0) data_type
		, src.max_len
		, src.numeric_precision
		, src.numeric_scale
		, src.derived_column_type_id
		, trg.[column_type_id]
		, trg.src_column_id
		, trg.chksum old_chksum
		, getdate() eff_dt
		, trg.column_id trg_sur_key
		, case when trg.[prefix] is null AND trg.column_type_id = 110 THEN dbo.guess_prefix(src.column_name) ELSE trg.[prefix] END prefix
		, case when trg.[entity_name] is null AND trg.column_type_id = 110 THEN dbo.guess_entity_name(src.column_name, <obj_id>) ELSE trg.[entity_name] END entity_name
		, case when check_foreign_column.column_id is null AND trg.column_type_id = 110 then dbo.guess_foreign_col_id(src.column_name, <obj_id>) ELSE trg.foreign_column_id END foreign_column_id
		, case when src.obj_id is not null then 1 else 0 end in_src
		, case when trg.obj_id is not null then 1 else 0 end in_trg
		from cols src
		full outer join dbo.Col trg on src.obj_id = trg.obj_id AND src.column_name = trg.column_name
		left join dbo.Col check_foreign_column on check_foreign_column.column_id = trg.foreign_column_id
		where 
		not ( src.obj_id is null and trg.obj_id is null ) 
		and ( trg.obj_id is null or trg.obj_id in ( select obj_id from cols) ) 
		and trg.delete_dt is null 
		
		) , q2 as (
			select *, 
			 checksum("sha1", util.trim(src.ordinal_position, 0)
			 +"|"+util.trim(src.is_nullable, 0)
			 +"|"+util.trim(src.data_type, 0)
			 +"|"+util.trim(src.max_len, 0)
			 +"|"+util.trim(src.numeric_precision, 0)
			 +"|"+util.trim(src.numeric_scale, 0) 
			 +"|"+util.trim(src.entity_name, 0) 
			 +"|"+util.trim(src.foreign_column_id, 0) 
			 ) chksum 
			 from q src
		 ) 
			select 
					case 
					when old_chksum is null then "NEW" 
					when in_src=1 and old_chksum <> chksum and obj_id is not null then "CHANGED"
					when in_src=1 and old_chksum = chksum then "UNCHANGED"
					when in_src=0 and in_trg=1 then "DELETED"
					end mutation
					, * 
			into <temp_table>
			from q2
		      
			-- new records
			insert into dbo.Col_hist ( obj_id,column_name, eff_dt,  ordinal_position,is_nullable,data_type,max_len,numeric_precision,numeric_scale, chksum, transfer_id, column_type_id,src_column_id, prefix, entity_name, foreign_column_id) 
			select obj_id,column_name, eff_dt, ordinal_position,is_nullable,data_type,max_len,numeric_precision,numeric_scale, chksum, -1 , derived_column_type_id,src_column_id , prefix, entity_name, foreign_column_id from <temp_table>
			where mutation = "NEW"
  
			-- changed records and deleted records
			set identity_insert dbo.Col_hist on
  
			insert into dbo.Col_hist ( obj_id,column_name, eff_dt,  ordinal_position,is_nullable,data_type,max_len, numeric_precision,numeric_scale , delete_dt, column_id, chksum, transfer_id, column_type_id, src_column_id , prefix, entity_name, foreign_column_id) 
			select obj_id,column_name, eff_dt,  ordinal_position,is_nullable,data_type,max_len,numeric_precision,numeric_scale 
			, case when mutation = "DELETED" then getdate()  else null end delete_dt
			, trg_sur_key -- take target key for deleted and changed records
			, chksum
			, -1
			, column_type_id 
			, src_column_id
			,prefix 
			,  [entity_name]
			, foreign_column_id
			from <temp_table>
			where mutation in ("CHANGED", "DELETED")
  
			set identity_insert dbo.Col_hist off
		
			drop table <temp_table>
			-----------------------------------
			-- END HISTORIZE <temp_table>
			-----------------------------------
			USE <current_db>
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
			ROLLBACK TRANSACTION T_refresh_columns
     
		INSERT INTO [dbo].[Error]([error_code],[error_msg],[error_line],[error_procedure],[error_severity],[transfer_id]) 
		VALUES (
		[tool].Int2Char(ERROR_NUMBER())
		, isnull(ERROR_MESSAGE(),"")
		, [tool].Int2Char(ERROR_LINE()) 
		,  isnull(error_procedure(),"")
		, [tool].Int2Char(ERROR_SEVERITY())
		, [tool].Int2Char(<transfer_id>)    )
						       
		update dbo.[Transfer] set transfer_end_dt = getdate(), status_id = 200
		, last_error_id = SCOPE_IDENTITY() 
		where transfer_id = [tool].Int2Char(<transfer_id>) 
		declare 
			@msg as varchar(255)
			, @sev as int
	
			set @msg = convert(varchar(255), isnull(ERROR_MESSAGE(),""))
			set @sev = ERROR_SEVERITY()
			RAISERROR("Error Occured in [refresh_obj_id]: %s", @sev, 1,@msg) WITH LOG
		USE <current_db>
	END CATCH
	-----------------------------------------
	-- DONE refresh_obj_id <full_obj_name>(<obj_id>)
	-----------------------------------------
	'
	end -- @obj_type in ( 'table', 'view' ) and @server_type_id in (  10,20)  -- sql server
	if @from is null -- e.g. user or procedure
		goto footer
	delete from @p
	insert into @p values ('obj_type_id'							, @obj_type_id) 
	-- insert all obj_types as const_ parameters 
	insert into @p(param_name, param_value) 
	select 'const_'+ obj_type,  convert(varchar(255), obj_type_id ) 
	from static.obj_type 
	
	insert into @p values ('sql_openrowset_ssas'	, @sql_openrowset_ssas) 
	insert into @p values ('sql_openquery'			, @sql_openquery) 
	insert into @p values ('parent_id'				, @obj_id) 
	insert into @p values ('obj_name'			, @obj_name ) 
	insert into @p values ('entity_name'			, @entity_name ) 
	insert into @p values ('identifier'				, @identifier ) 
	insert into @p values ('full_obj_name'		, @full_obj_name ) 
	insert into @p values ('obj_id'					, @obj_id) 
	insert into @p values ('server_type_id'			, @server_type_id) 
	insert into @p values ('srv'					, @srv_name ) 
	insert into @p values ('schema'				    , @schema_name ) 
	insert into @p values ('transfer_id'			, util.trim(@transfer_id,0)) 
	insert into @p values ('date'				    , util.addQuotes(convert(varchar(50), getdate(),109) ) ) 
	insert into @p values ('db'						, @db_name ) 
	insert into @p values ('current_db'				, @current_db ) 
	insert into @p values ('from'					, @from ) 
	insert into @p values ('from2'					, @from2 ) 
	insert into @p values ('sql_from'				, @sql_from ) 
	insert into @p values ('sql_lookup_prefix'		, @sql_lookup_prefix ) 
	insert into @p values ('credentials'			, 'User=company\991371;password=anT1svsrnv') 
	insert into @p values ('temp_table'				, '#betl_meta_<obj_id>') 

	EXEC util.apply_params @cols_sql_select output, @p
	insert into @p values ('cols_sql_select'						, @cols_sql_select) 
	EXEC util.apply_params @cols_sql output, @p
	insert into @p values ('cols_sql'				, @cols_sql) 
	-- select * from @p
	EXEC util.apply_params @sql2 output, @p
	insert into @p values ('sql2'					, @sql2) 
	EXEC util.apply_params @sql output, @p
	EXEC util.apply_params @sql output, @p -- twice because some parameters might contain other parameters
	EXEC util.apply_params @sql output, @p -- three time because some parameters might contain other parameters
	--print @sql 

	exec dbo.exec_sql @transfer_id, @sql 
	
	set @sql = 'exec dbo.get_dep_obj_id @obj_id=<obj_id>, @transfer_id=<transfer_id> -- <full_obj_name>'
	delete from @p 		
	insert into @p values ('obj_id'					, @obj_id ) 
	insert into @p values ('transfer_id'			, @transfer_id ) 
	insert into @p values ('full_obj_name'			, @full_obj_name ) 
	EXEC util.apply_params @sql output, @p

	insert into dbo.Stack([value]) 
	values( @sql) 

	if @obj_tree_depth> 0 
	begin 
		declare c cursor LOCAL for 
			select full_obj_name from dbo.obj_ext
			where parent_id = @obj_id and delete_dt is null 
		open c
		fetch next from c into @full_obj_name2
		while @@FETCH_STATUS=0 
		begin
			set @obj_tree_depth2= @obj_tree_depth-1
			exec dbo.refresh @full_obj_name=@full_obj_name2, @obj_tree_depth=@obj_tree_depth2, @transfer_id=@transfer_id 
			fetch next from c into @full_obj_name2
		end 
		close c
		deallocate c
	end 
	-- standard BETL footer code... 
    footer:
	
	-- restore exec_sql setting 
	exec dbo.setp 'exec_sql', @exec_sql
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? ? ?', @proc_name , @full_obj_name, @obj_tree_depth, @transfer_id
	-- END standard BETL footer code... 
END











GO
