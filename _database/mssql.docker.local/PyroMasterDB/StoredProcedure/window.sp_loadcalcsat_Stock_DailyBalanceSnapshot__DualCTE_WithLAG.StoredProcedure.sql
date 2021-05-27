SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[window].[sp_loadcalcsat_Stock_DailyBalanceSnapshot__DualCTE_WithLAG]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [window].[sp_loadcalcsat_Stock_DailyBalanceSnapshot__DualCTE_WithLAG] AS' 
END
GO

ALTER PROCEDURE [window].[sp_loadcalcsat_Stock_DailyBalanceSnapshot__DualCTE_WithLAG]
	@Today DATE,
	@IsReload BIT = 0,
	@IsTest BIT = 0,
	@RemoveReloadInterval BIT = 1
AS
/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
--Stored Proc Management
	--===============================================================================================================================
	--Variable workbench
	--===============================================================================================================================
	--Stored Proc Varialbles
	--DECLARE
	--	@Today DATE = '2019/08/04',
	--	@IsReload BIT = 0,
	--	@IsTest BIT = 0,
	--	@RemoveReloadInterval BIT = 0

	--Log Variables
	DECLARE @ExecutionLogID int
			, @StepStartDT datetime2(7)
			, @StepFinishDT datetime2(7)
			, @StepDuration int
			, @StepAffectedRowCount int 
			, @DatabaseName varchar(100)
			, @SchemaName varchar(100)
--!~ LoadConfigID
			, @LoadConfigID int = 103 --TODO update
-- End of LoadConfigID ~!
			, @StartDate datetime2(7) = GETDATE()
			, @DataEntityName varchar(100) = '[CALCSAT_Stock_DailyBalanceSnapshot]' --Target Data Entity


--Declarations
DECLARE
	  @ReloadInterval int = -1 -- Setting historic reload interval (beginning of last month if this is -1)
	, @LoadStartDate date -- Date from where to reload the aggregate fact
	, @CurrentLoadDate date
	, @HK_Stock VARCHAR(40)
	, @LoadChunks INT = 90
	, @FirstMovementDate_BRIDGE DATE
	, @LastMovmentDate_CALCSAT DATE


DECLARE 
	@sql AS VARCHAR(MAX)
,	@sql_select AS NVARCHAR(MAX)
,	@sql_insert AS NVARCHAR(MAX)
,	@sql_delete AS NVARCHAR(MAX)
,	@sql_params AS NVARCHAR(MAX)
,	@sql_values AS NVARCHAR(MAX)
,	@recursion_days AS INT

SET @Today = ISNULL(@Today, CONVERT(DATE, GETDATE()))

--===============================================================================================================================
--Get MAX([DateKey]) FROM Snapshot Fact
--===============================================================================================================================

--************** LOGGING **************--
--SET		@StepStartDT = CONVERT(datetime2(7), GETDATE())
--************** LOGGING **************--

--If it's a reload, set the load start date manually
IF @IsReload = 1 
BEGIN
	SET @LoadStartDate = '1900/01/01'

END
--If there is data in the Fact already, get the latest snapshot date from the Fact table
ELSE IF (SELECT COUNT(1)
		   FROM [dbo].[CALCSAT_Stock_DailyBalanceSnapshot]
	    ) > 1
BEGIN
	SELECT @LoadStartDate = MAX(DateKey)
	 FROM [dbo].[CALCSAT_Stock_DailyBalanceSnapshot]

	--The @LoadStartDate can only be a maximum of today
	IF @LoadStartDate >= @Today
	BEGIN
		--Set @LoadStartDate to yesterday
		SET @LoadStartDate = DATEADD(day, -1, @Today)
	END

	--Only backdate the @LoadStartDate to the beginning of last month if the @RemoveReloadInterval is true
	IF @RemoveReloadInterval = 1
	BEGIN
		--Set the @LoadStartDate to the beginning of last month (based on the @ReloadInterval)
		SET @LoadStartDate = DATEADD(month, @ReloadInterval, DATEADD(month, DATEDIFF(month, 0, @LoadStartDate), 0))
	END
	ELSE
	--Set the @LoadStartDate to the day after the last load date in the Fact table
	BEGIN
		SET @LoadStartDate = DATEADD(day, 1, @LoadStartDate)
	END


