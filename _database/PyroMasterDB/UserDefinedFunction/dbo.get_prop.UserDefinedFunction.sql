SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_prop]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB wrapper for getting property value
select  dbo.get_prop(''use_linked_server'' , ''My_PC'')
*/
CREATE   FUNCTION [dbo].[get_prop] (
	@prop varchar(255)
	, @fullObj_name varchar(255) 
	, @scope as varchar(255) = null 
	)
returns varchar(255) 
as 
begin
	declare @obj_id as int 
	Set @obj_id = dbo.obj_id(@fullObj_name, @scope) 
	return dbo.get_prop_obj_id(@prop, @obj_id) 
end












' 
END
GO
