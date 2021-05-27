SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_dep_obj_id]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[get_dep_obj_id] AS' 
END
GO
/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2018-03-19 BvdB find dependencies for this object using betl and sql server meta data.
-- there are different types of dependencies. namely: 
-- 1. a transfer dependency. ( A-> B)  B is dependent on A. 
-- 2. a stored procedure dependency sp p uses tables a,b and c and view d
-- 3. A referencing dependency. view x references table a and b and view c ( using sys.dm_sql_referenced_entities) 
-- note that referencing dependencies include stored procedure depdendencies. However the reliability of sys.dm_sql_referenced_entities is not very good, so 
-- to be complete I wrote a template to get the 'forgotten' dependencies in stored procedures. 
-- 4. A foreign key dependency. table x references tables y and z. Based on the existance of foreign keys. (used for deriving control flow of the refresh job). 

exec get_dep_obj_id 195
exec debug
*/
--select * from dbo.Obj_dep
ALTER   PROCEDURE [dbo].[get_dep_obj_id] 
	@obj_id int
	, @dependency_tree_depth as int =0
	, @obj_tree_depth as int = 0
	, @display  as int = 0
	, @transfer_id as int = -1 
as
begin 
	--declare 
	--@obj_id int=56
	--, @dependency_tree_depth as int =1
	--, @obj_tree_depth as int = 0
	--, @display  as int = 1
	--	, @transfer_id as int = -1 

	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'Header', '? ?,@obj_tree_depth ? , @dependency_tree_depth ?, @display ? ', @proc_name , @obj_id, @obj_tree_depth, @dependency_tree_depth, @display 
	-- END standard BETL header code... 

	declare 
		@obj_name as sysname
		, @rows as int=0
		, @dep_obj_id int
		, @dep_obj_name sysname
--		, @nesting as int
		, @full_obj_name as nvarchar(500) 
		--, @scope as varchar(255) = null 
		--, @transfer_id as int =-1
		 , @db_name sysname
		 , @obj_db sysname
		 , @schema_name sysname 
		 , @obj_schema_name sysname
		 , @obj_type as varchar(255) 
		 , @server_type_id as int 
		 , @p as ParamTable
		 , @identifier as int
		 , @sql as varchar(max)=''
		 , @result as int =0 

	if @obj_id is null or @obj_id < 0 
	begin
		exec dbo.log @transfer_id, 'error',  'invalid obj_id ? .', @obj_id
		goto footer
	end
	
	select 
		@full_obj_name = full_obj_name
		, @obj_schema_name = quotename([schema_name]) + '.'+ quotename(obj_name)
		, @schema_name = [schema_name]
		, @obj_name = [obj_name]
	    , @obj_type = obj_type
		, @server_type_id = server_type_id
		, @obj_db = db_name
		, @identifier = identifier
	from dbo.Obj_ext
	where obj_id = @obj_id 	

	exec dbo.log @transfer_id, 'VAR', 'object: ? ?(?,?) , server type ?', @obj_type , @full_obj_name , @obj_id, @obj_id, @server_type_id 

	if object_id('tempdb..#dep') is not null
		drop table #dep

	-- first create a list of dependent objects #dep
	-- after this-> add this list to dbo.dep_rel (node table). 
	set @sql = '
if object_id(N''[tempdb]..#dep'', ''U'') is not null 
	drop table #dep

create table #dep(
	obj_name varchar(100) not null
	, schema_name varchar(100) not null
	, [dep_type_id] varchar(255) not null 
	, obj_id int
	primary key (obj_name , schema_name, [dep_type_id]) 
) 
'
--select * into betl.[db_name]o.test from sys.objects	
-- sysname 

	if @server_type_id = 10 -- sql server
	begin
		-- step 1
		set @sql += '
-- step 1. look in transfer log to find dependencies for <full_obj_name>( <obj_id>, <obj_type>) , server type: <server_type_id>

insert into #dep
select distinct lookup_obj.[obj_name], lookup_obj.[schema_name], 1 [dep_type_id], lookup_obj.obj_id
from dbo.transfer t
inner join dbo.obj_ext lookup_obj on t.src_obj_id = lookup_obj.obj_id 
where t.target_name = "<full_obj_name>"
'
		set @sql += '
