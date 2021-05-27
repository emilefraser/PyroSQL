SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[GenerateTimeDimension]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dimension].[GenerateTimeDimension] AS' 
END
GO
/*
	EXEC dimension.GenerateTimeDimension
*/
ALTER   PROCEDURE [dimension].[GenerateTimeDimension]
AS
BEGIN

	DROP TABLE IF EXISTS dimension.TimeDimension;

	CREATE TABLE dimension.TimeDimension (
		[TimeKey]               [INT] NOT NULL
	  , [Hour24]				[VARCHAR](2) NULL
	  , [Hour24Value]           [SMALLINT] NULL
	  , [Hour24Min]			[VARCHAR](5) NULL
	  , [Hour24Full]			[VARCHAR](8) NULL
	  , [Hour12Value]                  [SMALLINT] NULL
	  , [Hour12]           [VARCHAR](2) NULL
	  , [Hour12Min]        [VARCHAR](5) NULL
	  , [Hour12Full]       [VARCHAR](8) NULL
	  , [AmPmCode]               [SMALLINT] NULL
	  , [AmPm]             [VARCHAR](2) NOT NULL
	  , [MinuteValue]                  [SMALLINT] NULL
	  , [MinuteCode]             [SMALLINT] NULL
	  , [Minute]           [VARCHAR](2) NULL
	  , [MinuteFull24]     [VARCHAR](8) NULL
	  , [MinuteFull12]     [VARCHAR](8) NULL
	  , [Minute5Code]            [SMALLINT] NULL
	  , [Minute10Code]           [SMALLINT] NULL
	  , [Minute15Code]           [SMALLINT] NULL
	  , [Minute20Code]           [SMALLINT] NULL
	  , [Minute30Code]           [SMALLINT] NULL
	  , [SecondValue]                  [SMALLINT] NULL
	  , [Second]           [VARCHAR](2) NULL
	  , [FullTime_24]       [VARCHAR](8) NULL
	  , [FullTime_12]       [VARCHAR](8) NULL
	  , [FullTime]                [TIME](7) NULL
	  , CONSTRAINT [PK_DimTime_TimeKey] PRIMARY KEY CLUSTERED([TimeKey] ASC)
	)

	--Script for generating members (records) for Time Dimension:
	DECLARE @hour       INT
	DECLARE @minute     INT
	DECLARE @second     INT

	SET @hour = 0

	WHILE (@hour < 24)
	BEGIN
		SET @minute = 0
		WHILE (@minute < 60)
		BEGIN
			SET @second = 0

				INSERT INTO [dimension].[TimeDimension] (
					[TimeKey]
				  , [Hour24Value]
				  , [Hour24]
				  , [Hour24Min]
				  , [Hour24Full]
				  , [Hour12Value]
				  , [Hour12]
				  , [Hour12Min]
				  , [Hour12Full]
				  , [AmPmCode]
				  , [AmPm]
				  , [MinuteValue]
				  , [MinuteCode]
				  , [Minute]
				  , [MinuteFull24]
				  , [MinuteFull12]
				  , [Minute5Code]
				  , [Minute10Code]
				  , [Minute15Code]
				  , [Minute20Code]
				  , [Minute30Code]
				  , [SecondValue]
				  , [Second]
				  , [FullTime_24]
				  , [FullTime_12]
				  , [FullTime]
				)
				SELECT
					(@hour * 10000) + (@minute * 100) + @second AS [TimeKey]
				  , @hour AS [Hour24]
				  , RIGHT('0' + CONVERT(VARCHAR(2), @hour), 2) AS [Hour24Short]
				  , RIGHT('0' + CONVERT(VARCHAR(2), @hour), 2) + ':00' AS [Hour24Min]
				  , RIGHT('0' + CONVERT(VARCHAR(2), @hour), 2) + ':00:00' AS [Hour24Full]
				  , @hour % 12 AS [Hour12]
				  , RIGHT('0' + CONVERT(VARCHAR(2), @hour % 12), 2) AS [Hour12Short]
				  , RIGHT('0' + CONVERT(VARCHAR(2), @hour % 12), 2) + ':00' AS [Hour12Min]
				  , RIGHT('0' + CONVERT(VARCHAR(2), @hour % 12), 2) + ':00:00' AS [Hour12Full]
				  , @hour / 12 AS [AmPmCode]
				  , CASE
						WHEN
					@hour < 12
							THEN 'AM'
						ELSE 'PM'
					END AS [AmPm]
				  , @minute AS [Minute]
				  , (@hour * 100) + (@minute) AS [MinuteCode]
				  , RIGHT('0' + CONVERT(VARCHAR(2), @minute), 2) AS [MinuteShort]
				  , RIGHT('0' + CONVERT(VARCHAR(2), @hour), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @minute), 2) + ':00' AS [MinuteFull24]
				  , RIGHT('0' + CONVERT(VARCHAR(2), @hour % 12), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @minute), 2) + ':00' AS [MinuteFull12]
				  , ROUND(((60 * @hour) + (@minute)) / 5, 0) AS Minute5_Code
				  , ROUND(((60 * @hour) + (@minute)) / 10, 0) AS Minute10_Code
				  , ROUND(((60 * @hour) + (@minute)) / 15, 0) AS Minute15_Code
				  , ROUND(((60 * @hour) + (@minute)) / 20, 0) AS Minute20_Code
				  , ROUND(((60 * @hour) + (@minute)) / 30, 0) AS Minute30_Code
				  , @second AS [Second]
				  , RIGHT('0' + CONVERT(VARCHAR(2), @second), 2) AS [SecondShort]
				  , RIGHT('0' + CONVERT(VARCHAR(2), @hour), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @minute), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @second), 2) AS [FullTime24]
				  , RIGHT('0' + CONVERT(VARCHAR(2), @hour % 12), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @minute), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @second), 2) AS [FullTime12]
				  , CONVERT(TIME, RIGHT('0' + CONVERT(VARCHAR(2), @hour), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @minute), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @second), 2)) AS [FullTime]
			SET @minute = @minute + 1
		END

		SET @hour = @hour + 1

	END

	SELECT * FROM dimension.TimeDimension

END
GO
