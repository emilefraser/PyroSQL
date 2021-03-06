USE [MetricsVault]
GO
/****** Object:  User [THARISA\hvermaak]    Script Date: 2020/06/05 2:07:01 AM ******/
CREATE USER [THARISA\hvermaak] FOR LOGIN [THARISA\hvermaak] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [THARISA\MROSL]    Script Date: 2020/06/05 2:07:01 AM ******/
CREATE USER [THARISA\MROSL] FOR LOGIN [THARISA\MROSL] WITH DEFAULT_SCHEMA=[THARISA\MROSL]
GO
ALTER ROLE [db_datareader] ADD MEMBER [THARISA\hvermaak]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [THARISA\hvermaak]
GO
ALTER ROLE [db_datareader] ADD MEMBER [THARISA\MROSL]
GO
/****** Object:  Schema [THARISA\MROSL]    Script Date: 2020/06/05 2:07:01 AM ******/
CREATE SCHEMA [THARISA\MROSL]
GO
/****** Object:  UserDefinedFunction [dbo].[usp_get_GroupBy]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	SELECT [dbo].[usp_get_GroupBy]('ClockTime', 5) 

*/
CREATE   FUNCTION [dbo].[usp_get_GroupBy] (	
	@GroupByDateFieldName	SYSNAME
,	@TimeGrainID			SMALLINT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	
	DECLARE 
			@GroupByCode NVARCHAR(MAX)
	,		@sql_tab		NVARCHAR(1) = CHAR(9)

	-- Parameters needed for grouping
	DECLARE
		@Years		SMALLINT
	,	@Months		SMALLINT
	,	@Days		SMALLINT
	,	@Hours		SMALLINT
	,	@Minutes	SMALLINT

	-- Get the TimeGrain to Apply in the Group by Function
	SELECT
		@Years		=	etg.[Years]
	,	@Months		=	etg.[Months]
	,	@Days		=	etg.[Days]
	,	@Hours		=	etg.[Hours]
	,	@Minutes	=	etg.[Minutes]
	FROM
		dbo.Ensamble_Timegrain AS etg
	WHERE
		TimeGrainID = @TimeGrainID

	SET @GroupByCode = ' 
								FORMAT(ISNULL(DATEPART(YEAR,	' + QUOTENAME(@GroupByDateFieldName) + ') / NULLIF(' + CONVERT(VARCHAR(4), @Years)	+ ', 0), 0), ''0000'') + ''-'' +
								FORMAT(ISNULL(DATEPART(MONTH,	' + QUOTENAME(@GroupByDateFieldName) + ') / NULLIF(' + CONVERT(VARCHAR(2), CASE 
																																			WHEN @Months != 0 
																																				THEN @Months
																																				ELSE DATEPART(MONTH, '1900-01-01')
																																			END)	+ ', 0), 0),   ''00'') + ''-'' +
								FORMAT(ISNULL(DATEPART(DAY,		' + QUOTENAME(@GroupByDateFieldName) + ') / NULLIF(' + CONVERT(VARCHAR(2), CASE 
																																			WHEN @Days != 0 
																																				THEN @Days
																																				ELSE DATEPART(DAY, '1900-01-01')
																																			END)	+ ', 0), 0),   ''00'') + '' '' + 
								FORMAT(ISNULL(DATEPART(HOUR,	' + QUOTENAME(@GroupByDateFieldName) + ') / NULLIF(' + CONVERT(VARCHAR(2), @Hours)	+ ', 0), 0),   ''00'') + '':'' +
								FORMAT(ISNULL(DATEPART(MINUTE,	' + QUOTENAME(@GroupByDateFieldName) + ') / NULLIF(' + CONVERT(VARCHAR(2), @Minutes)+ ', 0), 0),   ''00'') + '':00.000''
		'

	RETURN @GroupByCode

END
GO
/****** Object:  Table [dbo].[Ensamble_Element]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ensamble_Element](
	[ElementID] [smallint] IDENTITY(1,1) NOT NULL,
	[EnsambleID] [smallint] NOT NULL,
	[ElementTypeID] [smallint] NOT NULL,
	[ElementServerName] [sysname] NOT NULL,
	[ElementDatabaseName] [sysname] NOT NULL,
	[ElementSchemaName] [sysname] NOT NULL,
	[ElementEntityName] [sysname] NOT NULL,
	[ElementFullyQualified]  AS ((((((isnull(quotename([ElementServerName]),quotename(@@servername))+'.')+isnull(quotename([ElementDatabaseName]),''))+'.')+isnull(quotename([ElementSchemaName]),''))+'.')+isnull(quotename([ElementEntityName]),'')),
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ElementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ensamble_MetricType]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ensamble_MetricType](
	[MetricTypeID] [smallint] IDENTITY(1,1) NOT NULL,
	[MetricTypeCode] [varchar](30) NOT NULL,
	[MetricTypeName] [sysname] NULL,
	[ProcedureName] [sysname] NULL,
	[AdditionalParameters] [varchar](8000) NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK__Ensambl__CCAAE1D21CEC0E4B] PRIMARY KEY CLUSTERED 
(
	[MetricTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnsambleMetric_RowCount]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnsambleMetric_RowCount](
	[MetricID] [bigint] IDENTITY(1,1) NOT NULL,
	[ElementID] [smallint] NOT NULL,
	[MetricTypeID] [smallint] NOT NULL,
	[ConfigID] [smallint] NOT NULL,
	[DateValue] [datetime2](7) NULL,
	[Row_Count] [int] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK__RowCount__56105645E51B67AD] PRIMARY KEY CLUSTERED 
(
	[MetricID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ensamble_Timegrain]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ensamble_Timegrain](
	[TimeGrainID] [smallint] IDENTITY(1,1) NOT NULL,
	[TimeGrainCode] [varchar](30) NULL,
	[TimeGrainDescription] [varchar](100) NULL,
	[Years] [smallint] NULL,
	[Months] [smallint] NULL,
	[Days] [smallint] NULL,
	[Hours] [smallint] NULL,
	[Minutes] [smallint] NULL,
 CONSTRAINT [PK__TimeGrai__CCAAE1D21CEC0E4B] PRIMARY KEY CLUSTERED 
(
	[TimeGrainID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ensamble_Config]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ensamble_Config](
	[ConfigID] [smallint] IDENTITY(1,1) NOT NULL,
	[ElementID] [smallint] NOT NULL,
	[MetricTypeID] [smallint] NOT NULL,
	[ScheduleID] [smallint] NOT NULL,
	[TimeGrainID] [smallint] NOT NULL,
	[SourceSystemDT_FieldName] [sysname] NULL,
	[GroupBy_FieldName] [sysname] NULL,
	[AggregateValue_FieldName] [nvarchar](512) NULL,
	[AggregationTypeID] [smallint] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK__Ensamble__C3BC333C1CDB1399] PRIMARY KEY CLUSTERED 
(
	[ConfigID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_EnsambleMetric_RowCount]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [dbo].[vw_EnsambleMetric_RowCount]
AS

SELECT 
	sq.[ElementID]
,	ee.[ElementFullyQualified]
,	ee.[ElementServerName]
,	ee.[ElementDatabaseName]
,	ee.[ElementSchemaName]
,	ee.[ElementEntityName]
,	sq.[MetricTypeID]
,	emt.[MetricTypeCode]
,	ec.[TimeGrainID]
,	etg.[TimeGrainCode]
,	etg.[TimeGrainDescription]
,	sq.[DateValue]
,	sq.[Row_Count]
FROM (
		SELECT 
			[ElementID]
		,	[MetricTypeID]
		,	[ConfigID]
		,	[DateValue]
		,	[Row_Count]
		,	[CreatedDT]
		,	DENSE_RANK() OVER (PARTITION BY em_rc.[ElementID] , em_rc.[MetricTypeID], em_rc.[ConfigID]  ORDER BY em_rc.[CreatedDT] DESC) AS rn
		  FROM [MetricsVault].[dbo].[EnsambleMetric_RowCount] AS em_rc
) AS sq
INNER JOIN 
	[dbo].[Ensamble_Element] AS ee
	ON ee.[ElementID] = sq.[ElementID]
INNER JOIN
	[dbo].[Ensamble_MetricType] AS emt
	ON emt.[MetricTypeID] = sq.[MetricTypeID]
INNER JOIN 
	[dbo].[Ensamble_Config] AS ec
	ON ec.[ConfigID] = sq.[ConfigID]
INNER JOIN 
	[dbo].[Ensamble_Timegrain] AS etg
	ON etg.[TimeGrainID] = ec.[TimeGrainID]
WHERE
	sq.rn = 1

  
GO
/****** Object:  View [dbo].[vw_EnsambleMetric_RowCount_TEST]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [dbo].[vw_EnsambleMetric_RowCount_TEST]
AS

SELECT 
	sq.[ElementID]
,	ee.[ElementFullyQualified]
,	sq.[MetricTypeID]
,	emt.[MetricTypeCode]
,	ec.[TimeGrainID]
,	etg.[TimeGrainCode]
,	etg.[TimeGrainDescription]
,	sq.[DateValue]
,	sq.[Row_Count]
,	sq.[CreatedDT]
FROM (
		SELECT 
			[ElementID]
		,	[MetricTypeID]
		,	[ConfigID]
		,	[DateValue]
		,	[Row_Count]
		,	[CreatedDT]
		,	DENSE_RANK() OVER (PARTITION BY em_rc.[ElementID] , em_rc.[MetricTypeID], em_rc.[ConfigID]  ORDER BY em_rc.[CreatedDT] DESC) AS rn
		  FROM [MetricsVault].[dbo].[EnsambleMetric_RowCount] AS em_rc
) AS sq
INNER JOIN 
	[dbo].[Ensamble_Element] AS ee
	ON ee.[ElementID] = sq.[ElementID]
INNER JOIN
	[dbo].[Ensamble_MetricType] AS emt
	ON emt.[MetricTypeID] = sq.[MetricTypeID]
INNER JOIN 
	[dbo].[Ensamble_Config] AS ec
	ON ec.[ConfigID] = sq.[ConfigID]
INNER JOIN 
	[dbo].[Ensamble_Timegrain] AS etg
	ON etg.[TimeGrainID] = ec.[TimeGrainID]
WHERE
	sq.rn = 1

  
GO
/****** Object:  Table [dbo].[EnsambleMetric_OutdatedBusinessKey]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnsambleMetric_OutdatedBusinessKey](
	[MetricID] [bigint] IDENTITY(1,1) NOT NULL,
	[EnsambleID] [smallint] NOT NULL,
	[ServerName] [sysname] NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[EntityName] [sysname] NOT NULL,
	[EntityType] [varchar](30) NULL,
	[MetricCode] [varchar](30) NOT NULL,
	[MetricName] [varchar](50) NOT NULL,
	[OutdatedLinks_Count] [int] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK__Ensamble__EnsambleMetric_OutdatedBusinessKey] PRIMARY KEY CLUSTERED 
(
	[MetricID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_OutdatedBusinessKey]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_OutdatedBusinessKey]
AS
SELECT [MetricID]
      ,[EnsambleID]
      ,[ServerName]
      ,[DatabaseName]
      ,[SchemaName]
      ,[EntityName]
      ,[EntityType]
      ,[MetricCode]
      ,[MetricName]
      ,[OutdatedLinks_Count]
      ,[CreatedDT]
  FROM [MetricsVault].[dbo].[EnsambleMetric_OutdatedBusinessKey]
GO
/****** Object:  Table [dbo].[EnsambleMetric_OutdatedLinks]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnsambleMetric_OutdatedLinks](
	[MetricID] [bigint] IDENTITY(1,1) NOT NULL,
	[EnsambleID] [smallint] NOT NULL,
	[ServerName] [sysname] NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[EntityName] [sysname] NOT NULL,
	[EntityType] [varchar](30) NULL,
	[MetricCode] [varchar](30) NOT NULL,
	[MetricName] [varchar](50) NOT NULL,
	[OutdatedLinks_Count] [int] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK__Ensamble__EnsambleMetric_OutdatedLinks] PRIMARY KEY CLUSTERED 
(
	[MetricID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_OutdatedLinks]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_OutdatedLinks]
AS
SELECT *
  FROM [MetricsVault].[dbo].EnsambleMetric_OutdatedLinks
GO
/****** Object:  View [dbo].[vw_Ensamble]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_Ensamble]
AS
SELECT *
  FROM [MetricsVault].[dbo].EnsambleMetric_OutdatedLinks
GO
/****** Object:  View [dbo].[vw_EnsambleConfig]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_EnsambleConfig]
AS
SELECT *
  FROM [MetricsVault].[dbo].EnsambleMetric_OutdatedLinks
GO
/****** Object:  View [dbo].[vw_EnsambleSchedule]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_EnsambleSchedule]
AS
SELECT *
  FROM [MetricsVault].[dbo].EnsambleMetric_OutdatedLinks
GO
/****** Object:  UserDefinedFunction [dbo].[udf_split_String]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--/*
--	Written by: Emile Fraser
--	Date		:	2020-05-20
--	Function	:	Splits a string based on a delimeter and retuns a certain chunk based on the ChunkNumber (section)
--	Note		:	If you request ChunkNumber it will return ALL chunks in a table format (for speed 9999 chunk max will be returned)
--*/
CREATE   FUNCTION [dbo].[udf_split_String] (
	@StringValue	NVARCHAR(MAX)
,   @Delimiter		NVARCHAR(30)
,	@ChunkNumber	SMALLINT
)
RETURNS TABLE
WITH SCHEMABINDING AS

RETURN

	-- Creates a massive hash table values to hold the different start and end points of the string sent
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
		Item = SUBSTRING(@StringValue, s.ChunkStart, ISNULL(NULLIF(CHARINDEX(@Delimiter, @StringValue, s.ChunkStart), 0) - s.ChunkStart, 8000))
--	,	ChunkStart
--	,	ChunkNumber
	FROM 
		cteStart s
	WHERE
		ChunkNumber BETWEEN @ChunkNumber AND IIF(@ChunkNumber <> 0, @ChunkNumber, 9999) -- Done like this to accomplish chunnk ranges
GO
/****** Object:  Table [dbo].[Ensamble]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ensamble](
	[EnsambleID] [smallint] IDENTITY(1,1) NOT NULL,
	[EnsambleName] [varchar](100) NOT NULL,
	[BaseObjectName] [sysname] NULL,
 CONSTRAINT [PK_Ensamble] PRIMARY KEY CLUSTERED 
(
	[EnsambleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ensamble_AggregationType]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ensamble_AggregationType](
	[AggregationTypeID] [smallint] IDENTITY(1,1) NOT NULL,
	[AggregationTypeCode] [varchar](30) NOT NULL,
	[AggregationTypeName] [sysname] NULL,
	[AggregationDefinition] [nvarchar](200) NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK__Ensamble_AggregationType] PRIMARY KEY CLUSTERED 
(
	[AggregationTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ensamble_ElementType]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ensamble_ElementType](
	[ElementTypeID] [smallint] IDENTITY(1,1) NOT NULL,
	[ElementTypeCode] [varchar](30) NOT NULL,
	[ElementTypeName] [varchar](100) NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Ensamble_ElementType] PRIMARY KEY CLUSTERED 
(
	[ElementTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ensamble_Join]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ensamble_Join](
	[EnsambleID] [smallint] IDENTITY(1,1) NOT NULL,
	[EnsambleName] [varchar](100) NOT NULL,
	[BaseObjectName] [sysname] NULL,
	[HUB] [smallint] NULL,
	[REF] [smallint] NULL,
	[LINK_PARENT] [smallint] NULL,
	[LINK_CHILD] [smallint] NULL,
	[SAT] [smallint] NULL,
	[REFSAT] [smallint] NULL,
	[BRIDGE] [smallint] NULL,
	[HLINK] [smallint] NULL,
	[TLINK] [smallint] NULL,
	[STATSAT] [smallint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ensamble_Log]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ensamble_Log](
	[LogID] [bigint] IDENTITY(1,1) NOT NULL,
	[MetricProcedureCalled] [sysname] NOT NULL,
	[ConfigID] [smallint] NOT NULL,
	[LogStatusTypeID] [smallint] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ensamble_LogStatusType]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ensamble_LogStatusType](
	[LogStatusTypeID] [smallint] NOT NULL,
	[LogStatusTypeCode] [varchar](30) NOT NULL,
	[LogStatusTypeDescription] [varchar](100) NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK__Ensamble__9866D1BD5E4524E7] PRIMARY KEY CLUSTERED 
(
	[LogStatusTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ensamble_StatusCode]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ensamble_StatusCode](
	[StatusCodeID] [smallint] IDENTITY(1,1) NOT NULL,
	[StatusCode] [smallint] NOT NULL,
	[StatusCodeName] [varchar](30) NOT NULL,
	[StatusCodeDescription] [varchar](100) NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[StatusCodeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnsambleMetric_AggregateValue]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnsambleMetric_AggregateValue](
	[MetricID] [bigint] IDENTITY(1,1) NOT NULL,
	[ElementID] [smallint] NOT NULL,
	[MetricTypeID] [smallint] NOT NULL,
	[ConfigID] [smallint] NOT NULL,
	[DateValue] [datetime2](7) NULL,
	[AggregateValue] [float] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK__EnsambleMetric_AggregateValue] PRIMARY KEY CLUSTERED 
(
	[MetricID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnsambleMetric_HubSatelliteEffectivity]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnsambleMetric_HubSatelliteEffectivity](
	[MetricID] [bigint] IDENTITY(1,1) NOT NULL,
	[EnsambleID] [smallint] NOT NULL,
	[ServerName] [sysname] NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[EntityName] [sysname] NOT NULL,
	[EntityType] [varchar](30) NOT NULL,
	[MetricCode] [varchar](30) NOT NULL,
	[MetricName] [varchar](50) NOT NULL,
	[MetricValue] [float] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MetricID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnsambleMetric_HubToSatEffectivity]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnsambleMetric_HubToSatEffectivity](
	[MetricID] [bigint] IDENTITY(1,1) NOT NULL,
	[EnsambleID] [smallint] NOT NULL,
	[ServerName] [sysname] NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[EntityName] [sysname] NOT NULL,
	[EntityType] [varchar](30) NOT NULL,
	[MetricCode] [varchar](30) NOT NULL,
	[MetricName] [varchar](50) NOT NULL,
	[MetricValue] [float] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MetricID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnsambleMetric_LastLoadDT]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnsambleMetric_LastLoadDT](
	[MetricID] [bigint] IDENTITY(1,1) NOT NULL,
	[ElementID] [smallint] NOT NULL,
	[MetricTypeID] [smallint] NOT NULL,
	[ConfigID] [smallint] NOT NULL,
	[DateValue] [datetime2](7) NULL,
	[LastLoadDT] [int] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_EnsambleMetric_LastLoadDT] PRIMARY KEY CLUSTERED 
(
	[MetricID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnsambleMetric_LastSourceSystemDT]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnsambleMetric_LastSourceSystemDT](
	[MetricID] [bigint] IDENTITY(1,1) NOT NULL,
	[ElementID] [smallint] NOT NULL,
	[MetricTypeID] [smallint] NOT NULL,
	[ConfigID] [smallint] NOT NULL,
	[DateValue] [datetime2](7) NULL,
	[LastSourceSystemDT] [int] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_EnsambleMetric_LastSourceSystemDT] PRIMARY KEY CLUSTERED 
(
	[MetricID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnsambleMetric_LinkEffectivity]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnsambleMetric_LinkEffectivity](
	[MetricID] [bigint] IDENTITY(1,1) NOT NULL,
	[EnsambleID] [smallint] NOT NULL,
	[ServerName] [sysname] NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[EntityName] [sysname] NOT NULL,
	[EntityType] [varchar](30) NOT NULL,
	[MetricCode] [varchar](30) NOT NULL,
	[MetricName] [varchar](50) NOT NULL,
	[MetricValue] [float] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MetricID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnsambleMetric_RowCount_Active]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnsambleMetric_RowCount_Active](
	[MetricID] [bigint] IDENTITY(1,1) NOT NULL,
	[ElementID] [smallint] NOT NULL,
	[MetricTypeID] [smallint] NOT NULL,
	[ConfigID] [smallint] NOT NULL,
	[DateValue] [datetime2](7) NULL,
	[Row_Count] [int] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK__RowCountActive__56105645E51B67AD] PRIMARY KEY CLUSTERED 
(
	[MetricID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Ensamble_AggregationType] ADD  CONSTRAINT [DF_Ensamble_AggregationType_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
GO
ALTER TABLE [dbo].[Ensamble_AggregationType] ADD  CONSTRAINT [DF_Ensamble_AggregationType_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Ensamble_Config] ADD  CONSTRAINT [DF__Ensamble___Creat__42E1EEFE]  DEFAULT (getdate()) FOR [CreatedDT]
GO
ALTER TABLE [dbo].[Ensamble_Config] ADD  CONSTRAINT [DF__Ensamble___IsAct__43D61337]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Ensamble_Element] ADD  DEFAULT (getdate()) FOR [CreatedDT]
GO
ALTER TABLE [dbo].[Ensamble_Element] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Ensamble_ElementType] ADD  DEFAULT (getdate()) FOR [CreatedDT]
GO
ALTER TABLE [dbo].[Ensamble_ElementType] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Ensamble_LogStatusType] ADD  CONSTRAINT [DF__Ensamble___Creat__55009F39]  DEFAULT (getdate()) FOR [CreatedDT]
GO
ALTER TABLE [dbo].[Ensamble_LogStatusType] ADD  CONSTRAINT [DF__Ensamble___IsAct__55F4C372]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Ensamble_MetricType] ADD  CONSTRAINT [DF__Ensamble___Creat__74AE54BC]  DEFAULT (getdate()) FOR [CreatedDT]
GO
ALTER TABLE [dbo].[Ensamble_MetricType] ADD  CONSTRAINT [DF__Ensamble___IsAct__75A278F5]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Ensamble_StatusCode] ADD  DEFAULT (getdate()) FOR [CreatedDT]
GO
ALTER TABLE [dbo].[Ensamble_StatusCode] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Ensamble_Config]  WITH CHECK ADD FOREIGN KEY([AggregationTypeID])
REFERENCES [dbo].[Ensamble_AggregationType] ([AggregationTypeID])
GO
ALTER TABLE [dbo].[Ensamble_Config]  WITH CHECK ADD FOREIGN KEY([ElementID])
REFERENCES [dbo].[Ensamble_Element] ([ElementID])
GO
ALTER TABLE [dbo].[Ensamble_Config]  WITH CHECK ADD FOREIGN KEY([MetricTypeID])
REFERENCES [dbo].[Ensamble_MetricType] ([MetricTypeID])
GO
ALTER TABLE [dbo].[Ensamble_Config]  WITH CHECK ADD FOREIGN KEY([ScheduleID])
REFERENCES [dbo].[Ensamble_Timegrain] ([TimeGrainID])
GO
ALTER TABLE [dbo].[Ensamble_Config]  WITH CHECK ADD FOREIGN KEY([TimeGrainID])
REFERENCES [dbo].[Ensamble_Timegrain] ([TimeGrainID])
GO
ALTER TABLE [dbo].[Ensamble_Element]  WITH CHECK ADD FOREIGN KEY([ElementTypeID])
REFERENCES [dbo].[Ensamble_ElementType] ([ElementTypeID])
GO
ALTER TABLE [dbo].[Ensamble_Element]  WITH CHECK ADD FOREIGN KEY([EnsambleID])
REFERENCES [dbo].[Ensamble] ([EnsambleID])
GO
ALTER TABLE [dbo].[Ensamble_Log]  WITH CHECK ADD FOREIGN KEY([ConfigID])
REFERENCES [dbo].[Ensamble_Config] ([ConfigID])
GO
ALTER TABLE [dbo].[Ensamble_Log]  WITH CHECK ADD FOREIGN KEY([LogStatusTypeID])
REFERENCES [dbo].[Ensamble_LogStatusType] ([LogStatusTypeID])
GO
ALTER TABLE [dbo].[EnsambleMetric_AggregateValue]  WITH CHECK ADD FOREIGN KEY([ConfigID])
REFERENCES [dbo].[Ensamble_Config] ([ConfigID])
GO
ALTER TABLE [dbo].[EnsambleMetric_AggregateValue]  WITH CHECK ADD FOREIGN KEY([ElementID])
REFERENCES [dbo].[Ensamble_Element] ([ElementID])
GO
ALTER TABLE [dbo].[EnsambleMetric_AggregateValue]  WITH CHECK ADD FOREIGN KEY([MetricTypeID])
REFERENCES [dbo].[Ensamble_MetricType] ([MetricTypeID])
GO
ALTER TABLE [dbo].[EnsambleMetric_LastLoadDT]  WITH CHECK ADD FOREIGN KEY([ConfigID])
REFERENCES [dbo].[Ensamble_Config] ([ConfigID])
GO
ALTER TABLE [dbo].[EnsambleMetric_LastLoadDT]  WITH CHECK ADD FOREIGN KEY([ElementID])
REFERENCES [dbo].[Ensamble_Element] ([ElementID])
GO
ALTER TABLE [dbo].[EnsambleMetric_LastLoadDT]  WITH CHECK ADD FOREIGN KEY([MetricTypeID])
REFERENCES [dbo].[Ensamble_MetricType] ([MetricTypeID])
GO
ALTER TABLE [dbo].[EnsambleMetric_LastSourceSystemDT]  WITH CHECK ADD FOREIGN KEY([ConfigID])
REFERENCES [dbo].[Ensamble_Config] ([ConfigID])
GO
ALTER TABLE [dbo].[EnsambleMetric_LastSourceSystemDT]  WITH CHECK ADD FOREIGN KEY([ElementID])
REFERENCES [dbo].[Ensamble_Element] ([ElementID])
GO
ALTER TABLE [dbo].[EnsambleMetric_LastSourceSystemDT]  WITH CHECK ADD FOREIGN KEY([MetricTypeID])
REFERENCES [dbo].[Ensamble_MetricType] ([MetricTypeID])
GO
ALTER TABLE [dbo].[EnsambleMetric_RowCount]  WITH CHECK ADD FOREIGN KEY([ConfigID])
REFERENCES [dbo].[Ensamble_Config] ([ConfigID])
GO
ALTER TABLE [dbo].[EnsambleMetric_RowCount]  WITH CHECK ADD FOREIGN KEY([ElementID])
REFERENCES [dbo].[Ensamble_Element] ([ElementID])
GO
ALTER TABLE [dbo].[EnsambleMetric_RowCount]  WITH CHECK ADD FOREIGN KEY([MetricTypeID])
REFERENCES [dbo].[Ensamble_MetricType] ([MetricTypeID])
GO
ALTER TABLE [dbo].[EnsambleMetric_RowCount_Active]  WITH CHECK ADD FOREIGN KEY([ConfigID])
REFERENCES [dbo].[Ensamble_Config] ([ConfigID])
GO
ALTER TABLE [dbo].[EnsambleMetric_RowCount_Active]  WITH CHECK ADD FOREIGN KEY([ElementID])
REFERENCES [dbo].[Ensamble_Element] ([ElementID])
GO
ALTER TABLE [dbo].[EnsambleMetric_RowCount_Active]  WITH CHECK ADD FOREIGN KEY([MetricTypeID])
REFERENCES [dbo].[Ensamble_MetricType] ([MetricTypeID])
GO
/****** Object:  StoredProcedure [dbo].[sp_handle_EnsambleMetric]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Written By: Emile Fraser
	Date: 2020-05-20
	Function: Acts as the central handler of the Metrics Vault Population. Gets configs, 
				constructs the proc to execute in VARCHAR format and then finally execute and logs the 
					execution of the procedure

	Execution Example:

	DECLARE 
		@ServerName			SYSNAME			= 'TSABISQL02\STAGSSIS'
	,	@DatabaseName		SYSNAME			= 'DataVault'
	,	@SchemaName			SYSNAME			= 'RAW'
	,	@ProcedureName		SYSNAME			= 'sp_loadhub_XT_Terminal'

	EXEC [dbo].[sp_handle_EnsambleMetric]
		@ServerName							= @ServerName
	,	@DatabaseName						= @DatabaseName
	,	@SchemaName							= @SchemaName	
	,	@ProcedureName						= @ProcedureName
*/

-- Inserts plain count of rows to Ensambles
CREATE     PROCEDURE [dbo].[sp_handle_EnsambleMetric]
	@ServerName							SYSNAME
,	@DatabaseName						SYSNAME
,	@SchemaName							SYSNAME
,	@ProcedureName						SYSNAME
AS
BEGIN
	-- Dynamic SQL level 1 
	DECLARE 
		@sql_statement					NVARCHAR(MAX)
	,	@sql_parameter					NVARCHAR(MAX)
	,	@sql_message					NVARCHAR(MAX)
	,	@sql_crlf						NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_tab						NVARCHAR(1) = CHAR(9)
	,	@sql_isdebug					BIT = 1
	,	@sql_isexecute					BIT = 1

	-- Dynamic SQL level 2 (Inception phase)
	DECLARE 
		@sql_statement_incep			NVARCHAR(MAX)
	,	@sql_parameter_incep			NVARCHAR(MAX)

	---- Inception Variables used to get the passthough parameters
	DECLARE 
		@AggregateValue_FieldName NVARCHAR(MAX) 
	,	@AggregationTypeID NVARCHAR(MAX) 
	,	@GroupBy_FieldName NVARCHAR(MAX) 


	DECLARE  
		@ElementID						SMALLINT
	,	@EnsambleID						SMALLINT
	,	@EnsambleName					VARCHAR(100)
	,	@EntityType						VARCHAR(30)
	,	@DataEntityName					SYSNAME
	,	@FullyQualifiedEntityName		NVARCHAR(523)   -- (128 * 4) + (2 * 4) + (1 * 3)  -- SYSNAME + BRACKEETS + DOTS

	DECLARE 
		@config_cursor					CURSOR
	,	@MetricTypeID					SMALLINT
	,	@ScheduleID						SMALLINT
	,	@TimegrainID					SMALLINT
	,	@ConfigID						SMALLINT
	,	@MetricProcedureName			SYSNAME
	,	@Additional_Parameters			NVARCHAR(MAX)
	,	@Additional_Parameters_Declare	NVARCHAR(MAX)
	,	@Additional_Parameters_Inject	NVARCHAR(MAX)
	,	@Additional_Parameters_Output	NVARCHAR(MAX)
	,	@Additional_Parameters_Incep	NVARCHAR(MAX)
	,	@return_status					SMALLINT

	-- Sets the DT that  
	DECLARE @CreatedDT DATETIME2(7) = GETDATE()
	DECLARE @CurrentLogStatus SMALLINT = 0

	-- Gets the Entity type being loaded by the Procedure as well as the entity ultimately loaded 
	SET @EntityType			= (SELECT UPPER(REPLACE(Item, 'load','')) FROM  dbo.udf_split_String(@ProcedureName,'_',2))
	SET @EnsambleName		= (SELECT Item FROM dbo.udf_split_String(@ProcedureName,'_',4))
	SET @DataEntityName		= @EntityType + '_' + @EnsambleName

	-- Fully Qualified Name to figure out on what entity to run the test and then what ElementID relates to the FullyQualifiedName
	SET @FullyQualifiedEntityName = CONCAT_WS('.', QUOTENAME(@ServerName), QUOTENAME(@DatabaseName), QUOTENAME(@SchemaName), QUOTENAME(@DataEntityName))
	SET @ElementID = (SELECT ElementID FROM dbo.Ensamble_Element WHERE [ElementFullyQualified] = @FullyQualifiedEntityName)
	
	IF (@sql_isdebug = 1)
	BEGIN
		SET @sql_message = '## Debug ##: @FullyQualifiedEntityName = ' + @FullyQualifiedEntityName + ' (@ElementID = ' + CONVERT(NVARCHAR(MAX), @ElementID) + ')'
		RAISERROR(@sql_message, 0 , 1) WITH NOWAIT
	END

	-- Now Get all the Configs that are set for this specific Element, as well as the metrics they relate to
	-- The MetricTypeID is needed to figure out what parameters to send to the ultimate procedures
	SET @config_cursor = CURSOR FOR 
	SELECT 
		ec.[ConfigID]
	,	ec.[MetricTypeID]
	FROM 
		[MetricsVault].[dbo].[Ensamble_Config] AS ec
	WHERE
		ec.[ElementID] = @ElementID
	AND	
		ec.[IsActive] = 1

	OPEN @config_cursor
	
	FETCH NEXT FROM @config_cursor
	INTO @ConfigID, @MetricTypeID

	-- Start loopoing throught the metrics one for one, combine the test they need to run
	-- Fire the test and then logs the Execution status of the tests run
	WHILE (@@FETCH_STATUS = 0)
	BEGIN

		IF (@sql_isdebug = 1)
		BEGIN
			SET @sql_message = '## Debug ##: @config_cursor with ' + '@ConfigID = ' + CONVERT(NVARCHAR(MAX), @ConfigID) + ' & ' + '@MetricTypeID = ' + CONVERT(NVARCHAR(MAX), @MetricTypeID)
			RAISERROR(@sql_message, 0 , 1) WITH NOWAIT
		END

		-- Gets the procedure name to be executed as well as any additional fields we will require
		-- to perform the tests (any group by, value fields specified)
		SELECT 
			@MetricProcedureName = emt.ProcedureName
		,	@Additional_Parameters = emt.AdditionalParameters
		FROM 
			dbo.Ensamble_MetricType AS emt
		WHERE 
			MetricTypeID =  @MetricTypeID

		-- Prints out the ProcName and the Additional params needed
		-- Multiple Additional parameters are possible as well as whether they are mandatory denoted by {} or optional denoted by []
		IF (@sql_isdebug = 1)
		BEGIN
			SET @sql_message = '## Debug ##: @ConfigID = ' + @MetricProcedureName + ' & ' + '@Additional_Parameters = ' + CONVERT(NVARCHAR(MAX), @Additional_Parameters)
			RAISERROR(@sql_message, 0 , 1) WITH NOWAIT
		END
		

		--SELECT * FROM udf_split_String('{Value_FieldName},{AggregationTypeID},[GroupBy_FieldName]',',', 0)
		--DECLARE @Additional_Parameters_Inject NVARCHAR(MAX)
		SET @Additional_Parameters_Inject = ''
		SELECT      @Additional_Parameters_Inject = @Additional_Parameters_Inject 
					+  '@' + REPLACE(REPLACE(REPLACE(REPLACE(Item, '{',''),'}',''),'[',''),']','') 
					+ ' = ' 
					+ QUOTENAME(REPLACE(REPLACE(REPLACE(REPLACE(Item, '{',''),'}',''),'[',''),']',''))
					+ ', ' + CHAR(13) + REPLICATE(CHAR(9), 5)
		FROM dbo.udf_split_String(@Additional_Parameters,',', 0)	

		-- Grab the comma
		SET @Additional_Parameters_Inject = SUBSTRING(@Additional_Parameters_Inject, 1, LEN(@Additional_Parameters_Inject) - 8) 
		--SELECT @Additional_Parameters_Inject


		-- Gets the Additional Parameters we will need from the relevant config columns
		-- These can also contain multiple values (liek the GroupBy_FieldName)
		SET @sql_statement = N'
			SELECT ' + CHAR(13) + REPLICATE(CHAR(9), 5) +
				@Additional_Parameters_Inject + '
			FROM 
				dbo.Ensamble_Config
			WHERE
				ConfigID = @ConfigID'

		IF(@sql_isdebug = 1)
			RAISERROR(@sql_statement, 0, 1)

		-- Need to declare the dynamic parameters to be passed to next procedure in the current scope, othewise we cant do a passthrough
		--SET @Additional_Parameters_Declare = 

		-- This is done to be able to produce the sql_parameter portion of the query to execute
		-- We will have varying columns that we will need data in 
		SET @Additional_Parameters_Output = ''
		SELECT @Additional_Parameters_Output = @Additional_Parameters_Output 
					+ ', ' + '@' + REPLACE(REPLACE(REPLACE(REPLACE(Item, '{',''),'}',''),'[',''),']','') + ' NVARCHAR(MAX) OUTPUT'
		FROM 
			dbo.udf_split_String(@Additional_Parameters,',', 0)	

		SET @sql_parameter = N'@ConfigID SMALLINT' + @Additional_Parameters_Output

		
		-- Here due to a sliding number of parmeters specified and returned will have to do deep. Inception phase, dynamic inside dynamic
		--Need to first construct the inception parameters (easier to actually)
		SET @Additional_Parameters_Incep = ''
		SELECT @Additional_Parameters_Incep = @Additional_Parameters_Incep
				+ ', @' 
				+ REPLACE(REPLACE(REPLACE(REPLACE(Item, '{',''),'}',''),'[',''),']','') 
				+ ' = ' 
				+ '@'
				+ REPLACE(REPLACE(REPLACE(REPLACE(Item, '{',''),'}',''),'[',''),']','') 
				+ ' OUTPUT' 
				+ CHAR(13) + REPLICATE(CHAR(9), 4)
		FROM 
			dbo.udf_split_String(@Additional_Parameters,',', 0)

		-- Enough level 1, time to go level 2
		IF(@sql_isexecute = 1)
		BEGIN

			-- Time to go into the dream
			SET @sql_statement_incep = '				
				EXEC sp_executesql 
					  @stmt		= N''' + REPLICATE(CHAR(9),4) + @sql_statement + '''
					, @param	= N''' + @sql_parameter + '''
					, @ConfigID	= N''' + CONVERT(NVARCHAR(MAX), @ConfigID) + '''' + CHAR(13) +
					REPLICATE(CHAR(9), 4) + @Additional_Parameters_Incep

			IF(@sql_isdebug = 1)
				RAISERROR(@sql_statement_incep, 0, 1)

			SET @sql_parameter_incep = N'@ConfigID SYSNAME, @AggregateValue_FieldName SYSNAME OUTPUT, @AggregationTypeID SMALLINT OUTPUT, @GroupBy_FieldName SYSNAME OUTPUT'

			-- All prepped, time to fire our config driven, varying parameter taking and giving amazeballs dynamic procedure
			EXEC @return_status = sp_executesql 
							@stmt						=	@sql_statement_incep
					,		@param						=	@sql_parameter_incep
					,		@ConfigID					=	@ConfigID
					,		@AggregateValue_FieldName	=	@AggregateValue_FieldName OUTPUT
					,		@AggregationTypeID			=	@AggregationTypeID OUTPUT
					,		@GroupBy_FieldName			=	@GroupBy_FieldName OUTPUT
			
		
			SELECT @AggregateValue_FieldName AS PAR_AggregateValue_FieldName, @AggregationTypeID AS PAR_AggregationTypeID, @GroupBy_FieldName AS PAR_GroupBy_FieldName

		-- Write the Open Log Position to the Logfile
		EXEC dbo.sp_insert_Ensamble_Log
			@MetricProcedureCalled	=	@MetricProcedureName	
		,	@ConfigID				=	@ConfigID
		,	@LogStatusTypeID		=	0


		---- Now finally compose the test string to execute and fire
		-- First start with the part of the string that goes accross all types
		SET @sql_statement = 'EXEC ' +    QUOTENAME(N'dbo') + '.' + QUOTENAME(@MetricProcedureName) + @sql_crlf + @sql_tab + 
									N'    @ConfigID' + N' = ''' + CONVERT(NVARCHAR(5), @ConfigID) + N'''' + @sql_crlf + @sql_tab 
									

		-- Then 1 for one go through the other columns too , and concatente
		-- Field not present, concatenate to NULL, and ISNULL to blank value before concatenation
		SET @sql_statement += ISNULL(N', @AggregateValue_FieldName' + N' = ''' + @AggregateValue_FieldName + N'' + CHAR(13),  '')
		SET @sql_statement += ISNULL(N', @AggregationTypeID' + N' = ''' + @AggregationTypeID + N'' + CHAR(13),  '')
		SET @sql_statement += ISNULL(N', @GroupBy_FieldName' + N' = ''' + @GroupBy_FieldName + N'' + CHAR(13),  '')

		SET @sql_parameter = N''

		IF(@sql_isdebug = 1)
			RAISERROR(@sql_statement, 0, 1)



		-- EXECUTES the Actual Metric Capturing
		--EXEC @return_status = sp_executesql 
		--				@stmt  = @sql_statement
			--		,	@param = @sql_parameter


		-- If any error is returned (non 0 @retrun status, set error to -1) 
		SET @return_status = IIF(@return_status <> 0, -1, 1)

		-- Write the Close Log Position to the Logfile
			EXEC dbo.sp_insert_Ensamble_Log
				@MetricProcedureCalled	=	@MetricProcedureName	
			,	@ConfigID				=	@ConfigID
			,	@LogStatusTypeID		=	@return_status
		
		END

		FETCH NEXT FROM @config_cursor
		INTO @ConfigID, @MetricTypeID
		
	END
END
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_Ensamble_Log]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[sp_insert_Ensamble_Log] (
	@MetricProcedureCalled	SYSNAME	
,	@ConfigID				SMALLINT
,	@LogStatusTypeID		SMALLINT
)
AS

DECLARE @CurrentDT DATETIME2(7) = GETDATE()

INSERT INTO [MetricsVault].[dbo].[Ensamble_Log] (
	[MetricProcedureCalled]
,	[ConfigID]
,	[LogStatusTypeID]
,	[CreatedDT]
)
SELECT 
	@MetricProcedureCalled
,	@ConfigID
,	@LogStatusTypeID
,	@CurrentDT
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_EnsambleMetric_AggregatedValue]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
	Written by	: Emile Fraser		
	Date		: 2020-05-20
	Function	: To Capture and log Value based aggregated data at point in time for various ensambles

	Sample Execution:
	DECLARE 
			@ConfigID				SMALLINT		= 11
,			@Value_FieldName		NVARCHAR(MAX)   = 'TerminalCodeID'
,			@AggregationTypeID		SMALLINT		= 1
,			@GroupByFieldName		NVARCHAR(MAX)   = NULL

	EXEC [dbo].[sp_insert_EsambleMetric_Value]
							@ConfigID			=	@ConfigID
						,	@Value_FieldName	=	@Value_FieldName
						,	@AggregationTypeID	=	@AggregationTypeID
						,	@GroupByFieldName	=	@GroupByFieldName
*/
CREATE       PROCEDURE [dbo].[sp_insert_EnsambleMetric_AggregatedValue]
	@ConfigID				SMALLINT
,	@Value_FieldName		NVARCHAR(MAX)
,	@AggregationTypeID		SMALLINT
,	@GroupByFieldName		NVARCHAR(MAX)	= NULL		-- THIS A OPTIONAL FIELD
AS
BEGIN
	DECLARE @sql_statement	NVARCHAR(MAX)
	DECLARE @sql_parameter	NVARCHAR(MAX)
	DECLARE @sql_message	NVARCHAR(MAX)
	DECLARE @sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	DECLARE @sql_tab		NVARCHAR(1) = CHAR(9)
	DECLARE @sql_debug		BIT = 0
	DECLARE @sql_execute	BIT = 1
	DECLARE @count			INT
	DECLARE @EnsambleID		SMALLINT
	DECLARE @EntityType		VARCHAR(30)

	-- Sets the DT of the Current Insert 
	DECLARE @CreatedDT DATETIME2(7) = GETDATE()

	SELECT @ConfigID AS par_ConfigID, @Value_FieldName AS par_Value_FieldName, @AggregationTypeID AS par_AggregationTypeID, @GroupByFieldName AS par_GroupByFieldName

	
	---- Inserts the Count into the Metric Table
	--INSERT INTO 
	--	[dbo].[EnsambleMetric_RowCount] (
	--	  	[EnsambleID]
	--	  ,	[ServerName]
	--	  ,	[DatabaseName]
	--	  ,	[SchemaName]
	--	  ,	[EntityName]
	--	  ,	[EntityType]
	--	  ,	[MetricCode]
	--	  ,	[MetricName]
	--	  ,	[Row_Count]
	--	  ,	[CreatedDT]
	--)
	--SELECT 
	--	EnsambleID		= @EnsambleID
	--,	ServerName		= @@SERVERNAME
	--,	DatabaseName	= @DatabaseName
	--,	SchemaName		= @SchemaName
	--,	EntityName		= @EntityName
	--,	EntityType		= @EntityType
	--,	MetricCode		= 'RC' 
	--,	MetricName		= 'Row Count'
	--,	Row_Count		= @count
	--,	CreatedDT		= @CreatedDT
END
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_EnsambleMetric_Hub_Sat_JoinEffectivity]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	DECLARE 
		@ConfigID			SMALLINT		=	14

	EXEC [dbo].[sp_insert_EnsambleMetric_Hub_Sat_JoinEffectivity]
		@ConfigID			= @ConfigID
*/

-- Inserts plain count of rows to Ensambles
CREATE      PROCEDURE [dbo].[sp_insert_EnsambleMetric_Hub_Sat_JoinEffectivity]
	@ConfigID				SMALLINT
AS
BEGIN
	-- Dyanamic SQL
	DECLARE
		@sql_statement	NVARCHAR(MAX)
	,	@sql_parameter	NVARCHAR(MAX)
	,	@sql_message	NVARCHAR(MAX)
	,	@sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_tab		NVARCHAR(1) = CHAR(9)
	,	@sql_debug		BIT = 0
	,	@sql_execute	BIT = 1
	
	-- Parameters related to the ConfigID
	DECLARE 
		@EnsambleID		SMALLINT
	,	@EntityType		VARCHAR(30)
	,	@GroupByCode	NVARCHAR(MAX) 
	,	@TimeGrainCode	SYSNAME

	-- Parameters related to Ensamble and Element
	DECLARE		
		@EnsambleName	NVARCHAR(100)
	,	@ServerName		SYSNAME			= NULL
	,	@DatabaseName	SYSNAME
	,	@SchemaName		SYSNAME
	,	@EntityName		SYSNAME
	

	-- Sets the DT of the Current Insert 
	DECLARE @CreatedDT DATETIME2(7) = GETDATE()


	DECLARE 
		@ElementID				SMALLINT
	,	@MetricTypeID			SMALLINT
	,	@TimeGrainID			SMALLINT
	--,	@GroupByFieldName		SYSNAME

	SELECT 
		@ElementID				=	ec.ElementID
	,	@MetricTypeID			=	ec.MetricTypeID
	,	@TimeGrainID			=	ec.TimeGrainID
	--,	@GroupByFieldName		=	ec.GroupByFieldName
	FROM 
		dbo.Ensamble_Config AS ec
	WHERE
		ConfigID = @ConfigID



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
/*
	-- GET TIME GRAIN VALUE
	-- IF ALL JUST USE DATE @CreatedDT AND NO GROUP BY FUNCTION
	SET @TimeGrainCode  = (SELECT TimeGrainCode FROM dbo.[Ensamble_Timegrain] WHERE [TimeGrainID] = @TimeGrainID)
	IF(@TimeGrainCode = 'ALL')
	BEGIN
		SET @GroupByCode = '@CreatedDT'
	END
	ELSE
	BEGIN
		SET @GroupByCode = (SELECT [dbo].[usp_get_GroupBy](@GroupByFieldName, @TimeGrainID))
	END

	-- OTHERWISE USE GROUP BY FUNCTION
	DECLARE @DateValue NVARCHAR(MAX)
	
	SET @sql_statement = N'
		INSERT INTO 
			[dbo].[EnsambleMetric_RowCount] (
		  		[ElementID]
			  ,	[MetricTypeID]
			  , [ConfigID]
			  ,	[DateValue]
			  ,	[Row_Count]
			  ,	[CreatedDT]
		)
		SELECT 
			ElementID		= '   + CONVERT(NVARCHAR(5), @ElementID)	+ ' 
		,	MetricTypeID	= '   + CONVERT(NVARCHAR(5), @MetricTypeID) + '
		,	ConfigID		= '	  + CONVERT(NVARCHAR(5), @ConfigID) + '
		,	DateValue		= '   + IIF(@TimeGrainCode = 'ALL', '''' + CONVERT(NVARCHAR(27), @CreatedDT) + '''', @GroupByCode) + '
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
	END
	*/






END
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_EnsambleMetric_LastLoadDT]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Written by	: Emile Fraser	
	Date		: 2020-05-20
	Function	: Inserts the Last Load Date Time for the specific config that is passed to the procedure. This
					will look at LoadDT as its default, as it serves as our internal time of loading. For the last
						DateTime source data was actually updated, please refer to dbo.sp_insert_EnsambleMetric_LastSourceSystemDT
	
	Sample Execution:

	DECLARE 
		@ConfigID			SMALLINT		=	10

	EXEC [dbo].[sp_insert_EnsambleMetric_LastLoadDT]
		@ConfigID							= @ConfigID

