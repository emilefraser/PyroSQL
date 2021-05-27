SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[guess_entity_name]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB try to guess default entity name. when incorrect, user can change it
SELECT dbo.[guess_entity_name](''par_relatie_id'')
SELECT dbo.[guess_entity_name](''relatie_id'')
SELECT dbo.[guess_entity_name](''child_relatie_id'')
*/
CREATE  FUNCTION [dbo].[guess_entity_name]( @column_name VARCHAR(255), @obj_id int ) 
RETURNS VARCHAR(255) 
AS
BEGIN
	DECLARE @res VARCHAR(255) 
	,	@foreignCol_id int
	
	SELECT @foreignCol_id  = foreign_column_id
	from dbo.Col_hist
	where obj_id = @obj_id and column_name= @column_name
	if @foreignCol_id  is null 
		SELECT @foreignCol_id  = dbo.guess_foreign_col_id( @column_name, @obj_id ) 
	SELECT @res = [obj_name]
	FROM dbo.Col c
	INNER JOIN [dbo].[Obj] obj ON obj.obj_id = c.obj_id
	WHERE column_id = @foreignCol_id  
	RETURN @res 
END











' 
END
GO
