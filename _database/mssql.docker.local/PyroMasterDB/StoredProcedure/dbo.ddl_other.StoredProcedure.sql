SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ddl_other]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[ddl_other] AS' 
END
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-21 BvdB part of ddl generation process ( when making new betl release) . 
exec [dbo].[ddl_other]
*/    
ALTER   PROCEDURE [dbo].[ddl_other] as 
begin
	set nocount on 
	-- first create a temp table of dependencies #dep
	if object_id('tempdb..#dep') is not null 
	drop table tempdb.#dep
	;
	WITH dep -- (object_id, obj_name, dep_id, dep_name, level, [type_desc], [schema])
			AS
		(
		SELECT DISTINCT
			sd.referencing_id object_id,
			object_name(sd.referencing_id) obj_name,
			so.[type_desc],
			schema_name(so.schema_id) [schema],
			Referenced_ID dep_id, -- = sd.referenced_major_id,
			Referenced_entity_name dep_name, -- Object = object_name(sd.referenced_major_id),
			1 AS Level
		FROM    
			sys.sql_expression_dependencies sd
			JOIN sys.objects so ON sd.referencing_id = so.object_id
			JOIN sys.objects dep_o ON sd.Referenced_ID = dep_o.object_id
			where     so.type in  ( 'P', 'IF' , 'FT', 'FS', 'FN', 'V')
					AND so.is_ms_shipped = 0
				and dep_o.type in  ( 'P', 'IF' , 'FT', 'FS', 'FN', 'V')
				and dep_o.is_ms_shipped =0 
/*
			 UNION ALL
			 SELECT 
					sd.referencing_id object_id,
					object_name(sd.referencing_id)  obj_name,
					sd.referencing_id  dep_id, -- = sd.referenced_major_id,
					sd.Referenced_entity_name dep_name, -- Object = object_name(sd.referenced_major_id),
					Level+1
			--select * 
			 FROM  sys.sql_expression_dependencies sd
				join  dep do
					   ON sd.referenced_id = do.object_id
			 WHERE					sd.Referenced_ID <> sd.referencing_id    		
  */
			 --SELECT
				--	sd.object_id,
				--	object_name(sd.object_id),
				--	object_name(referenced_major_id),
				--	obj_id,
				--	Level + 1
			 --FROM    
				--	sys.sql_dependencies sd
				-- JOIN DependentObjectCTE do ON sd.referenced_major_id = do.DependentObjectID       
			
			 )
			 SELECT object_id, obj_name , [type_desc], [schema] , dep_id, dep_name--   max(level) level
			 into #dep
			 FROM  dep	
			--drop table #dep

	--select * from  #dep 
	declare 
		@def as varchar(max) 
		--, @sql as varchar(4000) 
		, @level as int =0 
		, @id int
		, @obj_name varchar(255) 
	declare 
	   @t TABLE 
	( 
	 id int identity(1,1),
	 obj_name varchar(4000) 
	 ,def  varchar(max) 
	 ,[type_desc] varchar(100) 
	 ,[schema] varchar(100) 
	) 
	insert into @t
			select o.name, object_definition(o.object_id) def
			, o.[type_desc]
			, schema_name(o.schema_id) 
			from sys.objects o
			left join #dep d on o.object_id =d.object_id
			where o.[type_desc] in ('SQL_SCALAR_FUNCTION',
			'SQL_STORED_PROCEDURE',
			'SQL_TABLE_VALUED_FUNCTION',
			'SQL_TRIGGER',
			'VIEW')
			and d.dep_name is null 
	while @level < 10
	begin --select * from @t
		insert into @t
			select distinct d.obj_name, object_definition(object_id) def, [type_desc], [schema]
			from #dep d 
			--where d.level = @level
			where d.dep_name in ( select obj_name from @t) -- dependend object is already added
		         and d.obj_name not in ( select obj_name from @t) -- dont add tw
		set @level+=1
	end 
	--select * from @t order by 1
	declare @i as int = 1
		, @j int
		, @n int
		, @nextspace int
		, @obj_type varchar(100) 
		, @type_desc varchar(100) 
		, @schema varchar(100) 
		, @newline nchar(2)= nchar(13) + nchar(10)
		, @full_obj_name as varchar(255) 
	while @i <= ( select max(id) from @t ) 
	begin
		SELECT @DEF= def , @id = id, @obj_name =obj_name 
		, @obj_type = 
		    case [type_desc]
				when  'SQL_SCALAR_FUNCTION' then 'FUNCTION' 
				when  'SQL_STORED_PROCEDURE' then 'PROCEDURE' 
				when  'SQL_TABLE_VALUED_FUNCTION' then 'FUNCTION' 
				when  'SQL_TRIGGER' then 'TRIGGER' 
				when  'VIEW' then 'VIEW' 
			end 
		, @type_desc = [type_desc] 
		, @schema = [schema]
		, @full_obj_name = '['+ [schema] + '].['+ [obj_name] + ']'
		from @t where id = @i
      print 'print ''-- '+ convert(varchar(255), @id) + '. '+ @obj_name + '''
IF object_id('''+ @full_obj_name + ''' ) is not null 
  DROP '+ @obj_type + ' ' +@full_obj_name + ' 
GO
'
	   /*
	   set @n = len(@def) 
	   set @j = 1 
	   set @nextspace=0
	   
	    while (@j <= @n)
        begin
 --           while Substring(@def,@j+3000+@nextspace,1) <> ' ' Substring(@def,@j+3000+@nextspace,2) <> @newline
            while Substring(@def,@j+3000+@nextspace,2) <> @newline and (@j+@nextspace<= @n) 
                BEGIN
                    set @nextspace = @nextspace + 1
                end
            print Substring(@def,@j,3000+@nextspace)
            set @j = @j+3000+@nextspace
            set @nextspace = 0
         end
		 */
	   exec util.print_max @def -- print is limited to 4000 chars workaround:
	   print '
GO
'
		set @i+=1
	end
end











GO
