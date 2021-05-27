SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GenerateNumberTable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[GenerateNumberTable] AS' 
END
GO
/*
	EXEC dbo.[GenerateNumberTable]
					@low	= 0
				,	@high	= 10000
*/
ALTER    PROCEDURE [dbo].[GenerateNumberTable]
	@low	INT		= 0
,	@high	INT		= 10000
AS
BEGIN

	DROP TABLE IF EXISTS dbo.Number

	CREATE TABLE dbo.Number (
		n BIGINT
	)

	;WITH e1(n) AS (
		SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
		SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
		SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
		SELECT 1 -- 10 
	), main AS (
		SELECT e1.n
		FROM e1
		CROSS JOIN (SELECT 1 FROM e1) AS e2(n) -- 100 (10^2)
		CROSS JOIN (SELECT 1 FROM e1) AS e3(n) -- 1000 (10^3)
		CROSS JOIN (SELECT 1 FROM e1) AS e4(n) -- 10000 (10^4)
		CROSS JOIN (SELECT 1 FROM e1) AS e5(n) -- 100000 (10^5) 
		CROSS JOIN (SELECT 1 FROM e1) AS e6(n) -- 1000000 (10^6) 
        --CROSS JOIN (SELECT 1 FROM e1) AS e6(n) -- 10000000 (10^7) 
        --CROSS JOIN (SELECT 1 FROM e1) AS e6(n) -- 100000000 (10^8) 
        --CROSS JOIN (SELECT 1 FROM e1) AS e6(n) -- 1000000000 (10^9) 
	)
	INSERT INTO 
		dbo.[Number](n)
	SELECT 
		n = ROW_NUMBER() OVER (ORDER BY n)  - 1
	FROM 
		main 
	WHERE 
		n BETWEEN @low and @high;

	CREATE UNIQUE CLUSTERED INDEX 
		ucix_Number_n
	ON 
		dbo.Number(n) 
	WITH 
		(DATA_COMPRESSION = PAGE);

END
GO
