SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[DifferenceBetweenWords]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
{{##
	(WrittenBy)		Emile Fraser
	(CreatedDate)	2021-01-22
	(ModifiedDate)	2021-01-22
	(Description)	Creates a Dynamic SQL Insert Statement

	(Usage)	
					SELECT * FROM  [string].[DifferenceBetweenWords] (@@First, @@Second, @Difference)
	(/Usage)
##}}
*/
CREATE   FUNCTION [string].[DifferenceBetweenWords] (
	 @First		VarChar(256)
	,@Second	VarChar(256)
	,@Difference	TinyInt	= NULL
) RETURNS TABLE AS RETURN	-- SELECT * FROM string.fnWordDifference(''012345679012'',''012456789012'',3)
WITH Shift(Position,[Left],[Right],[Difference]) AS (
	SELECT	 0
		,@First
		,@Second
		,0
	WHERE	@Difference >= 0 OR @Difference IS NULL
UNION ALL
	SELECT	 Position + 1
		,[Left]
		,[Right]
		,[Difference]
	FROM	Shift
	WHERE	    Position <= Len([Left] )
		AND Position <= Len([Right])
		AND SubString([Left] ,Position + 1,1)
		  = SubString([Right],Position + 1,1)
UNION ALL
	SELECT	 Position
		,Convert(VarChar(256),Stuff([Left],Position + 1,1,''''))
		,[Right]
		,[Difference] + 1
	FROM	Shift
	WHERE	    Position <= Len([Left] )
		AND Position <= Len([Right])
		AND SubString([Left]  + '' '',Position + 1,1)
		 != SubString([Right] + '' '',Position + 1,1)
		AND([Difference] < @Difference OR @Difference IS NULL)
UNION ALL
	SELECT	 Position
		,[Left]
		,Convert(VarChar(256),Stuff([Right],Position + 1,1,''''))
		,[Difference] + 1
	FROM	Shift
	WHERE	    Position <= Len([Left] )
		AND Position <= Len([Right])
		AND SubString([Left] + '' '',Position + 1,1)
		 != SubString([Right]+ '' '',Position + 1,1)
		AND([Difference] < @Difference OR @Difference IS NULL)
)	SELECT	Top(1)
		 @First		AS [First]
		,@Second	AS [Second]
		,[Left]		AS [Root]
		,[Difference]
	FROM	Shift
	WHERE	[Left] = [Right] AND Position = Len([Left])
	ORDER BY [Difference]
' 
END
GO
