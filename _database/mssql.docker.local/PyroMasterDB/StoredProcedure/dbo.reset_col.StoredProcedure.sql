SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[reset_col]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[reset_col] AS' 
END
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-21 BvdB reset column meta data
-----------------------------------------------------------------------------------------------
exec dbo.reset_col 1811
*/
ALTER   PROCEDURE [dbo].[reset_col]  
	@column_id as int 
	, @transfer_id int =0
	as
begin 
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ', @proc_name 
	-- END standard BETL header code... 
	exec dbo.log @transfer_id, 'INFO' , 'BEFORE reset'
	select * from dbo.col_ext where column_id = @column_id 
	
	set identity_insert [dbo].[Col_hist] on 
	INSERT INTO [dbo].[Col_hist]
           (column_id 
		   , [eff_dt]
           ,[obj_id]
           ,[column_name]
           ,[prefix]
           ,[entity_name]
           ,[foreign_column_id]
           ,[ordinal_position]
           ,[is_nullable]
           ,[data_type]
           ,[max_len]
           ,[numeric_precision]
           ,[numeric_scale]
           ,[column_type_id]
           ,[src_column_id]
           ,[delete_dt]
           ,[chksum]
           ,[transfer_id]
           ,[part_of_unique_index])
	SELECT [column_id]
      ,getdate()
      ,[obj_id]
      ,[column_name]
      ,[prefix]
      ,null [entity_name]
      ,null [foreign_column_id]
      ,[ordinal_position]
      ,[is_nullable]
      ,[data_type]
      ,[max_len]
      ,[numeric_precision]
      ,[numeric_scale]
      ,[column_type_id]
      ,[src_column_id]
      ,[delete_dt]
      ,0 [chksum]
      ,[transfer_id]
      ,[part_of_unique_index]
  FROM [betl].[dbo].[Col]
	where column_id = @column_id
	set identity_insert [dbo].[Col_hist] off
	exec dbo.log @transfer_id, 'INFO', 'AFTER reset'
	declare @obj_id as int
	select @obj_id = obj_id from dbo.col_ext where column_id = @column_id
	exec dbo.refresh_obj_id @obj_id
	select * from dbo.col_ext where column_id = @column_id 
	footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ', @proc_name 
	-- END standard BETL footer code... 
end











GO
