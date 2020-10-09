SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [GOV].[SprintObjective](
	[SprintObjectiveID] [int] NOT NULL,
	[SprintObjectiveDescription] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SprintObjectiveLevel] [int] NOT NULL,
	[SprintID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[ModifiedDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
