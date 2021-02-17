-------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
-- Unit test --
-- Split has been problematic enough for me I thought these tests important.

SET NOCOUNT ON

DECLARE @TESTS TABLE (
	[cnt] int,
	[txt] nvarchar(max),
	[delim] nvarchar(1000),
	[sum_len] int
)
DECLARE @RESULTS TABLE (
	[id] int identity(1,1),
	[msg] varchar(255) null,
	[pass_fail] AS (
		CASE 
			WHEN (ISNULL([expected_count],0) = ISNULL([actual_count],0) AND ISNULL([expected_sum_len],0) = ISNULL([actual_sum_len],0)) THEN 'PASS' 
			ELSE 'FAIL' 
			END
	),
	[runtime] int null,
	[expected_count] int null,
	[actual_count] int null,
	[expected_sum_len] int null,
	[actual_sum_len] int null,
	[delim] nvarchar(1000),
	[txt] nvarchar(max)
)

DECLARE @BigText nvarchar(max)
DECLARE @BigTextItemCount int
DECLARE @BigTextSumHash int

-- Alternative large volume tests, set to 10 for quick, set to 100K for a real workout
--SELECT @BigTextItemCount = 10, @BigTextSumHash = 11
SELECT @BigTextItemCount = 10000, @BigTextSumHash = 38894
--SELECT @BigTextItemCount = 100000, @BigTextSumHash = 488895

-- Create the hash of big text. I know this code is somewhat ugly, but it creates the large text in 
-- about 1 second, as opposed to an itterative concat that took 14 minutes... :-)
;with cte as (
	select 9 as [i]
	union all
	select [i] - 1 FROM cte where [i] > 0
),
crs as (
	SELECT ROW_NUMBER() OVER(ORDER BY c1.[i]) as [rn]
	FROM cte c1		  -- 10
	CROSS JOIN cte c2 -- 100
	CROSS JOIN cte c3 -- 1000
	CROSS JOIN cte c4 -- 10000
	CROSS JOIN cte c5 -- 100000
)
SELECT @BigText =
	(
		(
		SELECT '#' + CAST([rn] as nvarchar(32))
		FROM crs
		WHERE [rn] <= @BigTextItemCount
		FOR XML PATH('') , TYPE
		).value('.', 'nvarchar(max)')
	)

