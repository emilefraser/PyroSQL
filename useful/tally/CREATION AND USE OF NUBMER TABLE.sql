--CREATE SCHEMA VALIDATE 
--GO

--CREATE OR ALTER PROCEDURE VALIDATE.sp_Identity_stock_trail
--AS 

--BEGIN

    DECLARE @range_start  BIGINT = (SELECT MIN(LogID) AS Identity_Min FROM dbo.stock_trail)
    DECLARE @range_end BIGINT = (SELECT MAX(LogID) AS Idenitity_Max FROM dbo.stock_trail)
    DECLARE @count_expected BIGINT = (SELECT MAX(LogID) - MIN(LogID) AS Identity_Range FROM dbo.stock_trail)
    DECLARE @count_actual BIGINT = (SELECT COUNT(1) AS Identity_Count FROM dbo.stock_trail)
    DECLARE @distinctcount_actual BIGINT = (SELECT COUNT(DISTINCT LogID) AS Identity_DistinctCount FROM dbo.stock_trail)

   DROP TABLE IF EXISTS ##Numbers

   CREATE TABLE ##Numbers (n INT)

--SET STATISTICS TIME ON
--SET STATISTICS IO ON

;WITH e1(n) AS
	(
		SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
		SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
		SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
		SELECT 1 -- 10 
	),
	main AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY e1.n) AS rn
		FROM e1
		, (SELECT 1 FROM e1) AS e2(n) -- 100 (10^2)
		, (SELECT 1 FROM e1) AS e3(n) -- 1000 (10^3)
		, (SELECT 1 FROM e1) AS e4(n) -- 10000 (10^4)
		, (SELECT 1 FROM e1) AS e5(n) -- 100000 (10^5) 
		, (SELECT 1 FROM e1) AS e6(n) -- 1000000 (10^6) 
        , (SELECT 1 FROM e1) AS e7(n) -- 10000000 (10^7) 
        , (SELECT 1 FROM e1) AS e8(n) -- 100000000 (10^8) 
--      , (SELECT 1 FROM e1) AS e9(n) -- 1000000000 (10^9) 
	)
    INSERT INTO ##Numbers (n)
	SELECT rn
    FROM main 
    WHERE rn BETWEEN @range_start and @range_end
    ORDER BY rn


    SELECT * FROM ##Numbers as T
    WHERE NOT EXISTS 
    (
        SELECT 1
        FROM dbo.stock_trail as ST
        WHERE ST.LogID = T.n
    )