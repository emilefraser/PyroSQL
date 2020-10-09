SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DTA_reports_column](
	[ColumnID] [int] IDENTITY(1,1) NOT NULL,
	[TableID] [int] NOT NULL,
	[ColumnName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