-- step 2. find sql referenced entities for <full_obj_name>( <obj_id>, <obj_type>) , server type: <server_type_id>

insert into #dep 
SELECT distinct lookup_obj.[obj_name], lookup_obj.[schema_name], 2 [dep_type_id], lookup_obj.obj_id
FROM <obj_db>.sys.dm_sql_referenced_entities("<obj_schema_name>", "Object") d
inner join dbo.Obj_ext lookup_obj on d.[referenced_schema_name] = lookup_obj.[schema_name] collate database_default and d.[referenced_entity_name] = lookup_obj.obj_name collate database_default
and lookup_obj.[db_name]="<obj_db>" collate database_default
'
		set @sql += '
-- step 3. find stored procedure dependencies for <full_obj_name>( <obj_id>, <obj_type>) , server type: <server_type_id>
/*
insert into #dep 
SELECT distinct s.name schema_name , so.name obj_name, 3 [dep_type_id], lookup_obj.obj_id
FROM <obj_db>.sys.syscomments sc
INNER JOIN <obj_db>.sys.objects so ON sc.id=so.object_id 
inner join <obj_db>.sys.schemas s on s.schema_id = so.schema_id  
inner join dbo.Obj_ext lookup_obj on s.name = lookup_obj.[schema_name] collate database_default  and lookup_obj.obj_name = so.name collate database_default 
	and lookup_obj.[db_name]="<obj_db>" collate database_default 
WHERE 
	betl.util.remove_comments( text) 
	LIKE "%<obj_name>%" and type = "P"
*/
'

		set @sql += '
-- step 4. find foreign key dependencies for <full_obj_name>( <obj_id>, <obj_type>) , server type: <server_type_id>

insert into #dep 
-- SELECT distinct s.name schema_name , so.name obj_name, 4 [dep_type_id], lookup_obj.obj_id

SELECT
distinct
PK.TABLE_SCHEMA schema_name ,
PK.TABLE_NAME obj_name, 
4 [dep_type_id], 
lookup_obj.obj_id
FROM <obj_db>.INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C
INNER JOIN <obj_db>.INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
INNER JOIN <obj_db>.INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
inner join dbo.Obj_ext lookup_obj on PK.TABLE_SCHEMA = lookup_obj.[schema_name] collate database_default  and lookup_obj.obj_name = PK.TABLE_NAME collate database_default 
	and lookup_obj.[db_name]="<obj_db>" collate database_default 
where 
FK.TABLE_SCHEMA = "<schema_name>"
AND FK.TABLE_NAME = "<obj_name>"
'


	end -- if @server_type_id = 10 sql server
--	else 
--	begin -- server_type = 20 ssas
--		-- step 1
--		if @obj_type='table'
--			exec dbo.log @transfer_id, 'step' , 'try to relate cube tables to datamart tables in sql server ? (?) object type ?, server type ? ', @full_obj_name, @obj_id , @obj_type, @server_type_id 
--		insert into #dep
--		select 
--		obj.obj_id dep_obj_id, 'ssas to sql mapping'  [dep_type_id] 
--		--cube_obj.[db_name],
--		--cube_obj.[obj_name] , cube_obj.obj_name 
--		--, obj.[db_name]
--		--, obj.[obj_name] , obj.obj_name 
--		from dbo.obj_ext cube_obj
--		left join dbo.obj_ext obj on 
--		cube_obj.obj_name = obj.obj_name
--		and cube_obj.obj_id <> obj.obj_id 
--		and case when cube_obj.[db_name] like '%_company%' then 'bi_ready_dm' else 'MyDWH_dm' end = obj.[db_name]
--		-- object must live inside relevant datamart.
--		and obj.server_type_id=10 -- sql server 
--		where cube_obj.server_type_id = 20
--		and cube_obj.obj_type = 'table'
--		and cube_obj.obj_id = @obj_id 
--		and obj.obj_id is not null --> same as inner join
--		-- but not always the name of the tables are similar-> try 
--		-- to fix this using the sql query behind the table
--		if @@rowcount=0 and @obj_type = 'table'-- no name match..
--		begin 
--			declare @cnt as int 
--			select @cnt =count(*) from dbo.Obj_dep where obj_id = @obj_id 
--			if @cnt>0
--				goto footer -- there is already >1 dependency
--			-- step 2
--			exec dbo.log @transfer_id, 'step' , 'no name match-> try to match using sql behind ssas table'
--			if object_id('tempdb..#ssas_queries') is not null
--				drop table #ssas_queries
	
