SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[JobCandidateSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[JobCandidateSAT](
	[JobCandidateVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Resume] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[JobCandidateVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__JobCandid__JobCa__006AEB82]') AND parent_object_id = OBJECT_ID(N'[datavault].[JobCandidateSAT]'))
ALTER TABLE [datavault].[JobCandidateSAT]  WITH CHECK ADD FOREIGN KEY([JobCandidateVID])
REFERENCES [datavault].[JobCandidateHUB] ([JobCandidateVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__JobCandid__JobCa__09952E60]') AND parent_object_id = OBJECT_ID(N'[datavault].[JobCandidateSAT]'))
ALTER TABLE [datavault].[JobCandidateSAT]  WITH CHECK ADD FOREIGN KEY([JobCandidateVID])
REFERENCES [datavault].[JobCandidateHUB] ([JobCandidateVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__JobCandid__JobCa__0BFC99BF]') AND parent_object_id = OBJECT_ID(N'[datavault].[JobCandidateSAT]'))
ALTER TABLE [datavault].[JobCandidateSAT]  WITH CHECK ADD FOREIGN KEY([JobCandidateVID])
REFERENCES [datavault].[JobCandidateHUB] ([JobCandidateVID])
GO
