SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Data].[SystemErrorLog](
	[LogEntryId] [int] IDENTITY(1,1) NOT NULL,
	[TestSessionId] [int] NOT NULL,
	[CreatedTime] [datetime] NOT NULL,
	[LogMessage] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
