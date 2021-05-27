SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[schema_name]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-02 BvdB return schema name of this full object name 
--  e.g. My_PC.AdventureWorks2014.Person.Sales ->My_PC.AdventureWorks2014.Person
select dbo.schema(''My_PC.AdventureWorks2014.Person.Sales'') --> points to table 
*/
CREATE   FUNCTION [dbo].[schema_name]( @fullObj_name varchar(255) , @scope varchar(255) ) 
RETURNS varchar(255) 
AS
BEGIN
	declare @schema_id as int 
		, @res as varchar(255) =''''
		select @schema_id = dbo.schema_id(@fullObj_name, @scope ) 

	select @res = [full_obj_name] --isnull(''[''+ srv + ''].'', '''') +  isnull(''[''+db +''].'','''') + ''[''+ [schema] + '']''
	from dbo.obj_ext 
	where [obj_id] = @schema_id
	return @res 
END











' 
END
GO
