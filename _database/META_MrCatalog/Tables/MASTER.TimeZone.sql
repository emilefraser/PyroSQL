SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MASTER].[TimeZone](
	[TimeZoneID] [int] IDENTITY(1,1) NOT NULL,
	[CountryCode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CountryName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TimeZone] [char](32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Current_UTC_Offset] [char](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UTC_DST_Offset] [char](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
