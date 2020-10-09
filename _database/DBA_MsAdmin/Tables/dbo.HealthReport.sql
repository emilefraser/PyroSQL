SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HealthReport](
	[HealthReportID] [int] IDENTITY(1,1) NOT NULL,
	[DateStamp] [datetime] NOT NULL,
	[GeneratedHTML] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
