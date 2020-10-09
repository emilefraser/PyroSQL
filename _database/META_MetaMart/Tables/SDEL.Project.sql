SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [SDEL].[Project](
	[ProjectID] [int] IDENTITY(1,1) NOT NULL,
	[ProjectName] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
