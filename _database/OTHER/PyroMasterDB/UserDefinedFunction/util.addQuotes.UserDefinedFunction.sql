SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[util].[addQuotes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
*/
CREATE   FUNCTION [util].[addQuotes]
(
	@s varchar(7900) 
)
RETURNS varchar(8000) 
AS
BEGIN
	RETURN '''''''' + isnull(@s , '''') + '''''''' 
END











' 
END
GO
