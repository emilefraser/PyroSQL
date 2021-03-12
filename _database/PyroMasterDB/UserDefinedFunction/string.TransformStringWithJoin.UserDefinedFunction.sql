SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[TransformStringWithJoin]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =================================================
-- Join string Function
-- =================================================
-- Joins together the given array AS a string WITH
-- the @separator as separator:
/*
	SELECT string.[TransformStringWithJoin](dbo.array (''Waterp,Repr,Dispr,Al,L,R,Pr,'','',''),''oof,'')
*/
CREATE FUNCTION [string].[TransformStringWithJoin]
(
    @array XML,
    @separator VARCHAR(MAX)
)
RETURNS  VARCHAR(MAX)
AS BEGIN
	DECLARE @joined VARCHAR(MAX)
	--it is conceivable that someone might use a string here, to
    --make sure it is XML in our format 
      IF CHARINDEX(''<stringarray>'', CONVERT(VARCHAR(MAX), @array)) = 0
         SELECT   @array = ''<stringarray><element><seqno>1</seqno><item>''
                 + CONVERT(VARCHAR(MAX), @array)
                + ''</item></element></stringarray>''
--and now once again it is a simple select statement
SELECT @joined=COALESCE(@joined+@separator,'''') + item FROM
	( SELECT    x.y.value(''item[1]'', ''VARCHAR(200)'') AS [item],
                       x.y.value(''seqno[1]'', ''INT'') AS seqno
      FROM      @array.nodes(''//stringarray/element'') AS x ( y )
     ) f
 ORDER BY f.seqno
RETURN @joined
END
' 
END
GO
