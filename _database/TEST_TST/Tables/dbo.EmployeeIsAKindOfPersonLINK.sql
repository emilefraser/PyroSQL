SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EmployeeIsAKindOfPersonLINK](
	[EmployeeIsAKindOfPersonVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[EmployeeVID] [bigint] NOT NULL,
	[PersonVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
