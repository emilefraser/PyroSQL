SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[SplitStringWithDelimeterAndChunk]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
--/*
--	Written by: Emile Fraser
--	Date		:	2020-05-20
--	Function	:	Splits a string based on a delimeter and retuns a certain chunk based on the ChunkNumber
--*/



--  SELECT * FROM string.[SplitStringWithDelimeterAndChunk](''HUB_Andreas, LINK_Emile, SAT_Andreas, LINK_Ansa'', '','',0)

CREATE     FUNCTION [string].[SplitStringWithDelimeterAndChunk] (
	@StringValue	NVARCHAR(MAX)
,   @Delimiter		NVARCHAR(30)
,	@ChunkNumber	SMALLINT = NULL
)
RETURNS TABLE
RETURN

	 WITH E1(N) AS ( 
		SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
		UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
		UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
	), E2(N) AS (
		SELECT 1 FROM E1 a, E1 b
	), E4(N) AS (
		SELECT 1 FROM E2 a, E2 b
	), E8(N) AS (
		SELECT 1 FROM E4 a, E2 b
	), cteTally(N) AS (
		SELECT 0 
			UNION ALL 
		SELECT 
			TOP (DATALENGTH(ISNULL(@StringValue,1))) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E8)
		,	cteStart(ChunkStart, ChunkNumber) AS (
				SELECT 
					t.N+1
				,	ROW_NUMBER() OVER (ORDER BY t.N+1)
				FROM 
					cteTally t
                WHERE 
					SUBSTRING(@StringValue, t.N, 1) = @Delimiter 
				OR 
					t.N = 0
			)
	SELECT 
		Item = LTRIM(RTRIM(SUBSTRING(@StringValue, s.ChunkStart, ISNULL(NULLIF(CHARINDEX(@Delimiter, @StringValue, s.ChunkStart), 0) - s.ChunkStart, 8000))))
--	,	ChunkStart
--	,	ChunkNumber
	FROM 
		cteStart s
	WHERE
		ChunkNumber BETWEEN @ChunkNumber AND IIF(COALESCE(@ChunkNumber, 0) <> 0, @ChunkNumber, 9999)
' 
END
GO
