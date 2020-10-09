SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmail_query_transfer](
	[uid] [uniqueidentifier] NOT NULL,
	[text_data] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
