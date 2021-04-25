SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ddl_clear]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[ddl_clear] AS' 
END
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-21 BvdB Beware: this will clear the entire BETL database (all non ms objects) !
*/    
ALTER   PROCEDURE [dbo].[ddl_clear] @execute as bit = 0  as
begin 
	set nocount on 
	declare @sql as varchar(max) =''
	select @sql+= 'DROP '+
	   case 
	   when q.type ='P' then 'PROCEDURE' 
	   when q.type='U' then 'TABLE'
	   when q.type= 'V' then 'VIEW'
	   when q.type= 'TT' then 'TYPE'
	   else 'FUNCTION' end + ' ' + 
	   fullname + '
	;
	'
	from  (
	select so.object_id, so.name , so.type,  quotename(s.name) + '.' + quotename(so.name)  fullname 
	from sys.objects so
	inner join sys.schemas s on so.schema_id = s.schema_id 
	where     so.type in  ( 'U', 'V', 'P', 'IF' , 'FT', 'FS', 'FN', 'TF')
						AND so.is_ms_shipped = 0
     
	union all 
		SELECT null, name , 'TT' type ,name fullname
		FROM sys.types WHERE is_table_type = 1 
    ) q

--select quotename(s.name) + '.' + quotename(so.name), so.type
--from sys.objects so 
--inner join sys.schemas s on so.schema_id = s.schema_id 
--where   --  so.type in  ( 'U', 'V', 'P', 'IF' , 'FT', 'FS', 'FN')
--						 so.is_ms_shipped = 0
--order by 1
				
	if @execute = 1  
	   exec(@sql) 
	else 	
		print @sql
end











GO
