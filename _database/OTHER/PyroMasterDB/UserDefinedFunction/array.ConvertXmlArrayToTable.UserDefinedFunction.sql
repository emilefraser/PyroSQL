SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[array].[ConvertXmlArrayToTable]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- ================================================
-- creates a table from an array created by array.ConvertXmlArrayToTable
-- ================================================
/*
	Select * from array.ConvertXmlArrayToTable(array.ConvertArrayToXml(''Tiger tiger, my mistake|I thought that you were william blake'',''|''))
*/
CREATE FUNCTION [array].[ConvertXmlArrayToTable] (	
	@TheArray xml 
)
RETURNS TABLE 
AS
RETURN
(
	SELECT
		 x.y.value(''seqno[1]'', ''INT'') AS [SequenceNumber]
	,	 x.y.value(''item[1]'', ''VARCHAR(200)'') AS [Item]
	FROM
		@TheArray.nodes(''//stringarray/element'') AS x (y)
)
' 
END
GO
