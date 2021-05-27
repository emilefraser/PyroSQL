SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[recurse].[ReplaceCteWithOnlyChangedOutput]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [recurse].[ReplaceCteWithOnlyChangedOutput] AS' 
END
GO
-- CREATE SCHEMA recurse
ALTER PROCEDURE [recurse].[ReplaceCteWithOnlyChangedOutput]
AS
BEGIN


DROP TABLE IF EXISTS ##T
CREATE TABLE ##T (
    [level] INT IDENTITY(0,1),
    old NVARCHAR(128),
    new NVARCHAR(128)
)

DROP TABLE IF EXISTS ##Data
CREATE TABLE ##Data (
	[OriginalString] NVARCHAR(128)
)

INSERT INTO ##Data ([OriginalString]) VALUES ('banana')
INSERT INTO ##Data ([OriginalString]) VALUES ('apples')

INSERT INTO ##T VALUES('p', 'Q')
INSERT INTO ##T VALUES('s', 'Z')
INSERT INTO ##T VALUES('a', 'G')


;WITH CTE ([OriginalString], [StringPreReplacement], [StringOld], [StringNew],[StringPostReplacement], [level]) AS
(
    SELECT [OriginalString], [OriginalString], [OriginalString], [OriginalString], [OriginalString], 0
    FROM	##Data
	
    UNION ALL
	
    SELECT 
		[OriginalString]		= CTE.[OriginalString]
	,	[StringPreReplacement]	= CTE.[StringPostReplacement]
	,	[StringOld]				= rep.old
	,	[StringNew]				= rep.new
	,   [StringPostReplacement]	= CONVERT(NVARCHAR(128), REPLACE(CTE.[OriginalString], rep.old, rep.new))
    ,	[level]					= CTE.level + 1
	--,	[IsEqual]				= IIF(
	--									CTE.[OriginalString] = CONVERT(NVARCHAR(128), REPLACE(CTE.[OriginalString], rep.old, rep.new))
	--								OR
	--									rep.old = rep.new
	--									, 1
	--									, 0
	--								)
    FROM	
		CTE
    INNER JOIN 
		##T AS rep
		ON rep.[level] = CTE.[level]
)
SELECT 
	[OriginalString]
,	[StringPreReplacement]
,	[StringOld]
,	[StringNew]
,	[StringPostReplacement]
,	[level]
--,	IsInclude = IIF([OriginalString] != [StringPostReplacement], 1, 0)
FROM 
	CTE
WHERE
	IIF([OriginalString] != [StringPostReplacement], 1, 0) = 1
--AND
--	IIF([OriginalString] = [StringPostReplacement], 1, 0) = 1

END
GO
