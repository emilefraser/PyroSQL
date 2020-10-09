SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[suspect_pages](
	[database_id] [int] NOT NULL,
	[file_id] [int] NOT NULL,
	[page_id] [bigint] NOT NULL,
	[event_type] [int] NOT NULL,
	[error_count] [int] NOT NULL,
	[last_update_date] [datetime] NOT NULL
) ON [PRIMARY]

GO