-- Most of the tests go here --
INSERT INTO @TESTS (cnt, sum_len, txt, delim)
	-- Basic 1-char Delim Tests
			  SELECT 0, 0, '', ','
	UNION ALL SELECT 0, 0, null, ','
	UNION ALL SELECT 0, 0, 'a', null
	UNION ALL SELECT 0, 0, 'a', ''
	UNION ALL SELECT 3, 3, '1,2,3', ','
	UNION ALL SELECT 3, 3, ',1,2,3', ','
	UNION ALL SELECT 3, 3, '1,2,3,', ','
	UNION ALL SELECT 3, 3, ',1,2,3,', ','
	UNION ALL SELECT 3, 3, ' , 1 , 2 , 3 , ', ','
	UNION ALL SELECT 3, 3, ',,, , 1 , 2 , 3 , ,,,', ','
	UNION ALL SELECT 3, 3, 'a, b, c', ','
	UNION ALL SELECT 3, 3, 'a,b,c', ','
	UNION ALL SELECT 2, 6, 'Cat=Pub', '='
	UNION ALL SELECT 1, 1, 'a', ','
	UNION ALL SELECT 1, 1, '  a  ', ','
	-- 1 char Int Tests
	UNION ALL SELECT 10, 18, 'a,1,2,-1,-2,b,1.0,-1.0, 3 , -4 ,', ','
	-- Basic multi-char delim tests
	UNION ALL SELECT 0, 0, '', '<tag>'
	UNION ALL SELECT 0, 0, null, '<tag>'
	UNION ALL SELECT 0, 0, 'a', null
	UNION ALL SELECT 0, 0, 'a', ''
	UNION ALL SELECT 3, 3, '1<TaG>2<tag>3', '<tag>' -- Case Insensitivity test 1
	UNION ALL SELECT 3, 3, '<tag>1<tag>2<tag>3', '<TaG>' -- Case Insensitivity test 2
	UNION ALL SELECT 3, 3, '1<tag>2<tag>3<tag>', '<tag>'
	UNION ALL SELECT 3, 3, '<tag>1<tag>2<tag>3<tag>', '<tag>'
	UNION ALL SELECT 3, 3, ' <tag> 1 <tag> 2 <tag> 3 <tag> ', '<tag>'
	UNION ALL SELECT 3, 3, '<tag><tag><tag> <tag> 1 <tag> 2 <tag> 3 <tag> <tag><tag><tag>', '<tag>'
	UNION ALL SELECT 3, 3, 'a<tag> b<tag> c', '<tag>'
	UNION ALL SELECT 3, 3, 'a<tag>b<tag>c', '<tag>'
	UNION ALL SELECT 2, 6, 'Cat<tag>Pub', '<tag>'
	UNION ALL SELECT 1, 1, 'a', '<tag>'
	UNION ALL SELECT 1, 1, '  a  ', '<tag>'
	-- multi char delim Int Tests
	UNION ALL SELECT 10, 18, 'a<tag>1<tag>2<tag>-1<tag>-2<tag>b<tag>1.0<tag>-1.0<tag> 3 <tag> -4 <tag>', '<tag>'
	-- Delims with escape char % in it
	UNION ALL SELECT 0, 0, '', '<t%a%g>'
	UNION ALL SELECT 0, 0, null, '<t%a%g>'
	UNION ALL SELECT 0, 0, 'a', null
	UNION ALL SELECT 0, 0, 'a', ''
	UNION ALL SELECT 3, 3, '1<t%a%g>2<t%a%g>3', '<t%a%g>'
	UNION ALL SELECT 3, 3, '<t%a%g>1<t%a%g>2<t%a%g>3', '<t%a%g>'
	UNION ALL SELECT 3, 3, '1<t%a%g>2<t%a%g>3<t%a%g>', '<t%a%g>'
	UNION ALL SELECT 3, 3, '<t%a%g>1<t%a%g>2<t%a%g>3<t%a%g>', '<t%a%g>'
	UNION ALL SELECT 3, 3, ' <t%a%g> 1 <t%a%g> 2 <t%a%g> 3 <t%a%g> ', '<t%a%g>'
	UNION ALL SELECT 3, 3, '<t%a%g><t%a%g><t%a%g> <t%a%g> 1 <t%a%g> 2 <t%a%g> 3 <t%a%g> <t%a%g><t%a%g><t%a%g>', '<t%a%g>'
	UNION ALL SELECT 3, 3, 'a<t%a%g> b<t%a%g> c', '<t%a%g>'
	UNION ALL SELECT 3, 3, 'a<t%a%g>b<t%a%g>c', '<t%a%g>'
	UNION ALL SELECT 2, 6, 'Cat<t%a%g>Pub', '<t%a%g>'
	UNION ALL SELECT 1, 1, 'a', '<t%a%g>'
	UNION ALL SELECT 1, 1, '  a  ', '<t%a%g>'
	UNION ALL SELECT 10, 18, 'a<t%a%g>1<t%a%g>2<t%a%g>-1<t%a%g>-2<t%a%g>b<t%a%g>1.0<t%a%g>-1.0<t%a%g> 3 <t%a%g> -4 <t%a%g>', '<t%a%g>'
	-- Delims with escape char _ in it
	UNION ALL SELECT 0, 0, '', '<t_ag>'
	UNION ALL SELECT 0, 0, null, '<t_ag>'
	UNION ALL SELECT 0, 0, 'a', null
	UNION ALL SELECT 0, 0, 'a', ''
	UNION ALL SELECT 3, 3, '1<t_ag>2<t_ag>3', '<t_ag>'
	UNION ALL SELECT 3, 3, '<t_ag>1<t_ag>2<t_ag>3', '<t_ag>'
	UNION ALL SELECT 3, 3, '1<t_ag>2<t_ag>3<t_ag>', '<t_ag>'
	UNION ALL SELECT 3, 3, '<t_ag>1<t_ag>2<t_ag>3<t_ag>', '<t_ag>'
	UNION ALL SELECT 3, 3, ' <t_ag> 1 <t_ag> 2 <t_ag> 3 <t_ag> ', '<t_ag>'
	UNION ALL SELECT 3, 3, '<t_ag><t_ag><t_ag> <t_ag> 1 <t_ag> 2 <t_ag> 3 <t_ag> <t_ag><t_ag><t_ag>', '<t_ag>'
	UNION ALL SELECT 3, 3, 'a<t_ag> b<t_ag> c', '<t_ag>'
	UNION ALL SELECT 3, 3, 'a<t_ag>b<t_ag>c', '<t_ag>'
	UNION ALL SELECT 2, 6, 'Cat<t_ag>Pub', '<t_ag>'
	UNION ALL SELECT 1, 1, 'a', '<t_ag>'
	UNION ALL SELECT 1, 1, '  a  ', '<t_ag>'
	UNION ALL SELECT 10, 18, 'a<t_ag>1<t_ag>2<t_ag>-1<t_ag>-2<t_ag>b<t_ag>1.0<t_ag>-1.0<t_ag> 3 <t_ag> -4 <t_ag>', '<t_ag>'
	-- Semi Evil tests
	UNION ALL SELECT 2, 2, 'a~`!@#$%^&*()_+|-=\{}:;"''<>,.?/	b', '~`!@#$%^&*()_+|-=\{}:;"''<>,.?/	' -- no []
	UNION ALL SELECT 2, 2, 'a~`!@#$%^&*()_+|-=\{}[]:;"''<>,.?/	b', '~`!@#$%^&*()_+|-=\{}[]:;"''<>,.?/	' -- with []
	UNION ALL SELECT 2, 2, 'a' + CHAR(10) + CHAR(13) + 'b', CHAR(10) + CHAR(13) -- White space chars
	-- Big Text Tests
	UNION ALL SELECT @BigTextItemCount,@BigTextSumHash,@BigText, '#'
	UNION ALL SELECT @BigTextItemCount,@BigTextSumHash,REPLACE(@BigText,'#', '<tag>'), '<tag>'

