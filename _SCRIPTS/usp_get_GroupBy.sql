/*
	Written By	: Emile Fraser
	Date		: 2020-05-24
	Function	: Generates the GROUP BY code for consumption by the Metric Procs
					when Time Grain is applied and a Balance by field is supplied
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER FUNCTION dbo.usp_get_GroupBy (	
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
								FORMAT(ISNULL(DATEPART(MONTH,	' + QUOTENAME(@GroupByDateFieldName) + ') / NULLIF(' + CONVERT(VARCHAR(2), @Months)	+ ', 0), 0),   ''00'') + ''-'' +
								FORMAT(ISNULL(DATEPART(DAY,		' + QUOTENAME(@GroupByDateFieldName) + ') / NULLIF(' + CONVERT(VARCHAR(2), @Days)	+ ', 0), 0),   ''00'') + '' '' + 
								FORMAT(ISNULL(DATEPART(HOUR,	' + QUOTENAME(@GroupByDateFieldName) + ') / NULLIF(' + CONVERT(VARCHAR(2), @Hours)	+ ', 0), 0),   ''00'') + '':'' +
								FORMAT(ISNULL(DATEPART(MINUTE,	' + QUOTENAME(@GroupByDateFieldName) + ') / NULLIF(' + CONVERT(VARCHAR(2), @Minutes)+ ', 0), 0),   ''00'')
		'

	RETURN @GroupByCode

END
GO

