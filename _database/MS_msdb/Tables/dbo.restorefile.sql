SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[restorefile](
	[restore_history_id] [int] NOT NULL,
	[file_number] [numeric](10, 0) NULL,
	[destination_phys_drive] [nvarchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[destination_phys_name] [nvarchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
