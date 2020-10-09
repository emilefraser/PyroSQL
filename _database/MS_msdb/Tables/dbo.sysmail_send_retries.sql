SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmail_send_retries](
	[conversation_handle] [uniqueidentifier] NOT NULL,
	[mailitem_id] [int] NOT NULL,
	[send_attempts] [int] NOT NULL,
	[last_send_attempt_date] [datetime] NOT NULL
) ON [PRIMARY]

GO