--			set @sql  ='
--if object_id("tempdb..<temp_table>") is not null
--	drop table <temp_table>
--select convert(varchar(255), name) name, convert(varchar(8000),[QueryDefinition]) sql 
--into <temp_table> 
--from openrowset(''MSOLAP'', ''DATASOURCE=ssas01.company.nl;Initial Catalog=<db>;<credentials>''
--			 , ''
--			select [name], [QueryDefinition] from 
--SYSTEMRESTRICTSCHEMA([$System].[TMSCHEMA_PARTITIONS], [TableID]=""<identifier>"" )
--			'')
--declare @sql as varchar(8000) 
--	, @parsed_sql as SplitList 
--select @sql=[sql] 
--from <temp_table> 
--insert into @parsed_sql select * from util.parse_sql(@sql) 
--select @from_clause = item 
--from @parsed_sql
--where i=0 
--'
--			--select * into #ssas_queries exec(@sql) 
--			delete from @p 		
--			insert into @p values('credentials'	, 'User=domain\user;password=secret') 
--			insert into @p values('db'				, @db_name) 
--			insert into @p values('identifier'				, @identifier) 
--			insert into @p values('obj_id', @obj_id) 
--			insert into @p values('obj_name', @obj_name) 
--			insert into @p values('temp_table' ,	'#ssas_query_<obj_id>') 

		
--			EXEC util.apply_params @sql output, @p
--			EXEC util.apply_params @sql output, @p -- twice
--			declare @from_clause as varchar(8000) 
--			-- exec dbo.log @transfer_id, 'VAR' , '@sql ?', @sql
--			exec dbo.log @transfer_id, 'VAR' , 'identifier ?', @identifier
--			exec dbo.log @transfer_id, 'VAR' , 'SQL ?', @sql
--			EXECUTE sp_executesql @sql, N'@from_clause as varchar(8000) OUTPUT', @from_clause = @from_clause OUTPUT
--			-- select @from_clause = util.filter(@from_clause , 'char(10),char(13)') 
--			exec dbo.log @transfer_id, 'VAR' , '@from_clause ?', @from_clause 
--			if @from_clause not like '%MyDWH_dm%' or
--			   @from_clause not like '%bi_ready_dm%'
--			begin 
--				set @dep_obj_name  = 
--					case when @db_name like '%_company%' then '[bi_ready_dm].' else '[MyDWH_dm].' end + @from_clause
--			end
--			exec dbo.log @transfer_id, 'VAR' , '@dep_obj_name:?', @dep_obj_name 
--			exec dbo.get_obj_id @full_obj_name=@dep_obj_name , @obj_id=@dep_obj_id output 
			
----			select @dep_obj_id = dbo.obj_id(@dep_obj_name , null) 
--			exec dbo.log @transfer_id, 'VAR' , '@dep_obj_id ?', @dep_obj_id
--			if @dep_obj_id is null 
--			begin 
--				-- if not found->try without db name
--				exec dbo.get_obj_id @full_obj_name=@from_clause , @obj_id=@dep_obj_id output 
--				exec dbo.log @transfer_id, 'VAR' , 'option 2 @dep_obj_id ?', @dep_obj_id
--			end 
			
--			if @dep_obj_id is not null 
--				insert into #dep
--				select 
--				@dep_obj_id dep_obj_id, 'ssas sql parsing'  [dep_type_id] 
--		end 
--		--print @sql 
--	end -- server_type = 20 ssas

set @sql += '

-- finally store the dependencies
-- select * from #dep 

-- update delete_dt
update d2
set delete_dt = 
	case when d.obj_id is null /* the dependency does not exists anymore */ 
		then getdate() 
	else null end 
	, record_dt = getdate()
	, record_user = suser_sname() 
