SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EmployeeWasJobCandidateLINK](
	[EmployeeWasJobCandidateVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[EmployeeVID] [bigint] NOT NULL,
	[JobCandidateVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
