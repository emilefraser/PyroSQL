SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DTA_tuninglog](
	[SessionID] [int] NOT NULL,
	[RowID] [int] NOT NULL,
	[CategoryID] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Event] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Statement] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Frequency] [int] NOT NULL,
	[Reason] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
