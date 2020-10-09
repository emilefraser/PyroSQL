SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DTA_tuningresults_part](
	[SessionID] [int] NOT NULL,
	[PartNumber] [int] NOT NULL,
	[Content] [nvarchar](3500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
