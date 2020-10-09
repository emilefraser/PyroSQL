SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DocumentIsResponsibilityOfOwnerLINK](
	[DocumentIsResponsibilityOfOwnerVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[DocumentVID] [bigint] NOT NULL,
	[OwnerEmployeeVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
