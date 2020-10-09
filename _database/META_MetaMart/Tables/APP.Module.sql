SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [APP].[Module](
	[ModuleID] [int] IDENTITY(1,1) NOT NULL,
	[ModuleName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ModuleDescription] [varchar](225) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
