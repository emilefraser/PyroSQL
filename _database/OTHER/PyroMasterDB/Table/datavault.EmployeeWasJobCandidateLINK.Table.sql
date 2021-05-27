SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[EmployeeWasJobCandidateLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[EmployeeWasJobCandidateLINK](
	[EmployeeWasJobCandidateVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[EmployeeVID] [bigint] NOT NULL,
	[JobCandidateVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeWasJobCandidateVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeeVID] ASC,
	[JobCandidateVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeeVID] ASC,
	[JobCandidateVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeeVID] ASC,
	[JobCandidateVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeW__Emplo__05C49D7C]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeWasJobCandidateLINK]'))
ALTER TABLE [datavault].[EmployeeWasJobCandidateLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeW__Emplo__082C08DB]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeWasJobCandidateLINK]'))
ALTER TABLE [datavault].[EmployeeWasJobCandidateLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeW__Emplo__7C9A5A9E]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeWasJobCandidateLINK]'))
ALTER TABLE [datavault].[EmployeeWasJobCandidateLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeW__JobCa__06B8C1B5]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeWasJobCandidateLINK]'))
ALTER TABLE [datavault].[EmployeeWasJobCandidateLINK]  WITH CHECK ADD FOREIGN KEY([JobCandidateVID])
REFERENCES [datavault].[JobCandidateHUB] ([JobCandidateVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeW__JobCa__09202D14]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeWasJobCandidateLINK]'))
ALTER TABLE [datavault].[EmployeeWasJobCandidateLINK]  WITH CHECK ADD FOREIGN KEY([JobCandidateVID])
REFERENCES [datavault].[JobCandidateHUB] ([JobCandidateVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeW__JobCa__7D8E7ED7]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeWasJobCandidateLINK]'))
ALTER TABLE [datavault].[EmployeeWasJobCandidateLINK]  WITH CHECK ADD FOREIGN KEY([JobCandidateVID])
REFERENCES [datavault].[JobCandidateHUB] ([JobCandidateVID])
GO
