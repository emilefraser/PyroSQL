USE [MetricsVault]
GO
/****** Object:  StoredProcedure [dbo].[sp_handle_EnsambleMetric]    Script Date: 2020/05/27 7:08:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

	Written By: Emile Fraser
	Date: 2020-05-20
	Function: Acts as the central handler of the Metrics Vault Population. Gets configs, constructs the Proc Strings to Execute 
				Executes then procs to write metrics and then also logs the activity

	Execution Example:

	DECLARE 
		@ServerName			SYSNAME			= 'TSABISQL02\STAGSSIS'
	,	@DatabaseName		SYSNAME			= 'DataVault'
	,	@SchemaName			SYSNAME			= 'RAW'
	,	@ProcedureName		SYSNAME			= 'sp_loadhub_XT_Terminal'

	EXEC [dbo].[sp_handle_EnsambleMetric]
		@ServerName		= @ServerName
	,	@DatabaseName	= @DatabaseName
	,	@SchemaName		= @SchemaName	
	,	@ProcedureName	= @ProcedureName
*/

-- Inserts plain count of rows to Ensambles
ALTER     PROCEDURE [dbo].[sp_handle_EnsambleMetric]
	@ServerName			SYSNAME
,	@DatabaseName		SYSNAME
,	@SchemaName			SYSNAME
,	@ProcedureName		SYSNAME
AS
BEGIN
	DECLARE 
		@sql_statement					NVARCHAR(MAX)
	,	@sql_parameter					NVARCHAR(MAX)
	,	@sql_message					NVARCHAR(MAX)
	,	@sql_crlf						NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_tab						NVARCHAR(1) = CHAR(9)
	,	@sql_debug						BIT = 1
	,	@sql_execute					BIT = 1

	DECLARE  
		@ElementID						SMALLINT
	,	@EnsambleID						SMALLINT
	,	@EnsambleName					VARCHAR(100)
	,	@EntityType						VARCHAR(30)
	,	@DataEntityName					SYSNAME
	,	@FullyQualifiedEntityName		NVARCHAR(523)   -- (128 * 4) + (2 * 4) + (1 * 3)  -- SYSNAME + BRACKEETS + DOTS

	DECLARE 
		@config_cursor					CURSOR
	,	@metric_typeid					SMALLINT
	,	@scheduleid						SMALLINT
	,	@timegrainid					SMALLINT
	,	@configid						SMALLINT
	,	@metricprocedureName			SYSNAME
	,	@additional_parameters			NVARCHAR(MAX)
	,	@return_status					SMALLINT

	-- Sets the DT of the Current Insert 
	DECLARE @CreatedDT DATETIME2(7) = GETDATE()
	DECLARE @CurrentLogStatus SMALLINT = 0

	-- Gets the Entity type being loaded by the Procedure
	-- As well as the entity ultimately loaded 
	SET @EntityType			= (SELECT UPPER(REPLACE(Item, 'load','')) FROM  dbo.udf_split_String(@ProcedureName,'_',2))
	SET @EnsambleName		= (SELECT Item FROM dbo.udf_split_String(@ProcedureName,'_',4))
	SET @DataEntityName		= @EntityType + '_' + @EnsambleName

	-- Fully Qualified Name to figure out on what entity to run the test and then what ElementID relates to the FullyQualifiedName
	SET @FullyQualifiedEntityName = CONCAT_WS('.', QUOTENAME(@ServerName), QUOTENAME(@DatabaseName), QUOTENAME(@SchemaName), QUOTENAME(@DataEntityName))
	SET @ElementID = (SELECT ElementID FROM dbo.Ensamble_Element WHERE [ElementFullyQualified] = @FullyQualifiedEntityName)
	
	--SELECT @FullyQualifiedEntityName, @SchemaName, @ProcedureName, @EntityType, @EnsambleName, @DataEntityName, @DatabaseName
	--SELECT @ElementID
	
	-- Now Get all the Balancing Config Data Which will be entered into a cursor
	SET @config_cursor = CURSOR FOR 
	SELECT 
		ConfigID
	,	MetricTypeID
	FROM 
		[MetricsVault].[dbo].[Ensamble_Config]
	WHERE
		[ElementID] = @ElementID

	OPEN @config_cursor
	
	FETCH NEXT FROM @config_cursor
	INTO @configid, @metric_typeid

	--select * from dbo.ensamble_config

	WHILE (@@FETCH_STATUS = 0)
	BEGIN

		-- Gets the procedure name to be executed as well as any additional fields we will require
		SELECT 
			@metricprocedureName = emt.ProcedureName
		,	@additional_parameters = emt.AdditionalParameters
		FROM 
			dbo.Ensamble_MetricType AS emt
		WHERE 
			MetricTypeID =  @metric_typeid

		--SELECT @metricprocedureName, @configid, @additional_parameters

		DECLARE @GroupByFieldName NVARCHAR(MAX)

		-- Gets the Additional Parameters we will need
		SET @sql_statement = N'
			SELECT 
				@GroupByFieldName = ' + QUOTENAME(@additional_parameters) + '
			FROM 
				dbo.Ensamble_Config
			WHERE
				ConfigID = @configid
		'

		SET @sql_parameter = N'@GroupByFieldName NVARCHAR(MAX) OUTPUT, @configid SMALLINT'

		IF(@sql_debug = 1)
			RAISERROR(@sql_statement, 0, 1)

		IF(@sql_execute = 1)
		BEGIN
			EXEC sp_executesql 
				@stmt  = @sql_statement
			,	@param = @sql_parameter
			,	@GroupByFieldName = @GroupByFieldName OUTPUT
			,	@configid = @configid
		END


		-- Write the Open Log Position to the Logfile
		EXEC dbo.sp_insert_Ensamble_Log
			@MetricProcedureCalled	=	@metricprocedureName	
		,	@ConfigID				=	@configid
		,	@LogStatusTypeID		=	0


		-- Now finally compose the test string to execute and fire
		--SELECT @metricprocedureName, @configid, @additional_parameters, @GroupByFieldName
		SET @sql_statement = 'EXEC ' + QUOTENAME(N'dbo') + '.' + QUOTENAME(@metricprocedureName) + @sql_crlf + @sql_tab + 
									N'    @ConfigID' + N' = ''' + CONVERT(NVARCHAR(5), @configid) + N'''' + @sql_crlf + @sql_tab + 
									N',   @GroupByFieldName' + N' = ''' + @GroupByFieldName + N''''
		SET @sql_parameter = N''

		IF(@sql_debug = 1)
			RAISERROR(@sql_statement, 0, 1)

		IF(@sql_execute = 1)
		BEGIN

			-- Executes the Actual Metric Capturing
			EXEC @return_status = sp_executesql 
							@stmt  = @sql_statement
						,	@param = @sql_parameter


			SET @return_status = IIF(@return_status <> 0, -1, 1)

			-- Write the Close Log Position to the Logfile
				EXEC dbo.sp_insert_Ensamble_Log
					@MetricProcedureCalled	=	@metricprocedureName	
				,	@ConfigID				=	@configid
				,	@LogStatusTypeID		=	@return_status
		
		END

		FETCH NEXT FROM @config_cursor
		INTO @configid, @metric_typeid
		
	END
END
