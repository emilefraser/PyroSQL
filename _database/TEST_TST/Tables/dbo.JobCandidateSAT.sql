SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[JobCandidateSAT](
	[JobCandidateVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Resume] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
