SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[measure].[CalculateLastNonNull]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [measure].[CalculateLastNonNull] AS' 
END
GO

-- EXEC measure.CalculateLastNonNull
ALTER   PROCEDURE [measure].[CalculateLastNonNull]
AS

BEGIN

	DECLARE @DummyData TABLE (
	  id INT NOT NULL PRIMARY KEY,
	  col1 INT NULL,
	  chk1 INT NULL
	);
 
	INSERT INTO @DummyData(id, col1, chk1) VALUES
	( 2, NULL, NULL),
	( 3,   15, 15),
	( 4,   10, 10),
	( 5,   -1, -1),
	( 7, NULL, -1),
	(11, NULL, -1),
	(13,  -12, -12),
	(17, NULL, -12),
	(19, NULL, -12),
	(23, 1759, 1759);

	;WITH cte_nonnull AS (
		SELECT 
			id
		,	col1
		,   chk1
		,	id_grp = MAX(CASE WHEN col1 IS NOT NULL THEN id END) OVER(ORDER BY id ROWS UNBOUNDED PRECEDING)
		FROM 
			@DummyData
	) 
	SELECT 
		nn.*
	,	val1 = COALESCE(nn.col1, nn2.col1)
	,   iscorrect = IIF(COALESCE(COALESCE(nn.col1, nn2.col1), 0) - COALESCE(nn.chk1, 0) = 0, 1, 0)
	FROM 
		cte_nonnull AS nn
	LEFT JOIN 
		cte_nonnull AS nn2
		ON nn2.id = nn.id_grp


	DECLARE @DummyDataWithGroup TABLE (
	  id INT NOT NULL,
	  grp1 INT NULL,
	  col1 INT NULL,
	  chk1 INT NULL
	);
 
	INSERT INTO @DummyDataWithGroup(id, col1, grp1, chk1) VALUES
	( 2, NULL,  1, NULL),
	( 3,   15,  1, 15),
	( 4,   10,  1, 10),
	( 5,   -1,  1, -1),
	( 7, NULL,  1, -1),
	(11, NULL,  1, -1),
	(13,  -12,  1, -12),
	(17, NULL,  1, -12),
	(19, NULL,  1, -12),
	(23, 1759,  1, 1759),
	( 2, NULL,  2, NULL),
	( 3, NULL,  2, NULL),
	( 4, NULL,  2, NULL),
	( 5,   20,  2, 20),
	( 7, NULL,  2, 20),
	(11, NULL,  2, 20),
	(13, NULL,  2, 20),
	(17, NULL,  2, 20),
	(19, 30,    2, 30),
	(23, 100,   2, 100),
	( 2, 953,   3, 953),
	( 3,  273,  3, 273),
	( 4,   50,  3, 50),
	( 5,   10,  3, 10),
	( 7, NULL,  3, 10),
	(11, 432,   3, 432),
	(13,  NULL, 3, 432),
	(17, -102,  3, -102),
	(19, NULL,  3, -102),
	(23, 1759,  3, 1759);


	;WITH cte_nonnull AS (
		SELECT 
			id
		,	col1
		,   grp1
		,	id_grp = MAX(CASE WHEN col1 IS NOT NULL THEN id END) OVER(PARTITION BY grp1 ORDER BY id ROWS UNBOUNDED PRECEDING)
		,   chk1		
		FROM 
			@DummyDataWithGroup
	) 
	SELECT 
		nn.*
	,	val1 = COALESCE(nn.col1, nn2.col1)
	,   iscorrect = IIF(COALESCE(COALESCE(nn.col1, nn2.col1), 0) - COALESCE(nn.chk1, 0) = 0, 1, 0)
	FROM 
		cte_nonnull AS nn
	LEFT JOIN 
		cte_nonnull AS nn2
		ON nn2.id		= nn.id_grp
		AND nn2.grp1	= nn.grp1


	;WITH C AS
	(
	SELECT id, col1, grp1,
	  MAX(CASE WHEN col1 IS NOT NULL THEN id END)
		OVER(PARTITION BY grp1 ORDER BY id
			 ROWS UNBOUNDED PRECEDING) AS grp
	FROM @DummyDataWithGroup
	)
	SELECT id, col1, grp1,
	MAX(col1) OVER(PARTITION BY grp, grp1
				   ORDER BY id
				   ROWS UNBOUNDED PRECEDING) AS lastval
	FROM C
	ORDER BY grp1;
END
GO
