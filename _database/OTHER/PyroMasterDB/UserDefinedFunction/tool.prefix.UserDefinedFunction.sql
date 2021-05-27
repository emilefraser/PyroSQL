SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[prefix]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB returns true if @s ends with @suffix
select dbo.prefix(''gfjhaaaaa_aap'', 4) 
*/
CREATE   FUNCTION [tool].[prefix]
(
                @s as varchar(255)
                , @len_suffix as int
                --, @suffix as varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
                declare @n as int=len(@s) 
                                                --, @n_suffix as int = len(@suffix)
                declare @result as bit = 0 
                return SUBSTRING(@s, 1, @n-@len_suffix) 
END












' 
END
GO
