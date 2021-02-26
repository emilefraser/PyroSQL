SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[array].[GetArrayItem]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	select dbo.item(dbo.array(''Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday'', ''|''),4)

	Select dbo.item(@Months,10)
*/
CREATE FUNCTION [array].[GetArrayItem] (
@TheArray xml, @index int	

)
RETURNS varchar(max)
AS
BEGIN
return (select element.value(''item[1]'', ''VARCHAR(max)'')
    FROM @TheArray.nodes(''/stringarray/element[position()=sql:variable("@index")]'') array(element))

END
' 
END
GO
