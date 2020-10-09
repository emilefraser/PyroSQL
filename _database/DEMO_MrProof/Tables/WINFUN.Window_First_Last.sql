SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [WINFUN].[Window_First_Last](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Department] [nchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DateUpdate] [date] NOT NULL,
	[Code] [int] NOT NULL
) ON [PRIMARY]

GO
