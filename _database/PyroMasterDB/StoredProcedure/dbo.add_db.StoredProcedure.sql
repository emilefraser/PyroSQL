SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[add_db]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[add_db] AS' 
END
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-09-24 BvdB This will add @db_name to the Betl meta data repository and places a trigger 
-- to capture all ddl changes so that the structure of @db_name is synched to betl. 

*/
ALTER   PROCEDURE [dbo].[add_db]
	@db_name sysname
	, @transfer_id as int = -1 -- use this for logging. 
as 
begin 
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id =@transfer_id, @log_type ='header', @msg ='? ', @i1 =@proc_name , @i2 =@db_name
	-- END standard BETL header code... 

	-- first add @db_name to the repositoru
	exec dbo.refresh @db_name

	-- then place a trigger
    exec exec_template 'trig_betl_meta_data',  @db_name



  -- START standard BETL footer code... 
  footer:
 
 	exec dbo.log @transfer_id =@transfer_id, @log_type ='footer', @msg ='? ', @i1 =@proc_name , @i2 =@db_name
  -- END standard BETL footer code... 
end

GO