*/

-- Inserts plain count of rows to Ensambles
CREATE    PROCEDURE [dbo].[sp_insert_EnsambleMetric_LastLoadDT]
	@ConfigID				SMALLINT 
AS
BEGIN
	-- Dyanamic SQL
	DECLARE
		@sql_statement	NVARCHAR(MAX)
	,	@sql_parameter	NVARCHAR(MAX)
	,	@sql_message	NVARCHAR(MAX)
	,	@sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_tab		NVARCHAR(1) = CHAR(9)
	,	@sql_debug		BIT = 0
	,	@sql_execute	BIT = 1
	
	-- Parameters related to the ConfigID
	DECLARE 
		@EnsambleID		SMALLINT
	,	@EntityType		VARCHAR(30)
	,	@GroupByCode	NVARCHAR(MAX) 
	,	@TimeGrainCode	SYSNAME

	-- Parameters related to Ensamble and Element
	DECLARE		
		@EnsambleName	NVARCHAR(100)
	,	@ServerName		SYSNAME			= NULL
	,	@DatabaseName	SYSNAME
	,	@SchemaName		SYSNAME
	,	@EntityName		SYSNAME

	-- Sets the DT of the Current Insert 
	DECLARE @CreatedDT DATETIME2(7) = GETDATE()

	DECLARE 
		@ElementID				SMALLINT
	,	@MetricTypeID			SMALLINT
	,	@TimeGrainID			SMALLINT
	--,	@GroupByFieldName		SYSNAME

	SELECT 
		@ElementID				=	ec.ElementID
	,	@MetricTypeID			=	ec.MetricTypeID
	,	@TimeGrainID			=	ec.TimeGrainID
	--,	@GroupByFieldName		=	ec.GroupByFieldName
	FROM 
		dbo.Ensamble_Config AS ec
	WHERE
		ConfigID = @ConfigID


	-- Get the Ensamble Element Details
	SELECT
		@ServerName		=	es.ElementServerName
	,	@DatabaseName	=	es.ElementDatabaseName
	,	@SchemaName		=	es.ElementSchemaName
	,	@EntityName		=	es.ElementEntityName
	FROM 
		dbo.Ensamble_Element AS es
	WHERE
		ElementID = @ElementID

	-- Inserts the Last Load DT into the Table
	SET @sql_statement = N'
		INSERT INTO 
			[dbo].[EnsambleMetric_LastLoadDT] (
		  		[ElementID]
			  ,	[MetricTypeID]
			  , [ConfigID]
			  ,	[DateValue]
			  ,	[LastLoadDT]
			  ,	[CreatedDT]
		)
		SELECT 
			[ElementID]		= '   + CONVERT(NVARCHAR(5), @ElementID)	+ ' 
		,	[MetricTypeID]	= '   + CONVERT(NVARCHAR(5), @MetricTypeID) + '
		,	[ConfigID]		= '	  + CONVERT(NVARCHAR(5), @ConfigID) + '
		,	[DateValue]		= '   + IIF(@TimeGrainCode = 'ALL', '''' + CONVERT(NVARCHAR(27), @CreatedDT) + '''', @GroupByCode) + '
		,	[LastLoadDT]	= MAX([LoadDT]) 
		,	[CreatedDT]		= ''' + CONVERT(NVARCHAR(27), @CreatedDT) + '''
		FROM ' + @sql_crlf + REPLICATE(@sql_tab, 3) +
			IIF(@ServerName IS NOT NULL, QUOTENAME(@ServerName) + '.', '') + 
			QUOTENAME(@DatabaseName) + '.' +
			QUOTENAME(@SchemaName) + '.' +
			QUOTENAME(@EntityName)