-- Loop through each of the tests, logging results
DECLARE @txt nvarchar(max) -- Input text
DECLARE @delim nvarchar(1000) -- Input delimiter
DECLARE @cnt int -- Expected count
DECLARE @sum_len int -- Expected sum(len(item))
DECLARE @t_cnt int -- Actual count
DECLARE @t_sum_len int -- Actual sum(len(item))
DECLARE @start datetime -- Test Start time (for performance tracking)

DECLARE cur CURSOR FAST_FORWARD FOR
	SELECT [cnt],[txt],[delim],[sum_len] FROM @TESTS
OPEN cur
FETCH cur INTO @cnt, @txt, @delim,@sum_len
WHILE @@FETCH_STATUS = 0
BEGIN

	SELECT @start = GetDate();

	-- Execute test
	SELECT @t_cnt = count(*), @t_sum_len = SUM(LEN(item))
		FROM [string].[FN_SPLIT](@txt, @delim)
	
	-- Log results
	INSERT INTO @RESULTS ([msg],[runtime],[expected_count],[actual_count],[expected_sum_len],[actual_sum_len],[delim],[txt])
		SELECT 'TEST', DATEDIFF(ms, @start,  GetDate()), @cnt, @t_cnt, @sum_len, ISNULL(@t_sum_len,0), @delim, @txt
	
	FETCH cur INTO @cnt, @txt, @delim,@sum_len
END
CLOSE cur
DEALLOCATE cur

----------------------------------------------------------------------------------------------------------------------------------
-- Extra tests that required additional coding
DECLARE @int_test nvarchar(max)
SELECT @int_test = N'a,1,2,-1,-2,b,1.0,-1.0, 3 , -4 ,'

-- Basic int test, ensure int's are properly returned
INSERT INTO @RESULTS ([msg],[runtime],[expected_count],[actual_count],[expected_sum_len],[actual_sum_len],[delim],[txt])
SELECT 'Tested Ints 1', null, 6, count(*), null, null, ',', @int_test
	FROM [string].[FN_SPLIT](@int_test, ',') 
	WHERE [item_int] is not null

-- Ensure text value associated with int values maps 1:1
INSERT INTO @RESULTS ([msg],[runtime],[expected_count],[actual_count],[expected_sum_len],[actual_sum_len],[delim],[txt])
SELECT 'Tested Ints 2', null, 6, count(*), null, null, ',', @int_test
	FROM [string].[FN_SPLIT](@int_test, ',') 
	WHERE CAST([item_int] as nvarchar(max)) = [item]
	and item_int is not null


-- Split int tests
SELECT @int_test = '1,-2,3'
SELECT @start = GetDate();
INSERT INTO @RESULTS ([msg],[runtime],[expected_count],[actual_count],[expected_sum_len],[actual_sum_len],[delim],[txt])
		SELECT 'Split Int: ' + @int_test, DATEDIFF(ms, @start,  GetDate()), 3, count(*), 2, SUM(item_int), '#', @int_test
		FROM [string].[FN_SPLIT_INT](@int_test)

SELECT @int_test = '1,a,-2,b,3,c'
SELECT @start = GetDate();
INSERT INTO @RESULTS ([msg],[runtime],[expected_count],[actual_count],[expected_sum_len],[actual_sum_len],[delim],[txt])
		SELECT 'Split Int: ' + @int_test, DATEDIFF(ms, @start,  GetDate()), 3, count(*), 2, SUM(item_int), '#', @int_test
		FROM [string].[FN_SPLIT_INT](@int_test)

SELECT @int_test = '1, -2, 3' -- Spaces between commas
SELECT @start = GetDate();
INSERT INTO @RESULTS ([msg],[runtime],[expected_count],[actual_count],[expected_sum_len],[actual_sum_len],[delim],[txt])
		SELECT 'Split Int: ' + @int_test, DATEDIFF(ms, @start,  GetDate()), 3, count(*), 2, SUM(item_int), '#', @int_test
		FROM [string].[FN_SPLIT_INT](@int_test)

