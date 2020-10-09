SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductReviewSAT](
	[ProductReviewVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[EmailAddress] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Rating] [tinyint] NOT NULL,
	[ReviewDate] [datetime] NOT NULL,
	[ReviewerName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Comments] [varchar](3850) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