END
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_EnsambleMetric_LastSourceSystemDT]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
		Written by	: Emile Fraser	
	Date		: 2020-05-20
	Function	: Inserts the Last Load Date Time for the specific config that is passed to the procedure. This
					will look for the last data point based on a column containing a source system generated date
	
	Sample Execution:

	DECLARE 
		@ConfigID			SMALLINT		=	11

	EXEC [dbo].[sp_insert_EnsambleMetric_LastSourceSystemDT]
		@ConfigID							= @ConfigID

*/

-- Inserts last source system date time from the dataset provided
CREATE    PROCEDURE [dbo].[sp_insert_EnsambleMetric_LastSourceSystemDT]
	@ConfigID				SMALLINT 
AS
BEGIN
	-- Dyanamic SQL
	DECLARE
		@sql_statement	NVARCHAR(MAX)
	,	@sql_parameter	NVARCHAR(MAX)
	,	@sql_message	NVARCHAR(MAX)
	,	@sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_tab		NVARCHAR(1) = CHAR(9)
	,	@sql_debug		BIT = 0
	,	@sql_execute	BIT = 1
	
	-- Parameters related to the ConfigID
	DECLARE 
		@EnsambleID		SMALLINT
	,	@EntityType		VARCHAR(30)
	,	@GroupByCode	NVARCHAR(MAX) 
	,	@TimeGrainCode	SYSNAME

	-- Parameters related to Ensamble and Element
	DECLARE		
		@EnsambleName	NVARCHAR(100)
	,	@ServerName		SYSNAME			= NULL
	,	@DatabaseName	SYSNAME
	,	@SchemaName		SYSNAME
	,	@EntityName		SYSNAME

	-- Sets the DT of the Current Insert 
	DECLARE @CreatedDT DATETIME2(7) = GETDATE()

	DECLARE 
		@ElementID				SMALLINT
	,	@MetricTypeID			SMALLINT
	,	@TimeGrainID			SMALLINT
	,	@SourceSystemDT_Field	SYSNAME

	SELECT 
		@ElementID				=	ec.ElementID
	,	@MetricTypeID			=	ec.MetricTypeID
	,	@TimeGrainID			=	ec.TimeGrainID
	,	@SourceSystemDT_Field	=	ec.SourceSystemDT_Field
	FROM 
		dbo.Ensamble_Config AS ec
	WHERE
		ConfigID = @ConfigID


	-- Get the Ensamble Element Details
	SELECT
		@ServerName		=	es.ElementServerName
	,	@DatabaseName	=	es.ElementDatabaseName
	,	@SchemaName		=	es.ElementSchemaName
	,	@EntityName		=	es.ElementEntityName
	FROM 
		dbo.Ensamble_Element AS es
	WHERE
		ElementID = @ElementID

	-- Inserts the Last Load DT into the Table
	SET @sql_statement = N'
		INSERT INTO 
			[dbo].[EnsambleMetric_LastSourceSystemDT] (
		  		[ElementID]
			  ,	[MetricTypeID]
			  , [ConfigID]
			  ,	[DateValue]
			  ,	[LastSourceSystemDT]
			  ,	[CreatedDT]
		)
		SELECT 
			[ElementID]				= '   + CONVERT(NVARCHAR(5), @ElementID)	+ ' 
		,	[MetricTypeID]			= '   + CONVERT(NVARCHAR(5), @MetricTypeID) + '
		,	[ConfigID]				= '	  + CONVERT(NVARCHAR(5), @ConfigID) + '
		,	[DateValue]				= '   + IIF(@TimeGrainCode = 'ALL', '''' + CONVERT(NVARCHAR(27), @CreatedDT) + '''', @GroupByCode) + '
		,	[LastSourceSystemDT]	= MAX(' + QUOTENAME(@SourceSystemDT_Field) + ')
		,	[CreatedDT]				= ''' + CONVERT(NVARCHAR(27), @CreatedDT) + '''
		FROM ' + @sql_crlf + REPLICATE(@sql_tab, 3) +
			IIF(@ServerName IS NOT NULL, QUOTENAME(@ServerName) + '.', '') + 
			QUOTENAME(@DatabaseName) + '.' +
			QUOTENAME(@SchemaName) + '.' +
			QUOTENAME(@EntityName)

