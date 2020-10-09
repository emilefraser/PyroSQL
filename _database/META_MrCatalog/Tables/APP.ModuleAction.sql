SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [APP].[ModuleAction](
	[ModuleActionID] [int] IDENTITY(1,1) NOT NULL,
	[ActionCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ActionDescription] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ModuleID] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
