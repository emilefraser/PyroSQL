SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[reset]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[reset] AS' 
END
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-21 BvdB reset (user bound) properties
exec dbo.reset 
*/
ALTER   PROCEDURE [dbo].[reset]  
	@transfer_id int = -1 
	as
begin 
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ', @proc_name 
	-- END standard BETL header code... 
--	exec dbo.log @transfer_id, 'INFO' , 'BEFORE reset'
--	exec dbo.my_info @transfer_id
	exec dbo.setp 'exec_sql', 1
	exec dbo.setp 'LOG_LEVEL', 'INFO'
	exec dbo.setp 'nesting' , 0
--	exec dbo.log @transfer_id, 'INFO', 'AFTER reset'
	--exec dbo.my_info @transfer_id
	truncate table dbo.Stack

	footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ', @proc_name 
	-- END standard BETL footer code... 
end












GO