END
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_EnsambleMetric_RowCount]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	DECLARE 
		@ConfigID			SMALLINT		=	9
	,	@GroupByFieldName	NVARCHAR(MAX)	=	'LoadDT'

	EXEC [dbo].[sp_insert_EnsambleMetric_RowCount]
		@ConfigID			= @ConfigID
	,	@GroupByFieldName	= @GroupByFieldName
*/

-- Inserts plain count of rows to Ensambles
CREATE     PROCEDURE [dbo].[sp_insert_EnsambleMetric_RowCount]
	@ConfigID				SMALLINT
,	@GroupByFieldName		NVARCHAR(MAX)
AS
BEGIN
	-- Dyanamic SQL
	DECLARE
		@sql_statement	NVARCHAR(MAX)
	,	@sql_parameter	NVARCHAR(MAX)
	,	@sql_message	NVARCHAR(MAX)
	,	@sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_tab		NVARCHAR(1) = CHAR(9)
	,	@sql_debug		BIT = 0
	,	@sql_execute	BIT = 1
	
	-- Parameters related to the ConfigID
	DECLARE 
		@EnsambleID		SMALLINT
	,	@EntityType		VARCHAR(30)
	,	@GroupByCode	NVARCHAR(MAX) 
	,	@TimeGrainCode	SYSNAME

	-- Parameters related to Ensamble and Element
	DECLARE		
		@EnsambleName	NVARCHAR(100)
	,	@ServerName		SYSNAME			= NULL
	,	@DatabaseName	SYSNAME
	,	@SchemaName		SYSNAME
	,	@EntityName		SYSNAME
	

	-- Sets the DT of the Current Insert 
	DECLARE @CreatedDT DATETIME2(7) = GETDATE()


	DECLARE 
		@ElementID				SMALLINT
	,	@MetricTypeID			SMALLINT
	,	@TimeGrainID			SMALLINT
	--,	@GroupByFieldName		SYSNAME

	SELECT 
		@ElementID				=	ec.ElementID
	,	@MetricTypeID			=	ec.MetricTypeID
	,	@TimeGrainID			=	ec.TimeGrainID
	--,	@GroupByFieldName		=	ec.GroupByFieldName
	FROM 
		dbo.Ensamble_Config AS ec
	WHERE
		ConfigID = @ConfigID



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
		SET @GroupByCode = (SELECT [dbo].[usp_get_GroupBy](@GroupByFieldName, @TimeGrainID))
	END

	-- OTHERWISE USE GROUP BY FUNCTION
	DECLARE @DateValue NVARCHAR(MAX)
	
	SET @sql_statement = N'
		INSERT INTO 
			[dbo].[EnsambleMetric_RowCount] (
		  		[ElementID]
			  ,	[MetricTypeID]
			  , [ConfigID]
			  ,	[DateValue]
			  ,	[Row_Count]
			  ,	[CreatedDT]
		)
		SELECT 
			ElementID		= '   + CONVERT(NVARCHAR(5), @ElementID)	+ ' 
		,	MetricTypeID	= '   + CONVERT(NVARCHAR(5), @MetricTypeID) + '
		,	ConfigID		= '	  + CONVERT(NVARCHAR(5), @ConfigID) + '
		,	DateValue		= '   + IIF(@TimeGrainCode = 'ALL', '''' + CONVERT(NVARCHAR(27), @CreatedDT) + '''', @GroupByCode) + '
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
	END







