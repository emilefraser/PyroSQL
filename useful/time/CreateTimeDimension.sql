DROP TABLE IF EXISTS [MASTER].[TimeDimension];
GO

CREATE TABLE [MASTER].[TimeDimension] (
    [TimeKey]                 [INT] NOT NULL
  , [Hour24]                  [SMALLINT] NULL
  , [Hour24_String]           [VARCHAR](2) NULL
  , [Hour24_MinString]        [VARCHAR](5) NULL
  , [Hour24_FullString]       [VARCHAR](8) NULL
  , [Hour12]                  [SMALLINT] NULL
  , [Hour12_String]           [VARCHAR](2) NULL
  , [Hour12_MinString]        [VARCHAR](5) NULL
  , [Hour12_FullString]       [VARCHAR](8) NULL
  , [AMPM_Code]               [SMALLINT] NULL
  , [AMPM_String]             [VARCHAR](2) NOT NULL
  , [Minute]                  [SMALLINT] NULL
  , [Minute_Code]             [SMALLINT] NULL
  , [Minute_String]           [VARCHAR](2) NULL
  , [Minute_FullString24]     [VARCHAR](8) NULL
  , [Minute_FullString12]     [VARCHAR](8) NULL
  , [Minute5_Code]            [SMALLINT] NULL
  , [Minute10_Code]           [SMALLINT] NULL
  , [Minute15_Code]           [SMALLINT] NULL
  , [Minute20_Code]           [SMALLINT] NULL
  , [Minute30_Code]           [SMALLINT] NULL
  , [Second]                  [SMALLINT] NULL
  , [Second_String]           [VARCHAR](2) NULL
  , [FullTime_String24]       [VARCHAR](8) NULL
  , [FullTime_String12]       [VARCHAR](8) NULL
  , [FullTime]                [TIME](7) NULL
  , CONSTRAINT [PK_DimTime] PRIMARY KEY CLUSTERED([TimeKey] ASC)
    WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY]


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
            INSERT INTO [MASTER].[TimeDimension] (
                [TimeKey]
              , [Hour24]
              , [Hour24_String]
              , [Hour24_MinString]
              , [Hour24_FullString]
              , [Hour12]
              , [Hour12_String]
              , [Hour12_MinString]
              , [Hour12_FullString]
              , [AMPM_Code]
              , [AMPM_String]
              , [Minute]
              , [Minute_Code]
              , [Minute_String]
              , [Minute_FullString24]
              , [Minute_FullString12]
              , [Minute5_Code]
              , [Minute10_Code]
              , [Minute15_Code]
              , [Minute20_Code]
              , [Minute30_Code]
              , [Second]
              , [Second_String]
              , [FullTime_String24]
              , [FullTime_String12]
              , [FullTime]
            )
            SELECT
                (@hour * 10000) + (@minute * 100) + @second AS [TimeKey]
              , @hour AS [Hour24]
              , RIGHT('0' + CONVERT(VARCHAR(2), @hour), 2) AS [Hour24ShortString]
              , RIGHT('0' + CONVERT(VARCHAR(2), @hour), 2) + ':00' AS [Hour24MinString]
              , RIGHT('0' + CONVERT(VARCHAR(2), @hour), 2) + ':00:00' AS [Hour24FullString]
              , @hour % 12 AS [Hour12]
              , RIGHT('0' + CONVERT(VARCHAR(2), @hour % 12), 2) AS [Hour12ShortString]
              , RIGHT('0' + CONVERT(VARCHAR(2), @hour % 12), 2) + ':00' AS [Hour12MinString]
              , RIGHT('0' + CONVERT(VARCHAR(2), @hour % 12), 2) + ':00:00' AS [Hour12FullString]
              , @hour / 12 AS [AmPmCode]
              , CASE
                    WHEN
                @hour < 12
                        THEN 'AM'
                    ELSE 'PM'
                END AS [AmPmString]
              , @minute AS [Minute]
              , (@hour * 100) + (@minute) AS [MinuteCode]
              , RIGHT('0' + CONVERT(VARCHAR(2), @minute), 2) AS [MinuteShortString]
              , RIGHT('0' + CONVERT(VARCHAR(2), @hour), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @minute), 2) + ':00' AS [MinuteFullString24]
              , RIGHT('0' + CONVERT(VARCHAR(2), @hour % 12), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @minute), 2) + ':00' AS [MinuteFullString12]
              , ROUND(((60 * @hour) + (@minute)) / 5, 0) AS Minute5_Code
              , ROUND(((60 * @hour) + (@minute)) / 10, 0) AS Minute10_Code
              , ROUND(((60 * @hour) + (@minute)) / 15, 0) AS Minute15_Code
              , ROUND(((60 * @hour) + (@minute)) / 20, 0) AS Minute20_Code
              , ROUND(((60 * @hour) + (@minute)) / 30, 0) AS Minute30_Code
              , @second AS [Second]
              , RIGHT('0' + CONVERT(VARCHAR(2), @second), 2) AS [SecondShortString]
              , RIGHT('0' + CONVERT(VARCHAR(2), @hour), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @minute), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @second), 2) AS [FullTimeString24]
              , RIGHT('0' + CONVERT(VARCHAR(2), @hour % 12), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @minute), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @second), 2) AS [FullTimeString12]
              , CONVERT(TIME, RIGHT('0' + CONVERT(VARCHAR(2), @hour), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @minute), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @second), 2)) AS [FullTime]
        SET @minute = @minute + 1
    END
    SET @hour = @hour + 1
END


SELECT * FROM [MASTER].[TimeDimension]
