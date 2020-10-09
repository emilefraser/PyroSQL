SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE CreateTimeDimension
AS
DROP TABLE IF EXISTS [MASTER].[TimeDimension]

CREATE TABLE [MASTER].[TimeDimension] (
	[TimeKey]                 [INT] NOT NULL
  , [Hour24]                  [SMALLINT] NULL
  , [Hour24_String]			  [VARCHAR](2) NULL
  , [Hour24_MinString]        [VARCHAR](5) NULL
  , [Hour24_FullString]       [VARCHAR](8) NULL
  , [Hour12]                  [SMALLINT] NULL
  , [Hour12_String]			  [VARCHAR](2) NULL
  , [Hour12_MinString]        [VARCHAR](5) NULL
  , [Hour12_FullString]       [VARCHAR](8) NULL
  , [AMPM_Code]               [SMALLINT] NULL
  , [AMPM_String]             [VARCHAR](2) NOT NULL
  , [Minute]                  [SMALLINT] NULL
  , [Minute_Code]             [SMALLINT] NULL
  , [Minute_String]			  [VARCHAR](2) NULL
  , [Minute_FullString24]     [VARCHAR](8) NULL
  , [Minute_FullString12]     [VARCHAR](8) NULL
  , [Minute5_Code]			  [SMALLINT] NULL
  , [Minute10_Code]			  [SMALLINT] NULL
  , [Minute15_Code]			  [SMALLINT] NULL
  , [Minute20_Code]			  [SMALLINT] NULL
  , [Minute30_Code]			  [SMALLINT] NULL
  , [Second]                  [SMALLINT] NULL
  , [Second_String]			  [VARCHAR](2) NULL
  , [FullTime_String24]       [VARCHAR](8) NULL
  , [FullTime_String12]       [VARCHAR](8) NULL
  , [FullTime]                [TIME](7) NULL
  , CONSTRAINT [PK_DimTime] PRIMARY KEY CLUSTERED([TimeKey] ASC)
	WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY]
GO