END
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_EnsambleMetric_RowCount_Active]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	DECLARE 
		@ConfigID			SMALLINT		=	1
	,	@GroupByFieldName	NVARCHAR(MAX)	=	'LoadDT'

	EXEC [dbo].[sp_insert_EnsambleMetric_RowCount_Active]
		@ConfigID = @ConfigID
*/

-- Inserts plain count of rows to Ensambles
CREATE       PROCEDURE [dbo].[sp_insert_EnsambleMetric_RowCount_Active]
	@ConfigID				SMALLINT
,	@GroupByFieldName		NVARCHAR(MAX)
AS
BEGIN
	DECLARE
		@sql_statement	NVARCHAR(MAX)
	,	@sql_parameter	NVARCHAR(MAX)
	,	@sql_message	NVARCHAR(MAX)
	,	@sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_tab		NVARCHAR(1) = CHAR(9)
	,	@sql_debug		BIT = 1
	,	@sql_execute	BIT = 1
	
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


	DECLARE 
		@ElementID				SMALLINT
	,	@MetricTypeID			SMALLINT
	,	@TimeGrainID			SMALLINT
	--,	@GroupByFieldName		SYSNAME

	SELECT 
		@ElementID				=	ec.ElementID
	,	@MetricTypeID			=	ec.MetricTypeID
	,	@TimeGrainID			=	ec.TimeGrainID
	--,	@GroupByFieldName		=	ec.GroupByFieldName
	FROM 
		dbo.Ensamble_Config AS ec
	WHERE
		ConfigID = @ConfigID



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
		SET @GroupByCode = (SELECT [dbo].[usp_get_GroupBy](@GroupByFieldName, @TimeGrainID))
	END

	-- OTHERWISE USE GROUP BY FUNCTION
	DECLARE @DateValue NVARCHAR(MAX)
	
	SET @sql_statement = N'
		INSERT INTO 
			[dbo].[EnsambleMetric_RowCount_Active] (
		  		[ElementID]
			  ,	[MetricTypeID]
			  , [ConfigID]
			  ,	[DateValue]
			  ,	[Row_Count]
			  ,	[CreatedDT]
		)
		SELECT 
			ElementID		= '   + CONVERT(NVARCHAR(5), @ElementID)	+ ' 
		,	MetricTypeID	= '   + CONVERT(NVARCHAR(5), @MetricTypeID) + '
		,	ConfigID		= '	  + CONVERT(NVARCHAR(5), @ConfigID) + '
		,	DateValue		= '   + IIF(@TimeGrainCode = 'ALL', '''' + CONVERT(NVARCHAR(27), @CreatedDT) + '''', @GroupByCode) + '
		,	Row_Count		= COUNT(1)  
		,	CreatedDT		= ''' + CONVERT(NVARCHAR(27), @CreatedDT) + '''
		FROM ' + @sql_crlf + REPLICATE(@sql_tab, 3) +
			IIF(@ServerName IS NOT NULL, QUOTENAME(@ServerName) + '.', '') + 
			QUOTENAME(@DatabaseName) + '.' +
			QUOTENAME(@SchemaName) + '.' +
			QUOTENAME(@EntityName) + @sql_crlf + '
		WHERE
			[LoadEndDT] IS NULL'


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
	END







