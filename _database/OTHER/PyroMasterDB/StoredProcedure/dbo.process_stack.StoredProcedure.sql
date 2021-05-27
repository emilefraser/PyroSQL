SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[process_stack]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[process_stack] AS' 
END
GO
	  
	
/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2018-04-23 BvdB
exec dbo.process_stack
*/
ALTER   PROCEDURE [dbo].[process_stack]
	@transfer_id as int = -1 
as
begin 
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'Header', '? ', @proc_name 
	-- END standard BETL header code... 

	declare @stack_id as int
	select @stack_id = max(stack_id) from dbo.Stack
	
	exec dbo.log @transfer_id, 'VAR', 'stack id ?', @stack_id 
	while @stack_id is not null
	begin 
		exec dbo.log @transfer_id, 'Step', 'processing stack id ?', @stack_id 
		exec dbo.process_stack_id @stack_id 
		select @stack_id = min(stack_id) from dbo.Stack
	end 


	footer:
	
	exec dbo.log @transfer_id, 'Footer', '? ', @proc_name 
end

 












GO
