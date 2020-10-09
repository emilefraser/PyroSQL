SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/***** Setup the Test ******/
--The first thing I need to do for my test is create this table where I will test the inserts.
/*
	EXEC [dbo].[TestPerformanceBetweenAlternates]
*/
CREATE   PROCEDURE [dbo].[TestPerformanceBetweenAlternates]
AS
BEGIN
	DROP TABLE IF EXISTS [dbo].[TestPerformance]

	--Create a table for testing
	CREATE TABLE [dbo].[TestPerformance] (
			[TestID]          INT IDENTITY(1, 1) PRIMARY KEY
	,		[TestDateTime]    DATETIME2(7)
	,		[TestInteger]     INT
	,		[TestVarchar]     VARCHAR(10)
	)

	--The command that I want to test is the following and is in the larger script below.         
	INSERT INTO [dbo].[testPerformance]
	VALUES (
		GETDATE()
	  , ROUND(RAND() * 1000, 0)
	  , 'testString'
	)

	/***** Code to Run the Test ******/
	--Here is the code that will loop through the test.

	DECLARE
		@numberOfTests         INTEGER = 5			--The outer loop - the number of times to repeat the test		
	,	@numberOfIterations    INTEGER = 100000		--The inner loop - the number of times to repeat the code
	
	--The following statement will display a message to the user
	SELECT 'Starting performance test' AS [MessageToUser]

	--Declare the variables
	DECLARE 
		@overallStartTime      DATETIME = GETDATE()
	,	@testStartTime         DATETIME = GETDATE()
	,	@testEndTime           DATETIME = GETDATE()
	,	@testElapsedTime       INT      = 0
	,	@totalElapsedTime      BIGINT   = 0
	,	@averageElapsedTime    FLOAT    = 0
	,	@testRun               INTEGER  = 1
	,	@iteration             INTEGER  = 1

	BEGIN TRANSACTION
	--start the outer loop

	WHILE @testRun <= @numberOfTests
	BEGIN
		SET @iteration = 1
		SET @testStartTime = GETDATE()

		--the command below is part of my test
		TRUNCATE TABLE [dbo].[TestPerformance]

		--start the inner loop
		WHILE @iteration <= @numberOfIterations
		BEGIN

			/*** THE ACTUAL TEST ***/			
			DROP TABLE IF EXISTS dbo.Numbers

			CREATE TABLE dbo.Numbers (
				n BIGINT
			)

			;WITH e1(n) AS
			(
				SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
				SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
				SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
			)														-- 10
				,e2(n) AS (SELECT 1 FROM e1 CROSS JOIN e1 AS b)		-- 10*10
				,e3(n) AS (SELECT 1 FROM e1 CROSS JOIN e2 AS c)		-- 10*100
				,e4(n) AS (SELECT 1 FROM e1 CROSS JOIN e3 AS d)		-- 10*1000
				,e5(n) AS (SELECT 1 FROM e1 CROSS JOIN e4 AS e)		-- 10*10000
				,e6(n) AS (SELECT 1 FROM e1 CROSS JOIN e5 AS e)		-- 10*100000
			INSERT  INTO 
				dbo.Numbers(n)
			SELECT 
				n = ROW_NUMBER() OVER (ORDER BY n) 
			FROM 
				e6 
			ORDER BY 
				n

			--end of code
			-----------------------------------------
			--advance the inner loop counter           
			SET @iteration = @iteration + 1

			--commit after 1000 inserts, this can be adjusted to see how the performance is affected
			IF(@iteration % 1000 = 0)
			BEGIN
				COMMIT
				BEGIN TRANSACTION
			END
		END

		SET @testEndTime = GETDATE()

		--get the elapsed time in milliseconds for the test
		SET @testElapsedTime = DATEDIFF([ms], @testStartTime, @testEndTime)

		--accumulate the total elapsed time
		SET @totalElapsedTime = @totalElapsedTime + @testElapsedTime

		--display the elapsed time for the test
		SELECT 
			'testRun ' + CAST(@testRun AS VARCHAR(10)) + ', elapsed time = ' + CAST(@testElapsedTime AS VARCHAR(10)) + 'ms' AS [MessageToUser]

		--advance the outer loop counter
		SET @testRun = @testRun + 1
	END

	COMMIT

	DECLARE 
		@overallEndTime    DATETIME = GETDATE()
	SELECT 
		@overallStartTime AS [OverallStartTime]
	  , @overallEndTime AS [OverallEndTime]
	  , DATEDIFF([ms], @overallStartTime, @overallEndTime) AS [OverallElapsedTime]
	  , @totalElapsedTime / CAST(@numberOfTests AS FLOAT) AS [AverageElapsedTime]

END

GO
