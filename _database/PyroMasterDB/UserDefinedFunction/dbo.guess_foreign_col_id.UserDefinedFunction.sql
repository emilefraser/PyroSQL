SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[guess_foreign_col_id]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'	  
	  
  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB gueses foreign column. Currently based on datavault hub natural keys
-- 2018-05-14 BvdB give prevalence to columns in same schema (same parent object). 
SELECT * 
from dbo.col_ext 
where column_id = dbo.guess_foreign_col_id(''aanstelling_id'', 346) 
select * from dbo.obj_ext
select dbo.guess_foreign_col_id(''datum'', 3367 )
select dbo.guess_foreign_col_id(''top_relatie_id'', 12212 )
select dbo.guess_foreign_col_id(''werknemer_id'', 13473 )
select dbo.guess_foreign_col_id(''top_relatie_id'', 13484 )
*/ 
CREATE   FUNCTION [dbo].[guess_foreign_col_id]( @column_name VARCHAR(255) , @obj_id int=0 ) 
RETURNS int
AS
BEGIN
	DECLARE @nat_keys AS TABLE ( 
		column_id  int 
		, column_name  varchar(255) 
		, obj_name  varchar(255) 
		, trg_parent_id int 
		, src_parent_id int 
		, same_parent bit
		, diff_col_obj varchar(255) 
		, seq_nr int 
	) 
	;
	with foreign_cols as ( 
		SELECT c.column_id, c.column_name, o.[obj_name], o.parent_id trg_parent_id , o_src.parent_id  src_parent_id-- , COUNT(*) cnt
		, case when o.parent_id =o_src.parent_id  then 1 else 0 end same_parent
		, replace(o.[obj_name],  replace(c.column_name, ''_id'', ''''), '''') diff_col_obj
		FROM dbo.Col c
		INNER JOIN dbo.Obj o ON c.obj_id = o.obj_id
		left join dbo.Obj o_src ON o_src.obj_id =  @obj_id 
	--	INNER JOIN dbo.Col c2 ON c.obj_id = c2.obj_id -- AND c2.column_id <> c.column_id 
		WHERE 
			c.column_type_id = 100 -- nat_pkey 
			and o.delete_dt is null 
			and o_src.delete_dt is null 
			--and c.column_name=@column_name 
			-- AND c2.column_type_id = 100 
			-- AND c2.column_name NOT IN ( ''etl_data_source'', ''etl_load_dt'') 
			and o.obj_name like ''hub_%''
	) 
	INSERT INTO @nat_keys 
	select * 
	, row_number() over (partition by column_name order by same_parent desc,
	len (diff_col_obj)  asc 
	 ) seq_nr -- , COUNT(*) cnt
	 from foreign_cols 
	DECLARE @res INT 
	,		@pos INT 
	SELECT @res = column_id -- for now take the last known column if >1 
	FROM @nat_keys 
	WHERE column_name = @column_name
	AND util.prefix_first_underscore([obj_name]) =''hub'' -- foreign column should be a hub
	and seq_nr = 1 
	SET @pos = CHARINDEX(''_'', @column_name)
	IF @res IS NULL AND @pos IS NOT NULL  
	BEGIN 
		DECLARE @remove_prefix AS VARCHAR(255) = SUBSTRING(@column_name, @pos+1, LEN(@column_name) - @pos)
		SELECT @res = 
		( 
		select top 1 column_id -- for now take the last known column if >1 
		FROM @nat_keys 
		WHERE column_name = @remove_prefix
		AND util.prefix_first_underscore([obj_name]) =''hub'' -- foreign column should be a hub
		order by len(obj_name) asc
		) 	end
	-- Return the result of the function

	RETURN @res 
END











' 
END
GO
