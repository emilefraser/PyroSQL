USE [MetricsVault]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_EnsambleMetric_RowCount]    Script Date: 2020/05/24 11:33:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	DECLARE 
		@ElementID				SMALLINT				= 1
	,	@MetricTypeID			SMALLINT				= 1
	,	@TimeGrainID			SMALLINT				= 5
	,	@GroupByDateFieldName	SYSNAME					= 'LoadDT'

	EXEC [dbo].[sp_insert_EnsambleMetric_RowCount]
		@ElementID				= @ElementID
	,	@MetricTypeID			= @MetricTypeID
	,	@TimeGrainID			= @TimeGrainID	
	,	@GroupByDateFieldName	= @GroupByDateFieldName
*/

-- Inserts plain count of rows to Ensambles
ALTER     PROCEDURE [dbo].[sp_insert_EnsambleMetric_RowCount]
	@ElementID				SMALLINT
,	@MetricTypeID			SMALLINT
,	@TimeGrainID			SMALLINT
,	@GroupByDateFieldName	SYSNAME		= NULL
AS
BEGIN
	DECLARE
		@sql_statement	NVARCHAR(MAX)
	,	@sql_parameter	NVARCHAR(MAX)
	,	@sql_message	NVARCHAR(MAX)
	,	@sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_tab		NVARCHAR(1) = CHAR(9)
	,	@sql_debug		BIT = 1
	,	@sql_execute	BIT = 0
	
	DECLARE 
	  @count			INT
	, @EnsambleID		SMALLINT
	, @EntityType		VARCHAR(30)
	, @GroupByCode		NVARCHAR(MAX) 


	DECLARE		
		@EnsambleName	NVARCHAR(100)
	,	@ServerName		SYSNAME			= NULL
	,	@DatabaseName	SYSNAME
	,	@SchemaName		SYSNAME
	,	@EntityName		SYSNAME
	,	@TimeGrainCode	SYSNAME

	-- Sets the DT of the Current Insert 
	DECLARE @CreatedDT DATETIME2(7) = GETDATE()

	-- Get the Ensamble ELement Details
	SELECT
		@ServerName		=	es.ElementServerName
	,	@DatabaseName	=	es.ElementDatabaseName
	,	@SchemaName		=	es.ElementSchemaName
	,	@EntityName		=	es.ElementEntityName
	FROM 
		dbo.Ensamble_Element AS es
	WHERE
		ElementID = @ElementID

	
	-- GET TIME GRAIN VALUE
	-- IF ALL JUST USE DATE @CreatedDT AND NO GROUP BY FUNCTION
	SET @TimeGrainCode  = (SELECT TimeGrainCode FROM dbo.[Ensamble_Timegrain] WHERE [TimeGrainID] = @TimeGrainID)
	IF(@TimeGrainCode = 'ALL')
	BEGIN
		SET @GroupByCode = '@CreatedDT'
	END
	ELSE
	BEGIN
		SELECT @TimeGrainCode
		SET @GroupByCode = (SELECT [dbo].[usp_get_GroupBy](@GroupByDateFieldName, @TimeGrainID))
	END

	-- OTHERWISE USE GROUP BY FUNCTION
	DECLARE @DateValue NVARCHAR(MAX)
	
	SET @sql_statement = N'
		INSERT INTO 
			[dbo].[EnsambleMetric_RowCount] (
		  		[ElementID]
			  ,	[MetricTypeID]
			  ,	[DateValue]
			  ,	[Row_Count]
			  ,	[CreatedDT]
		)
		SELECT 
			ElementID		= '   + CONVERT(NVARCHAR(5), @ElementID)	+ ' 
		,	MetricTypeID	= '   + CONVERT(NVARCHAR(5), @MetricTypeID) + '
		,	DateValue		= '   + IIF(@TimeGrainCode = 'ALL', '' + CONVERT(NVARCHAR(27), @CreatedDT) + '', @GroupByCode) + '
		,	Row_Count		= COUNT(1)  
		,	CreatedDT		= ''' + CONVERT(NVARCHAR(27), @CreatedDT) + '''
		FROM ' + @sql_crlf + REPLICATE(@sql_tab, 3) +
			IIF(@ServerName IS NOT NULL, QUOTENAME(@ServerName) + '.', '') + 
			QUOTENAME(@DatabaseName) + '.' +
			QUOTENAME(@SchemaName) + '.' +
			QUOTENAME(@EntityName)


	-- Adds the Group by Portion if needed 
	IF(@TimeGrainCode != 'ALL')
	BEGIN
		SET @sql_statement += @sql_crlf + REPLICATE(@sql_tab, 2) + ' GROUP BY ' + @sql_tab + @GroupByCode
	END

	SET @sql_parameter = N''

	IF(@sql_debug = 1)
		RAISERROR(@sql_statement, 0, 1)

	IF(@sql_execute = 1)
	BEGIN
		EXEC sp_executesql 
			@stmt  = @sql_statement
		,	@param = @sql_parameter
		,	@count = @count OUTPUT
	END

	/*
	-- Inserts the Count into the Metric Table
	INSERT INTO 
		[dbo].[EnsambleMetric_RowCount] (
		  	[ElementID]
		  ,	[MetricTypeID]
		  ,	[DateValue]
		  ,	[Row_Count]
		  ,	[CreatedDT]
	)
	SELECT 
		EnsambleID		= @EnsambleID
	,	MetricTypeID	= @MetricTypeID
	,	DateValue		= @DatabaseName
	,	Row_Count		= @
	,	CreatedDT		= @CreatedDT
	*/






END
