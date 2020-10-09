SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DTA_reports_database](
	[DatabaseID] [int] IDENTITY(1,1) NOT NULL,
	[SessionID] [int] NOT NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsDatabaseSelectedToTune] [int] NULL
) ON [PRIMARY]

GO
