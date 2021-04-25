SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[onError]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[onError] AS' 
END
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-07-11 BvdB this is used in ssis event handling for maintaining log administration/ error handling. 
*/
ALTER   PROCEDURE [dbo].[onError]
	@transfer_id int 
	, @status as varchar(255) output
	, @source_name as varchar(255) =null
	, @error_desc as varchar(1000) =null
	, @error_code as varchar(255) =null
as 
begin 
	set nocount on 
	declare 
		@msg as varchar(2000) =''
	set @msg = '['+ isnull(@source_name,'') + '] ' + isnull(@error_desc ,'') + '('+ isnull(@error_code,'') + ')'
	set @status = 'Error'
	exec betl.dbo.log_error @transfer_id, @msg, 9 -- do not throw exception. -> else setting status fails
--	exec betl.dbo.log @transfer_id, 'ERROR', @msg
	footer: 
	
end












GO
