SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[refresh]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[refresh] AS' 
END
GO

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-02 BvdB This proc will refresh the meta data of servers, databases, schemas, tables, views and stored procedures
exec dbo.refresh '[LOCALHOST].[AdventureWorks2014]'
exec dbo.refresh 'LOCALHOST.My_Staging.NF.Center'
exec dbo.refresh @full_obj_name='SSAS01_TAB_CUSTOMER', @obj_tree_depth=2
*/
ALTER   PROCEDURE [dbo].[refresh]
    @full_obj_name as varchar(255) 
	, @obj_tree_depth as int = 0 -- 0->only refresh full_obj_name, if 1 -> refresh childs under this object as well. 
						---if 2 then for each child also refresh it's childs.. e.g. 
						-- dbo.refresh 'LOCALHOST', 0 will only create a record in dbo._Object for the server BETL
						-- dbo.refresh 'LOCALHOST', 1 will also create a record for all db's in this server (e.g. BETL). 
						-- dbo.refresh 'LOCALHOST', 2 will create records in object for each table and view on this server in every database.
						-- dbo.refresh 'LOCALHOST', 3 will create records in object for each table and view on this server in every database and
						-- also fill his._Column with all columns meta data for each table and view. 
	, @scope as varchar(255) = null
	, @transfer_id as int = -1
AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare   @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ? , scope ?, depth ?', @proc_name , @full_obj_name, @scope, @obj_tree_depth
	-- END standard BETL header code... 
	declare @obj_id as int
	exec dbo.get_obj_id @full_obj_name, @obj_id output, @scope, @obj_tree_depth, @transfer_id
	if @obj_id is null or @obj_id < 0 
	begin
		exec dbo.log @transfer_id, 'step', 'Object ? not found in scope ? .', @full_obj_name, @scope 
		goto footer
	end
	else
	begin 
--		exec dbo.log @transfer_id, 'step', 'obj_id resolved: ?, scope ? ', @obj_id , @scope
		exec dbo.refresh_obj_id @obj_id, @obj_tree_depth, @transfer_id
		exec process_stack @transfer_id 
	end
	
	-- standard BETL footer code... 
    footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? ? ?', @proc_name , @full_obj_name, @obj_tree_depth, @transfer_id
	-- END standard BETL footer code... 
END












GO
