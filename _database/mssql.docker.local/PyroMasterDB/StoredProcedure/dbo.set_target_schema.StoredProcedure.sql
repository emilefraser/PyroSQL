SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[set_target_schema]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[set_target_schema] AS' 
END
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB Sets the target schema for @full_obj_name 
*/
ALTER   PROCEDURE [dbo].[set_target_schema] 
	@full_obj_name as varchar(4000) ,
	@target_schema_name as varchar(4000), 
	@transfer_id as int = -1 
as 
begin 
	-- standard BETL header code... 
	set nocount on 
	declare   @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ? , ?', @proc_name , @full_obj_name, @target_schema_name
	-- END standard BETL header code... 
	declare @schema_id as int
	exec dbo.get_obj_id @target_schema_name , @schema_id output
	exec betl.dbo.setp 'target_schema_id'
		, @schema_id 
		, @full_obj_name
	-- standard BETL footer code... 
    footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? , ? (?)', @proc_name , @full_obj_name, @target_schema_name, @schema_id 
	-- END standard BETL footer code... 
end 











GO
