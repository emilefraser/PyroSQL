SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_cols]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB returns a table with all column meta data 
-- Unfortunately we have to re-define the columTable type here... 
-- see http://stackoverflow.com/questions/2501324/can-t-sql-function-return-user-defined-table-type
select * from dbo.get_cols(32)
exec dbo.info
*/
CREATE   FUNCTION [dbo].[get_cols]
(
	@obj_id int
)
RETURNS @cols TABLE(
	[ordinal_position] [int] NOT NULL PRIMARY KEY,
	[column_name] [varchar](255) NULL,
	[column_value] [varchar](255) NULL,
	[data_type] [varchar](255) NULL,
	[max_len] [int] NULL,
	[column_type_id] [int] NULL,
	[is_nullable] [bit] NULL,
	[prefix] [varchar](64) NULL,
	[entity_name] [varchar](64) NULL,
	[foreignCol_name] [varchar](64) NULL,
	[foreign_sur_pkey] int NULL,
	[numeric_precision] [int] NULL,
	[numeric_scale] [int] NULL,
	part_of_unique_index BIT NULL,
	[identity] [bit] NULL,
	[src_mapping] varchar(255) null
)  as
begin 
	--SET IDENTITY_INSERT @cols ON 
	insert into @cols(
		ordinal_position
		, column_name
		, column_value
		, data_type 
		, max_len
		, [column_type_id] 
		, is_nullable
		, [prefix] 
		, [entity_name]
		, [foreignCol_name] 
		, [foreign_sur_pkey] 
		  ,[numeric_precision]
		  ,[numeric_scale]
		  ,part_of_unique_index 
		  ,[identity]
		) 
		select 
			ordinal_position
			, column_name
			, null column_value
			, data_type 
			, max_len
			, [column_type_id] 
			, is_nullable
			, prefix
			, [entity_name]
			, [foreign_column_name]
			, [foreign_sur_pkey] 
			  ,[numeric_precision]
			  ,[numeric_scale]
			  ,part_of_unique_index 
			  ,null [identity]
		from dbo.Col_ext
		where [obj_id] = @obj_id 
	--SET IDENTITY_INSERT @cols OFF
	RETURN
end

--SELECT * from vwCol











' 
END
GO
