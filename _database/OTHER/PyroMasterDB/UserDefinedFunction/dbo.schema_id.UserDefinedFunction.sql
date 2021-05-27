SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[schema_id]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-03-21 BvdB return schema_id of this full object name 
--  e.g. LOCALHOST.AdventureWorks2014.Person.Sales -> schema_id(LOCALHOST.AdventureWorks2014.Person)
*/
CREATE   FUNCTION [dbo].[schema_id]( @fullObj_name varchar(255), @scope varchar(255) = null  ) 
RETURNS int
AS
BEGIN
	--declare @fullObj_name varchar(255)= ''AdventureWorks.dbo.Store''
	declare @t TABLE (item VARCHAR(8000), i int)
	declare  
	     @elem1 varchar(255)
	     ,@elem2 varchar(255)
	     ,@elem3 varchar(255)
	     ,@elem4 varchar(255)
		, @cnt_elems int 
		, @obj_id int 
		, @remove_chars varchar(255)
		, @cnt as int 
		 
	set @remove_chars = replace(@fullObj_name, ''['','''')
	set @remove_chars = replace(@remove_chars , '']'','''')
	
	insert into @t 
	select * from util.split(@remove_chars , ''.'') 
	--select * from @t 
	-- @t contains elemenents of fullObj_name 
	-- can be [server].[db].[schema].[table|view]
	-- as long as it''s unique 
	select @cnt_elems = MAX(i) from @t	
	select @elem1 = item from @t where i=@cnt_elems
	select @elem2 = item from @t where i=@cnt_elems-1
	select @elem3 = item from @t where i=@cnt_elems-2
	select @elem4 = item from @t where i=@cnt_elems-3
	select @obj_id= max(o.obj_id), @cnt = count(*) 
	from dbo.[Obj] o
	LEFT OUTER JOIN dbo.[Obj] AS parent_o ON o.parent_id = parent_o.[obj_id] 
	LEFT OUTER JOIN dbo.[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[obj_id] 
	LEFT OUTER JOIN dbo.[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[obj_id] 
	where 	o.[obj_name] = @elem2
	and ( @elem3 is null or parent_o.[obj_name] = @elem3) 
	and ( @elem4 is null or grand_parent_o.[obj_name] = @elem4) 
	and ( @scope is null or 
			@scope = o.scope
			or @scope = parent_o.scope
			or @scope = grand_parent_o.scope
			or @scope = great_grand_parent_o.scope) 
	declare @res as int
	if @cnt >1 
		set @res =  -@cnt
	else 
		set @res =@obj_id 
	return @res 
END











' 
END
GO
