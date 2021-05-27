SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[udf_min3]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'	  

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB returns min value
*/
CREATE   FUNCTION [tool].[udf_min3]
(
 @a sql_variant,
 @b sql_variant,
 @c sql_variant
) 
RETURNS sql_variant
as 
begin
	return util.udf_min(util.udf_min(@a, @b) , @c) 
end












' 
END
GO