SELECT @int_test = ' 1, -2, 3 ' -- Leading/trailing
SELECT @start = GetDate();
INSERT INTO @RESULTS ([msg],[runtime],[expected_count],[actual_count],[expected_sum_len],[actual_sum_len],[delim],[txt])
		SELECT 'Split Int: ' + @int_test, DATEDIFF(ms, @start,  GetDate()), 3, count(*), 2, SUM(item_int), '#', @int_test
		FROM [string].[FN_SPLIT_INT](@int_test)

SELECT @int_test = '999999999999999,1,-2,-3,-99999999999999999' -- Basic boundry testing
SELECT @start = GetDate();
INSERT INTO @RESULTS ([msg],[runtime],[expected_count],[actual_count],[expected_sum_len],[actual_sum_len],[delim],[txt])
		SELECT 'Split Int: ' + @int_test, DATEDIFF(ms, @start,  GetDate()), 3, count(*), -4, SUM(item_int), '#', @int_test
		FROM [string].[FN_SPLIT_INT](@int_test)

SELECT @int_test = ' 1.0, -2.0, 3 ' -- Should only return ints
SELECT @start = GetDate();
INSERT INTO @RESULTS ([msg],[runtime],[expected_count],[actual_count],[expected_sum_len],[actual_sum_len],[delim],[txt])
		SELECT 'Split Int: ' + @int_test, DATEDIFF(ms, @start,  GetDate()), 1, count(*), 3, SUM(item_int), '#', @int_test
		FROM [string].[FN_SPLIT_INT](@int_test)

----------------------------------------------------------------------------------------------------------------------------------
-- Runtime / Performance testing

IF OBJECT_ID('tempdb..#t1') IS NOT NULL	DROP TABLE #t1
IF OBJECT_ID('tempdb..#t2') IS NOT NULL	DROP TABLE #t2
IF OBJECT_ID('tempdb..#t3') IS NOT NULL	DROP TABLE #t3

SELECT @start = GetDate();
SELECT [item] INTO #t1 FROM [string].[FN_SPLIT](@BigText, '#') 
INSERT INTO @RESULTS ([msg],[runtime],[expected_count],[actual_count],[expected_sum_len],[actual_sum_len],[delim],[txt])
		SELECT 'Speed 1: Item only', DATEDIFF(ms, @start,  GetDate()), null, null, null, null, '#', @BigText


SELECT @start = GetDate();
SELECT [item_int] INTO #t3 FROM [string].[FN_SPLIT](@BigText, '#') 
INSERT INTO @RESULTS ([msg],[runtime],[expected_count],[actual_count],[expected_sum_len],[actual_sum_len],[delim],[txt])
		SELECT 'Speed 2: Item Int Only', DATEDIFF(ms, @start,  GetDate()), null, null, null, null, '#', @BigText

SELECT @start = GetDate();
SELECT [item] INTO #t2 FROM [string].[FN_SPLIT](@BigText, '#') WHERE [item_int] IS NOT NULL
INSERT INTO @RESULTS ([msg],[runtime],[expected_count],[actual_count],[expected_sum_len],[actual_sum_len],[delim],[txt])
		SELECT 'Speed 3: Item With Int Filter', DATEDIFF(ms, @start,  GetDate()), null, null, null, null, '#', @BigText

IF OBJECT_ID('tempdb..#t1') IS NOT NULL	DROP TABLE #t1
IF OBJECT_ID('tempdb..#t2') IS NOT NULL	DROP TABLE #t2
IF OBJECT_ID('tempdb..#t3') IS NOT NULL	DROP TABLE #t3

----------------------------------------------------------------------------------------------------------------------------------
/*
-- Ensure test failures work
INSERT INTO @RESULTS ([msg],[runtime],[expected_count],[actual_count],[expected_sum_len],[actual_sum_len],[delim],[txt])
		SELECT 'INTENTIONAL FAILURE', null, 1, 2, 3, 4, '', ''
*/

-- Display results
SELECT * 
FROM @RESULTS
ORDER BY CASE [pass_fail] WHEN 'FAIL' THEN 0 ELSE 1 END ASC, [id] ASC

-- And Total runtime
SELECT SUM(ISNULL(runtime,0)) as [total_runtime] FROM @RESULTS

-- Raise errors as needed.
IF (SELECT count(*) FROM @RESULTS WHERE [pass_fail] = 'FAIL') > 0
	RAISERROR('Unexpected results.  Review results table for details.',18,1)
GO
