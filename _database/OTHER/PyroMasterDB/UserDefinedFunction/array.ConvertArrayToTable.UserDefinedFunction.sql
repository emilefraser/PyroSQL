SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[array].[ConvertArrayToTable]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- ================================================
-- creates a table from an array created by dbo.array
-- ================================================
/*
	Select * from array.ConvertArrayToTable(dbo.array(''Tiger tiger, my mistake|I thought that you were william blake'',''|''))

	--and you can get the number of elements in an array
SELECT   dbo.array(''one,two,three,four,five,six,seven,eight,nine,ten'',
                           '','').query(''count(for $el in /stringarray/element
return $el/item)'') as ListCount
--Result: 10

--or just an XML list of all the items.
SELECT   dbo.array(''one,two,three,four,five,six,seven,eight,nine,ten'','',''
 ).query(''for $i in /stringarray/element return (/stringarray/element/item)[$i]'') 
/* now getting an element from an array is simple once you know the XML magic spell. We prefer to wrap it in a function as XML is rather unforgiving */
*/
CREATE   FUNCTION [array].[ConvertArrayToTable] (	
@TheArray xml 
)
RETURNS TABLE 
AS
RETURN 
(
SELECT   x.y.value(''seqno[1]'', ''INT'') AS [seqno],
		 x.y.value(''item[1]'', ''VARCHAR(200)'') AS [item]
FROM     @TheArray.nodes(''//stringarray/element'') AS x (y)
)
' 
END
GO
