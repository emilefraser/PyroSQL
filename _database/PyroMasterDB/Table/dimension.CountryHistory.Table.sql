SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[CountryHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dimension].[CountryHistory](
	[CountryID] [smallint] NOT NULL,
	[CountryName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ISO_Code] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CountryAbbreviation] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
END
GO
