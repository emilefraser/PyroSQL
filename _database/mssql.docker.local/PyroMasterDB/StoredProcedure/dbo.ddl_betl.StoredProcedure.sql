SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ddl_betl]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[ddl_betl] AS' 
END
GO
	  
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB generate a tsql script that contains a betl release 
exec dbo.ddl_betl 
*/
ALTER   PROCEDURE [dbo].[ddl_betl] as 
begin 
	set nocount on 
    declare @major_version as int
		, @minor_version as int
		, @build as int
		, @build_dt as varchar(255) = convert(varchar(255), getdate(),120) 
		, @version_str as varchar(500) ='?'

   select @major_version =major_version
		, @minor_version= minor_version
		, @build = build 
   from static.[Version]
   set @build+=1 
   update static.[Version] set build = @build , build_dt = @build_dt 
   set  @version_str = convert(varchar(10), @major_version) + '.'+ convert(varchar(10), @minor_version) + '.'+ convert(varchar(10), @build)+ ' , date: '+ @build_dt
  print '
-- START BETL Release version ' + @version_str+ '
set nocount on 
use betl 
-- WARNING: This will clear the betl database !
IF EXISTS (SELECT * FROM sys.objects WHERE type = ''P'' AND name = ''ddl_clear'')
	exec dbo.ddl_clear @execute=1
-- schemas
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''util'')
begin
	EXEC sys.sp_executesql N''CREATE SCHEMA [tool]''
	exec sp_addextendedproperty  
		 @name = N''Description'' 
		,@value = N''Generic utility data and functions'' 
		,@level0type = N''Schema'', @level0name = ''util'' 
end
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''static'')
begin 
	EXEC sys.sp_executesql N''CREATE SCHEMA [static]''
	exec sp_addextendedproperty  
		 @name = N''Description'' 
		,@value = N''Static betl data, not dependent on customer implementation'' 
		,@level0type = N''Schema'', @level0name = ''static'' 
end-- end schemas
IF NOT EXISTS (SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = schema_ID(''dbo'') AND [name] = N''Description'' AND [minor_id] = 0)
exec sp_addextendedproperty  
	@name = N''Description'' 
	,@value = N''dbo data is specific for each customer implementation'' 
	,@level0type = N''Schema'', @level0name = ''dbo'' 
-- end schemas
-- user defined table types 
CREATE TYPE [dbo].[ColumnTable] AS TABLE(
	[ordinal_position] [int] NOT NULL,
	[column_name] [varchar](255) NULL,
	[column_value] [varchar](255) NULL,
	[data_type] [varchar](255) NULL,
	[max_len] [int] NULL,
	[column_type_id] [int] NULL,
	[is_nullable] [bit] NULL,
	[prefix] [varchar](64) NULL,
	[entity_name] [varchar](64) NULL,
	[foreign_column_name] [varchar](64) NULL,
	[foreign_sur_pkey] [int] NULL,
	[numeric_precision] [int] NULL,
	[numeric_scale] [int] NULL,
	[part_of_unique_index] [bit] NULL,
	[identity] [bit] NULL,
	[src_mapping] varchar(255) null
	PRIMARY KEY CLUSTERED 
(
	[ordinal_position] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
CREATE TYPE [dbo].[MappingTable] AS TABLE(
	[src_id] [int] NOT NULL,
	[trg_id] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[src_id] ASC,
	[trg_id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
CREATE TYPE [dbo].[ParamTable] AS TABLE(
	[param_name] [varchar](255) NOT NULL,
	[param_value] varchar(max) NULL,
	PRIMARY KEY CLUSTERED 
(
	[param_name] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
CREATE TYPE [dbo].[SplitList] AS TABLE(
	[item] [varchar](max) NULL,
	[i] [int] NULL
)
GO
-- end user defined tables
'
	-- tables 
	declare 
		@t as varchar(255) 
		, @sql as varchar(max) 
	declare c cursor for
		select quotename(s.name ) + '.'+ quotename(t.name) 
		from sys.tables t
		inner join sys.schemas s on t.schema_id =s.schema_id
	open c 
	fetch next from c into @t
	while @@FETCH_STATUS=0
	begin 
		print '-- create table '+ @t
		set @sql = 'exec dbo.ddl_table '''  + @t + ''''
	    print 'GO
'
 		exec (@sql) 
	
		fetch next from c into @t
	end 
	close c
	deallocate c
	    print 'GO
'
    print '
INSERT [static].[Version] ([major_version], [minor_version], [build], build_dt) VALUES ('
	+convert(varchar(255), @major_version) + ','
	+convert(varchar(255), @minor_version) + ','
	+convert(varchar(255), @build) + ','''
	+convert(varchar(255), @build_dt) + ''')
GO
	'
	exec [dbo].[ddl_other]
	exec [dbo].[ddl_static]
	set nocount on 
	print '--END BETL Release version ' + @version_str
end












GO
