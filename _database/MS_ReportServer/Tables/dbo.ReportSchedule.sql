SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ReportSchedule](
	[ScheduleID] [uniqueidentifier] NOT NULL,
	[ReportID] [uniqueidentifier] NOT NULL,
	[SubscriptionID] [uniqueidentifier] NULL,
	[ReportAction] [int] NOT NULL
) ON [PRIMARY]

GO
