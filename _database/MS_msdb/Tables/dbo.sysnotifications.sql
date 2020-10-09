SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysnotifications](
	[alert_id] [int] NOT NULL,
	[operator_id] [int] NOT NULL,
	[notification_method] [tinyint] NOT NULL
) ON [PRIMARY]

GO