END
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_EnsambleMetric_Sat_Hub_JoinEffectivity]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	DECLARE 
		@ConfigID			SMALLINT		=	14

	EXEC [dbo].[sp_insert_EnsambleMetric_Sat_Hub_JoinEffectivity]
		@ConfigID			= @ConfigID
*/

-- Inserts plain count of rows to Ensambles
CREATE      PROCEDURE [dbo].[sp_insert_EnsambleMetric_Sat_Hub_JoinEffectivity]
	@ConfigID				SMALLINT
AS
BEGIN
	-- Dyanamic SQL
	DECLARE
		@sql_statement	NVARCHAR(MAX)
	,	@sql_parameter	NVARCHAR(MAX)
	,	@sql_message	NVARCHAR(MAX)
	,	@sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_tab		NVARCHAR(1) = CHAR(9)
	,	@sql_debug		BIT = 0
	,	@sql_execute	BIT = 1
	
	-- Parameters related to the ConfigID
	DECLARE 
		@EnsambleID		SMALLINT
	,	@EntityType		VARCHAR(30)
	,	@GroupByCode	NVARCHAR(MAX) 
	,	@TimeGrainCode	SYSNAME

	-- Parameters related to Ensamble and Element
	DECLARE		
		@EnsambleName	NVARCHAR(100)
	,	@ServerName		SYSNAME			= NULL
	,	@DatabaseName	SYSNAME
	,	@SchemaName		SYSNAME
	,	@EntityName		SYSNAME
	

	-- Sets the DT of the Current Insert 
	DECLARE @CreatedDT DATETIME2(7) = GETDATE()


	DECLARE 
		@ElementID				SMALLINT
	,	@MetricTypeID			SMALLINT
	,	@TimeGrainID			SMALLINT
	--,	@GroupByFieldName		SYSNAME

	SELECT 
		@ElementID				=	ec.ElementID
	,	@MetricTypeID			=	ec.MetricTypeID
	,	@TimeGrainID			=	ec.TimeGrainID
	--,	@GroupByFieldName		=	ec.GroupByFieldName
	FROM 
		dbo.Ensamble_Config AS ec
	WHERE
		ConfigID = @ConfigID



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
/*
	-- GET TIME GRAIN VALUE
	-- IF ALL JUST USE DATE @CreatedDT AND NO GROUP BY FUNCTION
	SET @TimeGrainCode  = (SELECT TimeGrainCode FROM dbo.[Ensamble_Timegrain] WHERE [TimeGrainID] = @TimeGrainID)
	IF(@TimeGrainCode = 'ALL')
	BEGIN
		SET @GroupByCode = '@CreatedDT'
	END
	ELSE
	BEGIN
		SET @GroupByCode = (SELECT [dbo].[usp_get_GroupBy](@GroupByFieldName, @TimeGrainID))
	END

	-- OTHERWISE USE GROUP BY FUNCTION
	DECLARE @DateValue NVARCHAR(MAX)
	
	SET @sql_statement = N'
		INSERT INTO 
			[dbo].[EnsambleMetric_RowCount] (
		  		[ElementID]
			  ,	[MetricTypeID]
			  , [ConfigID]
			  ,	[DateValue]
			  ,	[Row_Count]
			  ,	[CreatedDT]
		)
		SELECT 
			ElementID		= '   + CONVERT(NVARCHAR(5), @ElementID)	+ ' 
		,	MetricTypeID	= '   + CONVERT(NVARCHAR(5), @MetricTypeID) + '
		,	ConfigID		= '	  + CONVERT(NVARCHAR(5), @ConfigID) + '
		,	DateValue		= '   + IIF(@TimeGrainCode = 'ALL', '''' + CONVERT(NVARCHAR(27), @CreatedDT) + '''', @GroupByCode) + '
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
	END
	*/






END
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_LinkEffectivity]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
DECLARE 
	@EnsambleName	NVARCHAR(100)	= 'Terminal'
,	@ServerName		SYSNAME			= NULL
,	@DatabaseName	SYSNAME			= 'DataVault'
,	@SchemaName		SYSNAME			= 'raw'
,	@EntityName		SYSNAME			= 'HUB_Terminal'


EXEC [dbo].[sp_insert_EnsambleMetric_RowCount]
	@EnsambleName	= @EnsambleName
,	@DatabaseName	= @DatabaseName
,	@SchemaName		= @SchemaName	
,	@EntityName		= @EntityName
*/

-- Inserts plain count of rows to Ensambles
CREATE       PROCEDURE [dbo].[sp_insert_LinkEffectivity]
	@EnsambleName	NVARCHAR(100)
,	@ServerName		SYSNAME			= NULL
,	@DatabaseName	SYSNAME
,	@SchemaName		SYSNAME
,	@EntityName		SYSNAME
,	@ODSDatabaseName	SYSNAME
,	@ODSchemaName		SYSNAME
,	@ODSEntityName		SYSNAME
,	@ColumnVault	SYSNAME
,	@COlumnODS		SYSNAME
AS
BEGIN
	DECLARE @sql_statement	NVARCHAR(MAX)
	DECLARE @sql_parameter	NVARCHAR(MAX)
	DECLARE @sql_message	NVARCHAR(MAX)
	DECLARE @sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	DECLARE @sql_tab		NVARCHAR(1) = CHAR(9)
	DECLARE @sql_debug		BIT = 0
	DECLARE @sql_execute	BIT = 1
	DECLARE @count			INT
	DECLARE @EnsambleID		SMALLINT
	DECLARE @EntityType		VARCHAR(30)

	-- Sets the DT of the Current Insert 
	DECLARE @CreatedDT DATETIME2(7) = GETDATE()

	-- Get the Ensamble
	SET @EnsambleID = (
		SELECT 
			EnsambleID
		FROM 
			[MetricsVault].[dbo].[Ensamble]
		WHERE 
			EnsambleName = @EnsambleName
	)

	SET @EntityType = (
		SELECT 
			CASE 
				WHEN @DatabaseName LIKE '%ODS%'
					THEN 'SRC'
				WHEN SUBSTRING(@EntityName,1,3) = 'HUB'
					THEN 'HUB'
				WHEN SUBSTRING(@EntityName,1,3) = 'SAT'
					THEN 'SAT'
				WHEN SUBSTRING(@EntityName,1,3) = 'LINK'
					THEN 'LINK'
				WHEN SUBSTRING(@EntityName,1,6) = 'BRIDGE'
					THEN 'BRIDGE'
				WHEN SUBSTRING(@EntityName,1,7) = 'STATSAT'
					THEN 'STATSAT'
				WHEN SUBSTRING(@EntityName,1,5) = 'HLINK'
					THEN 'HLINK'
				WHEN SUBSTRING(@EntityName,1,3) = 'PIT'
					THEN 'PIT'
				WHEN SUBSTRING(@EntityName,1,3) = 'SAL'
					THEN 'SAL'
				WHEN SUBSTRING(@EntityName,1,6) = 'REFSAT'
					THEN 'REFSAT'
				WHEN SUBSTRING(@EntityName,1,6) = 'REF'
					THEN 'REF'
					ELSE 'UNK'
			END
			)

			DECLARE @Hub_Left SYSNAME = (SELECT SUBSTRING(REPLACE('LINK_XTGang_EmployeeContractor', 'LINK_',''), 1, CHARINDEX('_', REPLACE('LINK_XTGang_EmployeeContractor', 'LINK_','')) - 1))
			DECLARE @Hub_Right SYSNAME = (SELECT SUBSTRING(REPLACE('LINK_XTGang_EmployeeContractor', 'LINK_',''), CHARINDEX('_', REPLACE('LINK_XTGang_EmployeeContractor', 'LINK_','')) + 1, 100))
		
		--SELECT xt_e.EMP_EMPNO, xt_g.GNG_CODE, sq.GangCode
		--	FROM select * from ODS_XT900.dbo.vw_dv_TNAMaster_Employee AS xt_e
		--	INNER JOIN ODS_XT900.dbo.GANG AS xt_g
		--	ON xt_g.GNG_CODEID = xt_e.GNG_CODEID
		--	LEFT JOIN 
		--	(
		--	SELECT h_c.EmployeeNo, h_g.GangCode
		--	FROM [DataVault].[RAW].[LINK_XTGang_EmployeeContractor] AS l_xtg_empc
		--	INNER JOIN  [DataVault].[RAW].HUB_EmployeeContractor AS h_c
		--	ON h_c.HK_EmployeeContractor = l_xtg_empc.HK_EmployeeContractor
		--	INNER JOIN  [DataVault].[RAW].HUB_GANG AS h_g
		--	ON h_g.HK_GANG = l_xtg_empc.HK_GANG
		--	) AS sq
		--	ON  sq.EmployeeNo = xt_e.EMP_EMPNO
		--	WHERE  xt_g.GNG_CODE <> sq.GangCode
		/*
	SET @sql_statement = '
		SELECT 
			@count = COUNT(1)
		FROM ' + @sql_crlf + REPLICATE(@sql_tab, 3) +
			IIF(@ServerName IS NOT NULL, QUOTENAME(@ServerName) + '.', '') + 
			QUOTENAME(@DatabaseName) + '.' +
			QUOTENAME(@SchemaName) + '.' +
			QUOTENAME(@EntityName) + ' AS ods 
			LEFT JOIN
			(
				SELECT h_c.EmployeeNo, h_g.GangCode
			
			+ @sql_crlf + REPLICATE(@sql_tab, 3) +
			*/
	SET @sql_parameter = N'@count INT OUTPUT'

	IF(@sql_debug = 1)
		RAISERROR(@sql_statement, 0, 1)

	IF(@sql_execute = 1)
	BEGIN
		EXEC sp_executesql 
			@stmt  = @sql_statement
		,	@param = @sql_parameter
		,	@count = @count OUTPUT
	END

	
	-- Inserts the Count into the Metric Table
	INSERT INTO 
		[dbo].[EnsambleMetric_RowCount] (
		  	[EnsambleID]
		  ,	[ServerName]
		  ,	[DatabaseName]
		  ,	[SchemaName]
		  ,	[EntityName]
		  ,	[EntityType]
		  ,	[MetricCode]
		  ,	[MetricName]
		  ,	[Row_Count]
		  ,	[CreatedDT]
	)
	SELECT 
		EnsambleID		= @EnsambleID
	,	ServerName		= @@SERVERNAME
	,	DatabaseName	= @DatabaseName
	,	SchemaName		= @SchemaName
	,	EntityName		= @EntityName
	,	EntityType		= @EntityType
	,	MetricCode		= 'RC' 
	,	MetricName		= 'Row Count'
	,	Row_Count		= @count
	,	CreatedDT		= @CreatedDT
