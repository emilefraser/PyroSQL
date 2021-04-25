SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[content_type_name]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB get name by id. 
select dbo.[content_type_name](300) 
*/
CREATE   FUNCTION [dbo].[content_type_name]
(
	@content_type_id int
)
RETURNS varchar(255) 
AS
BEGIN
	declare @content_type_name as varchar(255) 
	select @content_type_name = [content_type_name] from dbo.Content_type where content_type_id = @content_type_id 
	return @content_type_name + '' ('' + convert(varchar(10), @content_type_id ) + '')''
END











' 
END
GO
