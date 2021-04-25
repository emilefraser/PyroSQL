SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[guess_prefix]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- SELECT dbo.guess_prefix(''par_relatie_id'')
-- SELECT dbo.guess_prefix(''relatie_id'')
*/
CREATE   FUNCTION [dbo].[guess_prefix]( @column_name VARCHAR(255) ) 
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @res INT 
	,		@pos INT 
	, @prefix VARCHAR(64)=''''
	SELECT @res = MAX(column_id) -- for now take the last known column if >1 
	FROM dbo.Col c
	INNER JOIN dbo.[Obj] o ON o.[obj_id] = c.[obj_id]
	WHERE column_name = @column_name
	AND column_type_id = 100 -- nat_pkey
	AND util.prefix_first_underscore([obj_name]) =''hub'' -- foreign column should be a hub
	/* 
	declare @column_name VARCHAR(255)  = ''par_relatie_id''
	,		@pos INT 
	 SELECT CHARINDEX(''_'', @column_name )
	 SET @pos = CHARINDEX(''_'', @column_name)
	 select SUBSTRING(@column_name, @pos+1, LEN(@column_name) - @pos)
	 */
	SET @pos = CHARINDEX(''_'', @column_name)
	IF @res IS NULL AND @pos IS NOT NULL  
	BEGIN 
		DECLARE @remove_prefix AS VARCHAR(255) = SUBSTRING(@column_name, @pos+1, LEN(@column_name) - @pos)
		SET @prefix = SUBSTRING(@column_name, 1, @pos-1)
		SELECT @res = MAX(column_id) -- for now take the last known column if >1 
		FROM dbo.Col c
		INNER JOIN dbo.[Obj] o ON o.[obj_id] = c.[obj_id]
		WHERE column_name = @remove_prefix
		AND column_type_id = 100 -- nat_pkey
		AND util.prefix_first_underscore([obj_name]) =''hub''
	end
	-- Return the result of the function
	RETURN @prefix
END











' 
END
GO
