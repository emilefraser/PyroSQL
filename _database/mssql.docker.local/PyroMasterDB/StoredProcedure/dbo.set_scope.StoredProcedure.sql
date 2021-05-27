SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[set_scope]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[set_scope] AS' 
END
GO
	  

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB set scope of an object. scope groups object together so that they for example
-- can be be pushed together ( via push_all ) . 
exec betl.dbo.info '[idv].[stgl_klantverloop]'
exec betl.dbo.set_scope '[AdventureWorks2014].[idv].[stgl_klantverloop]' , 'final'
select * from betl.dbo.obj_ext 
where scope is null and ( 
	
	obj_name like 'stgl%'
	or 
	obj_name like 'stgh%'
	)
*/
 
ALTER  PROCEDURE [dbo].[set_scope] 
	@full_obj_name as varchar(255) 
	, @scope as varchar(255) 
as 
begin 
	-- standard BETL header code... 
	set nocount on 
	declare @transfer_id as int = 0 -- for internal betl procedures
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ? ?', @proc_name , @full_obj_name, @scope
	-- END standard BETL header code... 

	declare @obj_id as int
	exec dbo.get_obj_id @full_obj_name, @obj_id output, @scope=null, @obj_tree_depth=default, @transfer_id=@transfer_id
	if @obj_id is null or @obj_id < 0 
	begin
		exec dbo.log @transfer_id, 'step', 'Object ? not found in scope ? .', @full_obj_name, @scope 
		goto footer
	end
	exec dbo.log @transfer_id, 'step', 'obj_id resolved: ?(?), scope ? ',@full_obj_name, @obj_id , @scope
	update dbo.obj set scope = @scope 
	where obj_id = @obj_id
	select * from dbo.obj_ext 
	where obj_id = @obj_id
	footer:
		exec dbo.log @transfer_id, 'footer', 'DONE ? ? ', @proc_name , @full_obj_name, @scope
	-- END standard BETL footer code... 
end











GO