END
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_OutdatedBusinessKey]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
DECLARE 
	@EnsambleName	NVARCHAR(100)	= 'Terminal'
,	@ServerName		SYSNAME			= NULL
,	@DatabaseName	SYSNAME			= 'DataVault'
,	@SchemaName		SYSNAME			= 'raw'
,	@EntityName		SYSNAME			= 'HUB_Terminal'


EXEC [dbo].[sp_insert_EnsambleMetric_RowCount]
	@EnsambleName	= @EnsambleName
,	@DatabaseName	= @DatabaseName
,	@SchemaName		= @SchemaName	
,	@EntityName		= @EntityName
*/

-- Inserts plain count of rows to Ensambles
CREATE       PROCEDURE [dbo].[sp_insert_OutdatedBusinessKey]
	@EnsambleName	NVARCHAR(100)
,	@ServerName		SYSNAME			= NULL
,	@DatabaseName	SYSNAME
,	@SchemaName		SYSNAME
,	@EntityName		SYSNAME
,	@ODSDatabaseName	SYSNAME
,	@ODSchemaName		SYSNAME
,	@ODSEntityName		SYSNAME
,	@ColumnVault	SYSNAME
,	@COlumnODS		SYSNAME
AS
BEGIN
	DECLARE @sql_statement	NVARCHAR(MAX)
	DECLARE @sql_parameter	NVARCHAR(MAX)
	DECLARE @sql_message	NVARCHAR(MAX)
	DECLARE @sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	DECLARE @sql_tab		NVARCHAR(1) = CHAR(9)
	DECLARE @sql_debug		BIT = 0
	DECLARE @sql_execute	BIT = 1
	DECLARE @count			INT
	DECLARE @EnsambleID		SMALLINT
	DECLARE @EntityType		VARCHAR(30)

	-- Sets the DT of the Current Insert 
	DECLARE @CreatedDT DATETIME2(7) = GETDATE()

	-- Get the Ensamble
	SET @EnsambleID = (
		SELECT 
			EnsambleID
		FROM 
			[MetricsVault].[dbo].[Ensamble]
		WHERE 
			EnsambleName = @EnsambleName
	)

	SET @EntityType = (
		SELECT 
			CASE 
				WHEN @DatabaseName LIKE '%ODS%'
					THEN 'SRC'
				WHEN SUBSTRING(@EntityName,1,3) = 'HUB'
					THEN 'HUB'
				WHEN SUBSTRING(@EntityName,1,3) = 'SAT'
					THEN 'SAT'
				WHEN SUBSTRING(@EntityName,1,3) = 'LINK'
					THEN 'LINK'
				WHEN SUBSTRING(@EntityName,1,6) = 'BRIDGE'
					THEN 'BRIDGE'
				WHEN SUBSTRING(@EntityName,1,7) = 'STATSAT'
					THEN 'STATSAT'
				WHEN SUBSTRING(@EntityName,1,5) = 'HLINK'
					THEN 'HLINK'
				WHEN SUBSTRING(@EntityName,1,3) = 'PIT'
					THEN 'PIT'
				WHEN SUBSTRING(@EntityName,1,3) = 'SAL'
					THEN 'SAL'
				WHEN SUBSTRING(@EntityName,1,6) = 'REFSAT'
					THEN 'REFSAT'
				WHEN SUBSTRING(@EntityName,1,6) = 'REF'
					THEN 'REF'
					ELSE 'UNK'
			END
			)

			DECLARE @Hub_Left SYSNAME = (SELECT SUBSTRING(REPLACE('LINK_XTGang_EmployeeContractor', 'LINK_',''), 1, CHARINDEX('_', REPLACE('LINK_XTGang_EmployeeContractor', 'LINK_','')) - 1))
			DECLARE @Hub_Right SYSNAME = (SELECT SUBSTRING(REPLACE('LINK_XTGang_EmployeeContractor', 'LINK_',''), CHARINDEX('_', REPLACE('LINK_XTGang_EmployeeContractor', 'LINK_','')) + 1, 100))
		
		--SELECT xt_e.EMP_EMPNO, xt_g.GNG_CODE, sq.GangCode
		--	FROM select * from ODS_XT900.dbo.vw_dv_TNAMaster_Employee AS xt_e
		--	INNER JOIN ODS_XT900.dbo.GANG AS xt_g
		--	ON xt_g.GNG_CODEID = xt_e.GNG_CODEID
		--	LEFT JOIN 
		--	(
		--	SELECT h_c.EmployeeNo, h_g.GangCode
		--	FROM [DataVault].[RAW].[LINK_XTGang_EmployeeContractor] AS l_xtg_empc
		--	INNER JOIN  [DataVault].[RAW].HUB_EmployeeContractor AS h_c
		--	ON h_c.HK_EmployeeContractor = l_xtg_empc.HK_EmployeeContractor
		--	INNER JOIN  [DataVault].[RAW].HUB_GANG AS h_g
		--	ON h_g.HK_GANG = l_xtg_empc.HK_GANG
		--	) AS sq
		--	ON  sq.EmployeeNo = xt_e.EMP_EMPNO
		--	WHERE  xt_g.GNG_CODE <> sq.GangCode
		/*
	SET @sql_statement = '
		SELECT 
			@count = COUNT(1)
		FROM ' + @sql_crlf + REPLICATE(@sql_tab, 3) +
			IIF(@ServerName IS NOT NULL, QUOTENAME(@ServerName) + '.', '') + 
			QUOTENAME(@DatabaseName) + '.' +
			QUOTENAME(@SchemaName) + '.' +
			QUOTENAME(@EntityName) + ' AS ods 
			LEFT JOIN
			(
				SELECT h_c.EmployeeNo, h_g.GangCode
			
			+ @sql_crlf + REPLICATE(@sql_tab, 3) +
			*/
	SET @sql_parameter = N'@count INT OUTPUT'

	IF(@sql_debug = 1)
		RAISERROR(@sql_statement, 0, 1)

	IF(@sql_execute = 1)
	BEGIN
		EXEC sp_executesql 
			@stmt  = @sql_statement
		,	@param = @sql_parameter
		,	@count = @count OUTPUT
	END

	
	-- Inserts the Count into the Metric Table
	INSERT INTO 
		[dbo].[EnsambleMetric_RowCount] (
		  	[EnsambleID]
		  ,	[ServerName]
		  ,	[DatabaseName]
		  ,	[SchemaName]
		  ,	[EntityName]
		  ,	[EntityType]
		  ,	[MetricCode]
		  ,	[MetricName]
		  ,	[Row_Count]
		  ,	[CreatedDT]
	)
	SELECT 
		EnsambleID		= @EnsambleID
	,	ServerName		= @@SERVERNAME
	,	DatabaseName	= @DatabaseName
	,	SchemaName		= @SchemaName
	,	EntityName		= @EntityName
	,	EntityType		= @EntityType
	,	MetricCode		= 'RC' 
	,	MetricName		= 'Row Count'
	,	Row_Count		= @count
	,	CreatedDT		= @CreatedDT
END
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_OutdatedLinks]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
DECLARE 
	@EnsambleName	NVARCHAR(100)	= 'Terminal'
,	@ServerName		SYSNAME			= NULL
,	@DatabaseName	SYSNAME			= 'DataVault'
,	@SchemaName		SYSNAME			= 'raw'
,	@EntityName		SYSNAME			= 'HUB_Terminal'


EXEC [dbo].[sp_insert_EnsambleMetric_RowCount]
	@EnsambleName	= @EnsambleName
,	@DatabaseName	= @DatabaseName
,	@SchemaName		= @SchemaName	
,	@EntityName		= @EntityName
*/

-- Inserts plain count of rows to Ensambles
CREATE       PROCEDURE [dbo].[sp_insert_OutdatedLinks]
	@EnsambleName	NVARCHAR(100)
