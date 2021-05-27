SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_dep]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[get_dep] AS' 
END
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-03-19 BvdB find dependencies for this object using betl and sql server meta data.

exec dbo.get_dep '[AW_Staging].[dbo].[Illustration]'
exec dbo.get_dep '[betl].[dbo]'

select * from stack
*/ 
ALTER   PROCEDURE [dbo].[get_dep] 
	@full_obj_name varchar(255)
	, @dependency_tree_depth as int =0
	, @obj_tree_depth as int = 0
	, @display as bit = 0 
	, @scope as varchar(255) = null 
	, @transfer_id as int = -1 -- see logging hierarchy above.

as
begin 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'Header', '? ?, scope ? , object tree depth ?, dep tree depth ?', @proc_name , @full_obj_name, @scope, @obj_tree_depth, @dependency_tree_depth
	declare 
		@obj_id as int

	exec dbo.get_obj_id @full_obj_name, @obj_id output, @scope=@scope, @obj_tree_depth=DEFAULT, @transfer_id=@transfer_id

	if @obj_id is null or @obj_id < 0 
	begin
		exec dbo.log @transfer_id, 'error',  'object ? not found.', @full_obj_name
		goto footer
	end
	else 
		exec dbo.log @transfer_id, 'step' , 'obj_id resolved: ?', @obj_id 

	exec dbo.get_dep_obj_id @obj_id =@obj_id, @dependency_tree_depth = @dependency_tree_depth 
		, @obj_tree_depth = @obj_tree_depth,	@transfer_id=@transfer_id, @display = @display 

	exec dbo.process_stack

	footer:
	
	exec dbo.log @transfer_id, 'Footer', '? ?, scope ? , depth ?', @proc_name , @full_obj_name, @scope, @obj_tree_depth
end 

GO