END
ELSE
--Set the start load date manually (because it's the initial load)
BEGIN
	SET @LoadStartDate = '1900/01/01'
END

--If @LoadStartDate is set to the beginning of time, get the start of the SAT as the @LoadStartDate
IF @LoadStartDate = '1900/01/01'
BEGIN
	SET @LoadStartDate = (SELECT MIN(Logtime) FROM [dbo].[SAT_StockTransaction])
END
	
--===============================================================================================================================
--Delete from the target table as necessary
--===============================================================================================================================

--If it's a reload, clear the entire target table
IF @IsReload = 1 
BEGIN
	TRUNCATE TABLE [dbo].[CALCSAT_Stock_DailyBalanceSnapshot]
END
--Delete from the snapshot fact going back to the first day of last month
ELSE
BEGIN
	DELETE
	  FROM [dbo].[CALCSAT_Stock_DailyBalanceSnapshot]
	 WHERE DateKey >= @LoadStartDate
END

--===============================================================================================================================
-- BUILD THE LOAD SETS, FORE EVERYSTOCK ITEM WE WILL LOAD 90 DAYS 1 ITEMS AT A TIME
--===============================================================================================================================

-- Create @ Table to hold the Load Params per StockItem
DECLARE @StockParameters TABLE (
	HK_Stock VARCHAR(40) INDEX ncix_StockParameters_HK_Stock NONCLUSTERED
,	FirstMovementDate_BRIDGE DATE
,	LastMovmentDate_CALCSAT DATE
)

-- Get Relevant info for the query 
INSERT INTO @StockParameters (HK_Stock, FirstMovementDate_BRIDGE, LastMovmentDate_CALCSAT)
SELECT 
	h_stock.HK_Stock
,	ISNULL(MIN(stktrans.TransactionDate), '9999/12/31') AS FirstMovementDate_BRIDGE
,	ISNULL(MAX(csat.DateKey), '1900/01/01') AS LastMovmentDate_CALCSAT
FROM 
	.[dbo].[HUB_Stock] AS h_stock
INNER JOIN 
	[dbo].[BRIDGE_StockTransaction] stktrans
	ON stktrans.StockKey = h_stock.HK_STOCK
LEFT JOIN 
	[dbo].[CALCSAT_Stock_DailyBalanceSnapshot] csat
	ON csat.HK_Stock = h_stock.HK_STOCK
GROUP BY 
	h_stock.HK_Stock


DECLARE stock_cursor CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
SELECT 
	HK_Stock, FirstMovementDate_BRIDGE, LastMovmentDate_CALCSAT
FROM 
	@StockParameters

OPEN stock_cursor
FETCH NEXT FROM stock_cursor
INTO @HK_Stock, @FirstMovementDate_BRIDGE, @LastMovmentDate_CALCSAT

WHILE (@@FETCH_STATUS = 0)
BEGIN

		SET @LoadStartDate = (SELECT MAX(sq.MovmentDate) FROM (SELECT @FirstMovementDate_BRIDGE AS MovmentDate UNION ALL SELECT @LastMovmentDate_CALCSAT AS MovmentDate) AS sq)
		
		-- deactivate indexes in the CALCSAT
		--IF @IsReload = 1
		--ALTER INDEX ncix_CALCSAT_Stock_DailyBalanceSnapshot_DateKey_Include1 ON [dbo].[CALCSAT_Stock_DailyBalanceSnapshot] DISABLE
		--ALTER INDEX PK_CALCSAT_Stock_DailyBalanceSnapshot_EMS ON [dbo].[CALCSAT_Stock_DailyBalanceSnapshot] DISABLE

		--===============================================================================================================================
		-- INSERT New Records into Snapshot Fact
		--===============================================================================================================================
		--DECLARE @HK_Stock VARCHAR(40) = '09BD6CD4BE6219CDDB9E065C491CDB6119B8C32F'
		--DECLARE @LoadStartDate DATE = '2004-10-15'
		--DECLARE @Today DATE = '2004-10-30'
	
		;WITH cte_endofday AS
		(
			SELECT
				[refd].[CalendarDate]
			  ,	LAG([refd].[CalendarDate]) OVER (PARTITION BY isnull([f].[StockKey], @HK_Stock) ORDER BY [refd].[CalendarDate] ASC) CalendarDate_LAG
		      ,	LEAD([refd].[CalendarDate]) OVER (PARTITION BY isnull([f].[StockKey], @HK_Stock) ORDER BY [refd].[CalendarDate] ASC) CalendarDate_LEAD
		      ,	isnull([f].[StockKey], @HK_Stock) AS StockKey
		      ,	[f].[QtyAfter] AS Quantity
		      ,	[f].[AveCostPerUnit] AS AverageCostPerUnit
			 FROM 
				 [dbo].[REF_Date] AS [refd]				
			LEFT JOIN
			(
				 SELECT 
					 [brid].[TransactionDate]
				   , [brid].[StockKey]
				   , SUM([brid].[QtyAfter]) AS QtyAfter
				   , AVG([brid].[AveCostPerUnit]) AS [AveCostPerUnit]
				 FROM 
					 [dbo].[BRIDGE_StockTransaction] AS [brid]
				 INNER JOIN (
							SELECT 
								[brid_lasttx].[TransactionDate], [brid_lasttx].[StockKey], [brid_lasttx].[BranchKey], MAX([brid_lasttx].[RowCount]) AS lastofday
							FROM 
								[dbo].[BRIDGE_StockTransaction] AS [brid_lasttx]
							WHERE
								[brid_lasttx].StockKey =  @HK_Stock
							AND
								[brid_lasttx].[TransactionDate] BETWEEN  @LoadStartDate AND @Today
							GROUP BY 
								[brid_lasttx].[TransactionDate], [brid_lasttx].[StockKey], [brid_lasttx].[BranchKey]
				) AS lod
				ON lod.[TransactionDate] = [brid].[TransactionDate]
				AND lod.StockKey = [brid].StockKey
				AND lod.BranchKey = [brid].BranchKey
				AND lod.lastofday = [brid].[RowCount]
				GROUP BY 
			 [brid].[TransactionDate]
				   , [brid].[StockKey]
			) AS [f]
		ON [f].[TransactionDate] = [refd].[CalendarDate]
		WHERE
			[refd].CalendarDate BETWEEN  @LoadStartDate AND @Today
		
),
cte_soh AS
(
    SELECT 
		  [CalendarDate]
		, [CalendarDate_LAG]
		, [CalendarDate_LEAD]
		, [StockKey]
		, [Quantity]
		, [AverageCostPerUnit]
    FROM 
		cte_endofday
    WHERE 
		[CalendarDate_LAG] IS NULL

    UNION ALL

    SELECT 
		  eod.[CalendarDate]
		, eod.[CalendarDate_LAG]
		, eod.[CalendarDate_LEAD]
		, eod.[StockKey]
		, COALESCE(eod.[Quantity], soh.[Quantity]) AS Quantity
		, COALESCE(eod.[AverageCostPerUnit], soh.[AverageCostPerUnit]) AS AverageCostPerUnit
    FROM 
		cte_endofday AS eod
    INNER JOIN 
		cte_soh AS soh
    ON 
		soh.[CalendarDate_LEAD] = eod.[CalendarDate]
)

INSERT INTO [dbo].[CALCSAT_Stock_DailyBalanceSnapshot] (
		[HK_Stock]
	,	[LoadDT]
	,	[DateKey]
	,	[QtyOnHand]
	,	[AveCostPerUnit]
	,	[TotalCost]
)
SELECT 
		cte_soh.[StockKey] AS [HK_Stock]
	,	@Today AS [LoadDT]
	,	[CalendarDate] AS [DateKey]
	,	cte_soh.[Quantity]
	,	cte_soh.[AverageCostPerUnit]
	,	[TotalCost] = CONVERT(DECIMAL(29, 2), cte_soh.[Quantity]) * CONVERT(DECIMAL(29, 2), cte_soh.[AverageCostPerUnit])
FROM 
	cte_soh
ORDER BY 
	CalendarDate OPTION (MAXRECURSION 10000)

	FETCH NEXT FROM stock_cursor
	INTO @HK_Stock, @FirstMovementDate_BRIDGE, @LastMovmentDate_CALCSAT

END

CLOSE stock_cursor
DEALLOCATE stock_cursor


		-- deactivate indexes in the CALCSAT
		-- IF @IsReload = 1
		--ALTER INDEX ncix_CALCSAT_Stock_DailyBalanceSnapshot_DateKey_Include1 ON [dbo].[CALCSAT_Stock_DailyBalanceSnapshot] REBUILD
		--ALTER INDEX PK_CALCSAT_Stock_DailyBalanceSnapshot_EMS ON [dbo].[CALCSAT_Stock_DailyBalanceSnapshot] REBUILD
GO