,	@ServerName		SYSNAME			= NULL
,	@DatabaseName	SYSNAME
,	@SchemaName		SYSNAME
,	@EntityName		SYSNAME
,	@ODSDatabaseName	SYSNAME
,	@ODSchemaName		SYSNAME
,	@ODSEntityName		SYSNAME
,	@ColumnVault	SYSNAME
,	@COlumnODS		SYSNAME
AS
BEGIN
	DECLARE @sql_statement	NVARCHAR(MAX)
	DECLARE @sql_parameter	NVARCHAR(MAX)
	DECLARE @sql_message	NVARCHAR(MAX)
	DECLARE @sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	DECLARE @sql_tab		NVARCHAR(1) = CHAR(9)
	DECLARE @sql_debug		BIT = 0
	DECLARE @sql_execute	BIT = 1
	DECLARE @count			INT
	DECLARE @EnsambleID		SMALLINT
	DECLARE @EntityType		VARCHAR(30)

	-- Sets the DT of the Current Insert 
	DECLARE @CreatedDT DATETIME2(7) = GETDATE()

	-- Get the Ensamble
	SET @EnsambleID = (
		SELECT 
			EnsambleID
		FROM 
			[MetricsVault].[dbo].[Ensamble]
		WHERE 
			EnsambleName = @EnsambleName
	)

	SET @EntityType = (
		SELECT 
			CASE 
				WHEN @DatabaseName LIKE '%ODS%'
					THEN 'SRC'
				WHEN SUBSTRING(@EntityName,1,3) = 'HUB'
					THEN 'HUB'
				WHEN SUBSTRING(@EntityName,1,3) = 'SAT'
					THEN 'SAT'
				WHEN SUBSTRING(@EntityName,1,3) = 'LINK'
					THEN 'LINK'
				WHEN SUBSTRING(@EntityName,1,6) = 'BRIDGE'
					THEN 'BRIDGE'
				WHEN SUBSTRING(@EntityName,1,7) = 'STATSAT'
					THEN 'STATSAT'
				WHEN SUBSTRING(@EntityName,1,5) = 'HLINK'
					THEN 'HLINK'
				WHEN SUBSTRING(@EntityName,1,3) = 'PIT'
					THEN 'PIT'
				WHEN SUBSTRING(@EntityName,1,3) = 'SAL'
					THEN 'SAL'
				WHEN SUBSTRING(@EntityName,1,6) = 'REFSAT'
					THEN 'REFSAT'
				WHEN SUBSTRING(@EntityName,1,6) = 'REF'
					THEN 'REF'
					ELSE 'UNK'
			END
			)

			DECLARE @Hub_Left SYSNAME = (SELECT SUBSTRING(REPLACE('LINK_XTGang_EmployeeContractor', 'LINK_',''), 1, CHARINDEX('_', REPLACE('LINK_XTGang_EmployeeContractor', 'LINK_','')) - 1))
			DECLARE @Hub_Right SYSNAME = (SELECT SUBSTRING(REPLACE('LINK_XTGang_EmployeeContractor', 'LINK_',''), CHARINDEX('_', REPLACE('LINK_XTGang_EmployeeContractor', 'LINK_','')) + 1, 100))
		
		--SELECT xt_e.EMP_EMPNO, xt_g.GNG_CODE, sq.GangCode
		--	FROM select * from ODS_XT900.dbo.vw_dv_TNAMaster_Employee AS xt_e
		--	INNER JOIN ODS_XT900.dbo.GANG AS xt_g
		--	ON xt_g.GNG_CODEID = xt_e.GNG_CODEID
		--	LEFT JOIN 
		--	(
		--	SELECT h_c.EmployeeNo, h_g.GangCode
		--	FROM [DataVault].[RAW].[LINK_XTGang_EmployeeContractor] AS l_xtg_empc
		--	INNER JOIN  [DataVault].[RAW].HUB_EmployeeContractor AS h_c
		--	ON h_c.HK_EmployeeContractor = l_xtg_empc.HK_EmployeeContractor
		--	INNER JOIN  [DataVault].[RAW].HUB_GANG AS h_g
		--	ON h_g.HK_GANG = l_xtg_empc.HK_GANG
		--	) AS sq
		--	ON  sq.EmployeeNo = xt_e.EMP_EMPNO
		--	WHERE  xt_g.GNG_CODE <> sq.GangCode
		/*
	SET @sql_statement = '
		SELECT 
			@count = COUNT(1)
		FROM ' + @sql_crlf + REPLICATE(@sql_tab, 3) +
			IIF(@ServerName IS NOT NULL, QUOTENAME(@ServerName) + '.', '') + 
			QUOTENAME(@DatabaseName) + '.' +
			QUOTENAME(@SchemaName) + '.' +
			QUOTENAME(@EntityName) + ' AS ods 
			LEFT JOIN
			(
				SELECT h_c.EmployeeNo, h_g.GangCode
			
			+ @sql_crlf + REPLICATE(@sql_tab, 3) +
			*/
	SET @sql_parameter = N'@count INT OUTPUT'

	IF(@sql_debug = 1)
		RAISERROR(@sql_statement, 0, 1)

	IF(@sql_execute = 1)
	BEGIN
		EXEC sp_executesql 
			@stmt  = @sql_statement
		,	@param = @sql_parameter
		,	@count = @count OUTPUT
	END

	
	-- Inserts the Count into the Metric Table
	INSERT INTO 
		[dbo].[EnsambleMetric_RowCount] (
		  	[EnsambleID]
		  ,	[ServerName]
		  ,	[DatabaseName]
		  ,	[SchemaName]
		  ,	[EntityName]
		  ,	[EntityType]
		  ,	[MetricCode]
		  ,	[MetricName]
		  ,	[Row_Count]
		  ,	[CreatedDT]
	)
	SELECT 
		EnsambleID		= @EnsambleID
	,	ServerName		= @@SERVERNAME
	,	DatabaseName	= @DatabaseName
	,	SchemaName		= @SchemaName
	,	EntityName		= @EntityName
	,	EntityType		= @EntityType
	,	MetricCode		= 'RC' 
	,	MetricName		= 'Row Count'
	,	Row_Count		= @count
	,	CreatedDT		= @CreatedDT
END
GO
/****** Object:  StoredProcedure [dbo].[sp_set_Ensamble_Config]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Written by	: Emile Fraser	
	Date		: 2020-05-20
	Function	: Insert or Updates new Ensamble Configs

	DECLARE @ElementID SMALLINT = (SELECT ElementID FROM dbo.Ensamble_Element WHERE ElementEntityName = 'HUB_Terminal')
	DECLARE @MetricTypeID SMALLINT = (SELECT MetricTypeID FROM dbo.Ensamble_MetricType WHERE MetricTypeCode = 'LASTLOADDT')
	DECLARE @ScheduleID SMALLINT = (SELECT TimeGrainID FROM dbo.Ensamble_Timegrain WHERE TimeGrainCode = 'ALL')
	DECLARE @TimeGrainID SMALLINT = (SELECT TimeGrainID FROM dbo.Ensamble_Timegrain WHERE TimeGrainCode = 'ALL')
	DECLARE @GroupByFieldName SYSNAME = NULL
	DECLARE @SourceSystemDT_Field SYSNAME = 'LoadDT'

	EXEC [dbo].[sp_set_Ensamble_Config] 
		@ConfigID = NULL
	,	@ElementID = @ElementID
	,	@MetricTypeID = @MetricTypeID
	,	@ScheduleID = @ScheduleID
	,	@TimeGrainID = @TimeGrainID
	,	@GroupByFieldName = @GroupByFieldName
	,	@SourceSystemDT_Field = SourceSystemDT_Field

*/
CREATE   PROCEDURE [dbo].[sp_set_Ensamble_Config]
	@ConfigID					SMALLINT	= NULL
,	@ElementID					SMALLINT	= NULL
,	@MetricTypeID				SMALLINT	= NULL
,	@ScheduleID					SMALLINT	= NULL
,	@TimeGrainID				SMALLINT	= NULL
,	@GroupByFieldName			SYSNAME		= NULL
,	@SourceSystemDT_Field		SYSNAME		= NULL
,	@IsActive					BIT			= NULL
AS 
BEGIN
	
	-- SET THE DATE TIME FOR THE UPDATE/INSERT
	DECLARE @CurrentDT DATETIME2(7) = GETDATE()

	-- First need to determine if this is an Insert/Update or a "Other"
	-- Check if this is Possibly update?
	IF EXISTS (
				SELECT 
					1
				FROM	
					[dbo].[Ensamble_Config]
				WHERE
					ElementID = @ElementID
				AND
					MetricTypeID = @MetricTypeID
				AND 
					ScheduleID = @ScheduleID
				AND
					TimeGrainID = @TimeGrainID
	) OR (
			@ConfigID IS NOT NULL
		AND
			EXISTS (
						SELECT 
							1
						FROM 
							[dbo].[Ensamble_Config]
						WHERE
							ConfigID = @ConfigID
			)
	)
	BEGIN

		UPDATE 
			[dbo].[Ensamble_Config]
		SET 
			[ElementID]				= COALESCE(@ElementID, [ElementID])
		,	[MetricTypeID]			= COALESCE(@MetricTypeID, [MetricTypeID])
		,	[ScheduleID]			= COALESCE(@ScheduleID, [ScheduleID])
		,	[TimeGrainID]			= COALESCE(@TimeGrainID, [TimeGrainID])
		,	[GroupByFieldName]		= @GroupByFieldName
		,	[SourceSystemDT_Field]  = @SourceSystemDT_Field
		,	[IsActive]				= COALESCE(@IsActive, [IsActive])
		,	[UpdatedDT]				= @CurrentDT
		WHERE
			[ConfigID] = @ConfigID

	END
	ELSE

	--INSERT 
	BEGIN
		IF( @ElementID IS NULL OR @MetricTypeID IS NULL OR @ScheduleID IS NULL OR @TimeGrainID IS NULL)
		-- ERRORNEOUS INSERT ATTEMPT
		BEGIN
			RAISERROR('Plese supply valid values for @ElementID, @MetricTypeID, @ScheduleID and @TimeGrainID', 0, 1) WITH NOWAIT
		END
		ELSE	
		BEGIN
		INSERT INTO 
			[dbo].[Ensamble_Config] (
				[ElementID]
			,	[MetricTypeID]
			,	[ScheduleID]
			,	[TimeGrainID]
			,	[GroupByFieldName]
			,	[SourceSystemDT_Field]
			)
			SELECT 
				@ElementID
			,	@MetricTypeID
			,	@ScheduleID
			,	@TimeGrainID
			,	@GroupByFieldName
			,	@SourceSystemDT_Field
		END
	END

END

	
GO
/****** Object:  StoredProcedure [dbo].[sp_set_Ensamble_Element]    Script Date: 2020/06/05 2:07:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Written by	: Emile Fraser	
	Date		: 2020-05-20
	Function	: Insert or Updates new Ensamble Elements
*/
CREATE PROCEDURE [dbo].[sp_set_Ensamble_Element]
	@ElementID					SMALLINT	= NULL
,	@EnsambleID					SMALLINT	= NULL
,	@ElementTypeID				SMALLINT	= NULL
,	@ElementServerName			SYSNAME		= @@SERVERNAME
,	@ElementDatabaseName		SYSNAME		= NULL
,	@ElementSchemaName			SYSNAME		= NULL
,	@ElementEntityName			SYSNAME		= NULL
,	@IsActive					BIT			= NULL
AS 
BEGIN
	
	-- SET THE DATE TIME FOR THE UPDATE/INSERT
	DECLARE @CurrentDT DATETIME2(7) = GETDATE()

	-- First need to determine if this is an Insert/Update or a "Other"
	-- Check if this is Possibly update?
	IF EXISTS (
				SELECT 
					1
				FROM	
					[dbo].[Ensamble_Element]
				WHERE
					[ElementTypeID] = @ElementTypeID
				AND
					[ElementServerName] = @ElementServerName
				AND 
					[ElementDatabaseName] = @ElementDatabaseName
				AND
					[ElementSchemaName] = @ElementSchemaName
				AND
					[ElementEntityName] = @ElementEntityName
	) OR (
			@ElementID IS NOT NULL
		AND
			EXISTS (
						SELECT 
							1
						FROM 
							[dbo].[Ensamble_Element]
						WHERE
							ElementID = @ElementID
			)
	)
	BEGIN

			UPDATE 
				[dbo].[Ensamble_Element]
			SET 
				[EnsambleID]			= COALESCE(@EnsambleID, [EnsambleID])
			,	[ElementTypeID]			= COALESCE(@ElementTypeID, [ElementTypeID])
			,	[ElementServerName]		= COALESCE(@ElementServerName, [ElementServerName])
			,	[ElementDatabaseName]	= COALESCE(@ElementDatabaseName, [ElementDatabaseName])
			,	[ElementSchemaName]		= COALESCE(@ElementSchemaName, [ElementSchemaName])
			,	[ElementEntityName]		= COALESCE(@ElementEntityName, [ElementEntityName])
			,	[UpdatedDT]				= @CurrentDT
			WHERE
				[ElementID] = @ElementID
				
	END

	ELSE

	--INSERT 
	BEGIN
		IF(@EnsambleID IS NULL OR @ElementTypeID IS NULL OR @ElementDatabaseName IS NULL OR @ElementSchemaName IS NULL OR @ElementEntityName IS NULL)
		-- ERRORNEOUS INSERT ATTEMPT
		BEGIN
			RAISERROR('Plese supply valid values for @EnsambleID, @ElementTypeID, @ElementDatabaseName, @ElementSchemaName and @ElementEntityName', 0, 1) WITH NOWAIT
		END
		ELSE	
		BEGIN
			INSERT INTO 
				[dbo].[Ensamble_Element] (
					[EnsambleID]
				,	[ElementTypeID]
				,	[ElementServerName]
				,	[ElementDatabaseName]
				,	[ElementSchemaName]
				,	[ElementEntityName]
			)
			SELECT 
				@EnsambleID
			,	@ElementTypeID
			,	ISNULL(@ElementServerName , @@SERVERNAME) 
			,	@ElementDatabaseName
			,	@ElementSchemaName
			,	@ElementEntityName
		END
	END

END

	
GO
