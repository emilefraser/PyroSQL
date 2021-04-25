SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[util].[udf_max]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2014-02-25 BvdB returns the maximum of two ordinal types (e.g. int or date). 
select util.udf_max(1,2)
select util.udf_max(null,2)
select util.udf_max(2,null)
select util.udf_max(2,3)
*/
CREATE   FUNCTION [util].[udf_max]
(
 @a sql_variant,
 @b sql_variant
 
)
RETURNS sql_variant
AS
BEGIN
 if @a is null or @b >= @a
  return @b
 else
  if @b is null or @a > @b
   return @a
  return @a
END











' 
END
GO
