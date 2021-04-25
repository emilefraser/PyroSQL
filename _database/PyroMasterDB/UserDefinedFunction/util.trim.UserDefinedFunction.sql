SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[util].[trim]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-21 BvdB remove left and right spaces and double and single quotes. 
*/    
CREATE   FUNCTION [util].[trim]
(
	@s varchar(200)
	, @return_null bit = 1 
)
RETURNS varchar(200)
AS
BEGIN
	declare @result as varchar(max)= replace(replace(convert(varchar(200), ltrim(rtrim(@s))), ''"'', ''''), '''''''' , '''')
	if @return_null =0 
		return isnull(@result , '''') 
	return @result 
END











' 
END
GO
