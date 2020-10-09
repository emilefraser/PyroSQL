SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ASSESS].[BusinessRespondentDetails](
	[DetailsID] [int] IDENTITY(1,1) NOT NULL,
	[RespondentID] [int] NULL,
	[Department] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[JobGrade] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Gender] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Age] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LengthofService] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HighestQualification] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