from dbo.Obj_dep d2
left join #dep d on d2.dep_obj_id = d.obj_id and d2.dep_type_id = d.dep_type_id
where d2.obj_id = <obj_id>
-- deleted or undeleted
and ( (d.obj_id is null and d2.delete_dt is null ) /* the dependency does not exists anymore */ 
or ( d2.delete_dt is not null and d.obj_id is not null) ) 

-- insert new dependencies
insert into dbo.Obj_dep(obj_id, dep_obj_id, [dep_type_id]) 
select N"<obj_id>", obj_id, [dep_type_id]
from #dep
except 
select obj_id, dep_obj_id, [dep_type_id]
from dbo.Obj_dep
where obj_id = "<obj_id>" 

'

	delete from @p 		
	insert into @p values('obj_db'					, @obj_db) 
	insert into @p values('obj_id'					, @obj_id) 
	insert into @p values('obj_name'				, @obj_name) 
	insert into @p values('schema_name'				, @schema_name) 
	insert into @p values('full_obj_name'			, @full_obj_name) 
	insert into @p values('obj_schema_name'			, @obj_schema_name) 
	
	EXEC util.apply_params @sql output, @p

	exec @result = dbo.exec_sql @transfer_id, @sql 

	if @display = 1
		select * from dbo.Obj_dep_ext	
		where obj_id = @obj_id 
	
	--exec dbo.getp 'nesting' , @nesting output
	declare @save_@dependency_tree_depth as int = @dependency_tree_depth 
			, @dep_id as int

	-- we build a stack of to do items, that will be sequentially processed outside this procedure to prevent too many simultaneous executions. 
	-- first go down the dependency tree ( dependencies of objects that are dependent of @obj_id) 
	if @dependency_tree_depth > 0 -- travel through dependency tree
	begin 
		set @dependency_tree_depth += -1 
		set @sql = 'exec dbo.get_dep_obj_id @obj_id=<obj_id>, @dependency_tree_depth = <dependency_tree_depth>, @obj_tree_depth=<obj_tree_depth>, @display=<display>, @transfer_id=<transfer_id> -- <full_obj_name>'
		
		delete from @p 		
		insert into @p values ('transfer_id'			, @transfer_id ) 
		insert into @p values ('display'				, @display ) 
		insert into @p values ('obj_tree_depth'			, @obj_tree_depth) 
		insert into @p values ('dependency_tree_depth'	, @dependency_tree_depth) 
		EXEC util.apply_params @sql output, @p

		insert into dbo.Stack([value]) 
		select replace(replace(@sql, '<obj_id>', d.dep_obj_id) , '<full_obj_name>', o.full_obj_name) 
		from dbo.Obj_dep_ext d
		inner join dbo.Obj_ext o on d.dep_obj_id = o.obj_id
		where d.obj_id = @obj_id
	end 

	-- second go down the object tree ( dependencies of objects that are childs of @obj_id). e.g. tables when @obj_id is a schema. 
	if @obj_tree_depth > 0 -- travel through object tree
	begin 
		set @obj_tree_depth += -1 
		set @sql = 'exec dbo.get_dep_obj_id @obj_id=<obj_id>, @dependency_tree_depth = <dependency_tree_depth>, @obj_tree_depth=<obj_tree_depth>, @display=<display>, @transfer_id=<transfer_id> -- <full_obj_name>'
		delete from @p 		
		insert into @p values ('transfer_id'			, @transfer_id ) 
		insert into @p values ('display'				, @display ) 
		insert into @p values ('obj_tree_depth'			, @obj_tree_depth) 
		insert into @p values ('dependency_tree_depth'	, @dependency_tree_depth) 
		EXEC util.apply_params @sql output, @p

		insert into dbo.Stack([value]) 
		select replace(replace(@sql, '<obj_id>', obj_id) , '<full_obj_name>', full_obj_name) 
		from dbo.Obj_ext
		where parent_id = @obj_id
	end 

	footer:
	
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? ? ?', @proc_name , @full_obj_name, @dependency_tree_depth, @transfer_id
	-- END standard BETL footer code... 
 end 

GO
